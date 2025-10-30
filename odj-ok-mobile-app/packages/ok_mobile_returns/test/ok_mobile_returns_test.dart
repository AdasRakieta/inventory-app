import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ok_mobile_common/ok_mobile_common.dart';
import 'package:ok_mobile_data/ok_mobile_data.dart';
import 'package:ok_mobile_domain/ok_mobile_domain.dart';
import 'package:ok_mobile_returns/ok_mobile_returns.dart';
import 'package:ok_mobile_translations/ok_mobile_translations.dart';

class MockReturnsUsecases extends Mock implements ReturnsUsecases {}

class MockEnvironmentProvider extends Mock implements AppConfigProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReturnsCubit tests', () {
    late ReturnsCubit returnsCubit;
    late MockReturnsUsecases mockReturnsUsecases;
    late AppConfigProvider mockAppConfigProvider;

    late Failure failure;
    late Return testReturn;
    late Package testPackage1;
    late Package testPackage2;

    const testEan1 = '123456789';
    const testEan2 = '8468563456';
    const testBagId = '12345';

    setUpAll(() async {
      await initializeDateFormatting('en');
      await S.load(const Locale('en'));

      mockAppConfigProvider = MockEnvironmentProvider();

      getIt.registerSingleton<AppConfigProvider>(mockAppConfigProvider);

      when(
        () => mockAppConfigProvider.environment,
      ).thenReturn(AppEnvironmentEnum.prd);

      // those 2 methods are needed for printVoucher test to work
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('flutter.baseflow.com/permissions/methods'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'requestPermissions') {
                return {1: 1};
              }
              return null;
            },
          );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('ok_mobile_zebra_printer'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'printVoucher') {
                return 'true';
              }
              return null;
            },
          );
    });

    setUp(() {
      mockReturnsUsecases = MockReturnsUsecases();

      failure = const Failure(
        type: FailureType.general,
        severity: FailureSeverity.error,
      );

      testPackage1 = Package(
        eanCode: testEan1,
        description: 'Test Package 1',
        type: BagType.can,
        quantity: 1,
        deposit: 0.5,
        bagId: testBagId,
      );
      testPackage2 = Package(
        eanCode: testEan2,
        description: 'Test Package 2',
        type: BagType.plastic,
        quantity: 1,
        deposit: 0.5,
        bagId: testBagId,
      );

      testReturn = Return(
        id: 'return_id',
        state: ReturnState.ongoing,
        packages: [testPackage1, testPackage2],
        voucher: Voucher(id: '123', code: '123', depositValue: 1),
      );

      registerFallbackValue(testReturn);

      when(
        () => mockReturnsUsecases.getCachedData(),
      ).thenAnswer((_) async => testReturn);
      returnsCubit = ReturnsCubit(mockReturnsUsecases);
    });

    blocTest<ReturnsCubit, ReturnsState>(
      'emits [loading, loaded] with cached data when checkForCache is called',
      build: () => returnsCubit,
      act: (cubit) async {
        await cubit.checkForCache();
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<ReturnsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.openedReturn, 'openedReturn', testReturn),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits [loading, error] when fetchReturns fails',
      build: () {
        when(
          () => mockReturnsUsecases.fetchReturns(),
        ).thenAnswer((_) async => Left(failure));
        return returnsCubit;
      },
      act: (cubit) async {
        await cubit.fetchReturns();
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<ReturnsState>()
            .having((state) => state.state, 'state', GeneralState.error)
            .having((state) => state.result, 'result', failure)
            .having((state) => state.returns, 'returns', isEmpty),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits [loading, loaded] with returns when fetchReturns is successful',
      build: () {
        when(
          () => mockReturnsUsecases.fetchReturns(),
        ).thenAnswer((_) async => Right([testReturn]));
        return returnsCubit;
      },
      act: (cubit) async {
        await cubit.fetchReturns();
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<ReturnsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.returns, 'returns', [testReturn]),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'adds new state to selectedStates when changeStateFilter is called',
      build: () => returnsCubit,
      seed: () => ReturnsState.initial().copyWith(
        selectedStatesPerScreen: {
          ClosedReturnsScreen.routeName: [ReturnState.ongoing],
        },
      ),
      act: (cubit) {
        cubit.changeStateFilter(
          ClosedReturnsScreen.routeName,
          ReturnState.printed,
        );
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) =>
              state.selectedStatesPerScreen[ClosedReturnsScreen.routeName],
          'selectedStates',
          [ReturnState.ongoing, ReturnState.printed],
        ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'removes state from selectedStates when changeStateFilter is called',
      build: () => returnsCubit,
      seed: () => ReturnsState.initial().copyWith(
        selectedStatesPerScreen: {
          ClosedReturnsScreen.routeName: [
            ReturnState.ongoing,
            ReturnState.canceled,
          ],
        },
      ),
      act: (cubit) {
        cubit.changeStateFilter(
          ClosedReturnsScreen.routeName,
          ReturnState.ongoing,
        );
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) =>
              state.selectedStatesPerScreen[ClosedReturnsScreen.routeName],
          'selectedStatesPerScreen for ClosedReturnsScreen',
          [ReturnState.canceled],
        ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits [loading, loaded] with success when printVoucher is successful',
      build: () {
        when(
          () => mockReturnsUsecases.requestVoucherPrint('voucher_id'),
        ).thenAnswer((_) async => const Right(null));
        return returnsCubit;
      },
      act: (cubit) async {
        final result = await cubit.printVoucher(
          voucherId: 'voucher_id',
          voucherCode: 'voucher_code',
          depositValue: 10,
          returnCode: 'return_code',
          packages: [testPackage1],
          macAddress: 'mac_address',
          collectionPoint: const CollectionPointData(
            id: '',
            segregatesItems: true,
            nip: 'nip',
            code: 'code',
            collectedPackagingType: CollectedPackagingTypeEnum.allTypes,
          ),
          contractorData: const ContractorData(
            id: 'contractor_id',
            name: 'Contractor Name',
            code: 'contractor_code',
            addressCity: 'City',
            krs: '123456789',
            court: 'District Court',
          ),
        );
        expect(result, isTrue);
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loaded,
        ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits [loading, loaded] with failure when printVoucher fails',
      build: () {
        when(
          () => mockReturnsUsecases.requestVoucherPrint('voucher_id'),
        ).thenAnswer((_) async => Left(failure));
        return returnsCubit;
      },
      act: (cubit) async {
        final result = await cubit.printVoucher(
          voucherId: 'voucher_id',
          voucherCode: 'voucher_code',
          depositValue: 10,
          returnCode: 'return_code',
          packages: [testPackage1],
          macAddress: 'mac_address',
          collectionPoint: const CollectionPointData(
            id: '',
            segregatesItems: true,
            code: 'code',
            collectedPackagingType: CollectedPackagingTypeEnum.allTypes,
          ),
          contractorData: const ContractorData(
            id: 'contractor_id',
            name: 'Contractor Name',
            code: 'contractor_code',
            addressCity: 'City',
            krs: '123456789',
            court: 'District Court',
          ),
        );
        expect(result, isFalse);
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<ReturnsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.result, 'result', failure),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits [loading, loaded] when checkPrinter is successful',
      build: () => returnsCubit,
      act: (cubit) async {
        final result = await cubit.checkPrinter('mac_address');
        expect(result, isTrue);
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loaded,
        ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits [loading, loaded] with failure when checkPrinter fails',
      build: () => returnsCubit,
      act: (cubit) async {
        final result = await cubit.checkPrinter(null);
        expect(result, isFalse);
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<ReturnsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.result,
              'result',
              Failure(
                type: FailureType.noPrinterConfigured,
                severity: FailureSeverity.error,
                message: S.current.no_printer_configured,
              ),
            ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits [loading, loaded + ReturnState.printed + Success] when '
      'confirmVoucherPrint is successful for the first time',
      build: () {
        when(
          () => mockReturnsUsecases.confirmVoucherPrinted(any()),
        ).thenAnswer((_) async => const Right(null));
        return returnsCubit;
      },
      seed: () => ReturnsState.initial().copyWith(
        openedReturn: testReturn,
        returns: [testReturn],
      ),
      act: (cubit) async {
        final result = await cubit.confirmVoucherPrint(testReturn);
        expect(result, isTrue);
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<ReturnsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.result,
              'result',
              isA<Success>().having(
                (success) => success.message,
                'message',
                S.current.voucher_printed_for_client,
              ),
            )
            .having(
              (state) => state.returns.first.state,
              'state.returns.first.state',
              ReturnState.printed,
            ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits [loading, loaded + ReturnState.printed + Success] when '
      'confirmVoucherPrint is successful in reprint mode',
      build: () {
        when(
          () => mockReturnsUsecases.confirmVoucherPrinted(any()),
        ).thenAnswer((_) async => const Right(null));
        return returnsCubit;
      },
      seed: () => ReturnsState.initial().copyWith(
        openedReturn: testReturn,
        returns: [testReturn],
      ),
      act: (cubit) async {
        final result = await cubit.confirmVoucherPrint(
          testReturn,
          isReprint: true,
        );
        expect(result, isTrue);
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<ReturnsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.result,
              'result',
              isA<Success>().having(
                (success) => success.message,
                'message',
                S.current.reprint_voucher_confirmation,
              ),
            )
            .having(
              (state) => state.returns.first.state,
              'state.returns.first.state',
              ReturnState.printed,
            ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits [loading, loaded + failure] when confirmVoucherPrint fails',
      build: () {
        when(
          () => mockReturnsUsecases.confirmVoucherPrinted(any()),
        ).thenAnswer((_) async => Left(failure));
        return returnsCubit;
      },
      seed: () => ReturnsState.initial().copyWith(
        openedReturn: testReturn,
        returns: [testReturn],
      ),
      act: (cubit) async {
        final result = await cubit.confirmVoucherPrint(testReturn);
        expect(result, isFalse);
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<ReturnsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.result, 'result', failure),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits [loading, loaded + voucherCancellationReason] when '
      'cancelVoucherPrint is successful',
      build: () {
        when(
          () => mockReturnsUsecases.cancelVoucherPrint(
            any(),
            reason: ActionReason.clientResignation,
          ),
        ).thenAnswer((_) async => const Right(''));
        return returnsCubit;
      },
      seed: () => ReturnsState.initial().copyWith(
        openedReturn: testReturn,
        returns: [testReturn],
      ),
      act: (cubit) async {
        await cubit.cancelVoucherPrint(
          testReturn,
          reason: ActionReason.clientResignation,
        );
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<ReturnsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.returns.first.voucherCancellationReason,
              'state.returns.first.voucherCancellationReason',
              ActionReason.clientResignation,
            ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits [loading, loaded] with failure when cancelVoucherPrint fails',
      build: () {
        when(
          () => mockReturnsUsecases.cancelVoucherPrint(
            any(),
            reason: ActionReason.clientResignation,
          ),
        ).thenAnswer((_) async => Left(failure));
        return returnsCubit;
      },
      seed: () => ReturnsState.initial().copyWith(openedReturn: testReturn),
      act: (cubit) async {
        await cubit.cancelVoucherPrint(
          testReturn,
          reason: ActionReason.clientResignation,
        );
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<ReturnsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.result, 'result', failure),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits updated openedReturn when createNewReturn is called',
      build: () {
        when(
          () => mockReturnsUsecases.changeCachedData(any()),
        ).thenAnswer((_) async {});
        return returnsCubit;
      },
      act: (cubit) {
        cubit.createNewReturn();
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.openedReturn,
          'openedReturn',
          isA<Return>()
              .having((r) => r.state, 'state', ReturnState.ongoing)
              .having((r) => r.packages, 'packages', <Package>[]),
        ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits updated openedReturn when increasePackageQuantity is called',
      build: () {
        when(
          () => mockReturnsUsecases.changeCachedData(any()),
        ).thenAnswer((_) async {});
        return returnsCubit;
      },
      seed: () => ReturnsState.initial().copyWith(openedReturn: testReturn),
      act: (cubit) {
        cubit.increasePackageQuantity(testPackage1.eanCode, testBagId);
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.openedReturn.packages.first.quantity,
          'quantity',
          2,
        ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits updated openedReturn when decreasePackageQuantity is called',
      build: () {
        when(
          () => mockReturnsUsecases.changeCachedData(any()),
        ).thenAnswer((_) async {});
        return returnsCubit;
      },
      seed: () => ReturnsState.initial().copyWith(openedReturn: testReturn),
      act: (cubit) {
        cubit.decreasePackageQuantity(testPackage1.eanCode, testBagId);
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.openedReturn.packages.first.quantity,
          'quantity',
          0,
        ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'addPackage: returns false and adds package when type is glass '
      '(BagType.glass, _)',
      build: () {
        when(
          () => mockReturnsUsecases.changeCachedData(any()),
        ).thenAnswer((_) async {});
        return returnsCubit;
      },
      seed: () => ReturnsState.initial().copyWith(
        openedReturn: testReturn.copyWith(packages: []),
      ),
      act: (cubit) {
        final glassPackage = Package(
          eanCode: 'glass_ean',
          description: 'Glass Package',
          type: BagType.glass,
          quantity: 1,
          deposit: 0.5,
        );
        final result = cubit.addPackage(glassPackage);
        expect(result, isFalse);
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.openedReturn.packages.any(
            (package) => package.eanCode == 'glass_ean',
          ),
          'contains glass package',
          isTrue,
        ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'addPackage: returns true and adds package with warning when bag is null',
      build: () {
        when(
          () => mockReturnsUsecases.changeCachedData(any()),
        ).thenAnswer((_) async {});
        return returnsCubit;
      },
      seed: () => ReturnsState.initial().copyWith(
        openedReturn: testReturn.copyWith(packages: []),
        isScannerLocked: false,
      ),
      act: (cubit) {
        final result = cubit.addPackage(testPackage1);
        expect(result, isTrue);
      },
      expect: () => [
        isA<ReturnsState>()
            .having(
              (state) => state.openedReturn.packages.any(
                (package) => package.eanCode == testPackage1.eanCode,
              ),
              'contains package',
              isTrue,
            )
            .having((state) => state.result, 'result', null),

        isA<ReturnsState>()
            .having(
              (state) => state.openedReturn.packages.any(
                (package) => package.eanCode == testPackage1.eanCode,
              ),
              'contains package',
              isTrue,
            )
            .having(
              (state) => state.result,
              'result',
              Failure(
                type: FailureType.general,
                severity: FailureSeverity.warning,
                message: S.current.scanned_package_must_be_assigned_to_bag,
              ),
            ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'addPackage: returns true and adds package with warning when bag type '
      'does not match package type',
      build: () {
        when(
          () => mockReturnsUsecases.changeCachedData(any()),
        ).thenAnswer((_) async {});
        return returnsCubit;
      },
      seed: () => ReturnsState.initial().copyWith(
        openedReturn: testReturn.copyWith(packages: []),
        isScannerLocked: false,
      ),
      act: (cubit) {
        const bag = Bag(
          id: 'bag_id',
          label: 'label',
          type: BagType.plastic,
          state: BagState.open,
          packages: [],
        );
        final canPackage = Package(
          eanCode: 'can_ean',
          description: 'Can Package',
          type: BagType.can,
          quantity: 1,
          deposit: 0.5,
        );
        final result = cubit.addPackage(canPackage, bag);
        expect(result, isTrue);
      },
      expect: () => [
        isA<ReturnsState>()
            .having(
              (state) => state.openedReturn.packages.any(
                (package) => package.eanCode == 'can_ean',
              ),
              'contains package',
              isTrue,
            )
            .having((state) => state.result, 'result', null),
        isA<ReturnsState>().having(
          (state) => state.result,
          'result',
          Failure(
            type: FailureType.general,
            severity: FailureSeverity.warning,
            message: S.current.scanned_package_requires_bag_change,
          ),
        ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'addPackage: returns false and adds package with bagId when bag type '
      'matches package type',
      build: () {
        when(
          () => mockReturnsUsecases.changeCachedData(any()),
        ).thenAnswer((_) async {});
        return returnsCubit;
      },
      seed: () => ReturnsState.initial().copyWith(
        openedReturn: testReturn.copyWith(packages: []),
      ),
      act: (cubit) {
        const bag = Bag(
          id: 'bag_id',
          label: 'label',
          type: BagType.can,
          state: BagState.open,
          packages: [],
        );
        final canPackage = Package(
          eanCode: 'can_ean',
          description: 'Can Package',
          type: BagType.can,
          quantity: 1,
          deposit: 0.5,
        );
        final result = cubit.addPackage(canPackage, bag);
        expect(result, isFalse);
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.openedReturn.packages.any(
            (p) => p.eanCode == 'can_ean' && p.bagId == 'bag_id',
          ),
          'contains package with correct bagId',
          isTrue,
        ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits updated openedReturn when removePackage is called',
      build: () {
        when(() => mockReturnsUsecases.changeCachedData(testReturn)).thenAnswer(
          (_) async {
            return;
          },
        );
        return returnsCubit;
      },
      seed: () => ReturnsState.initial().copyWith(openedReturn: testReturn),
      act: (cubit) {
        cubit.removePackage(testPackage1.eanCode, testBagId);
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.openedReturn.packages,
          'packages',
          [testPackage2],
        ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits empty openedReturn when rejectReturn is called',
      build: () {
        when(mockReturnsUsecases.removeCache).thenAnswer((_) async {
          return;
        });
        return returnsCubit;
      },
      seed: () => ReturnsState.initial().copyWith(openedReturn: testReturn),
      act: (cubit) {
        cubit.rejectReturn();
      },
      expect: () => [
        isA<ReturnsState>(),
        isA<ReturnsState>().having(
          (state) => state.openedReturn,
          'openedReturn',
          isA<Return>().having((r) => r.id, 'id', isEmpty),
        ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits [loading, loaded] with success when closeReturn is successful',
      build: () {
        when(mockReturnsUsecases.removeCache).thenAnswer((_) async {
          return;
        });
        when(() => mockReturnsUsecases.closeReturn(any<Return>())).thenAnswer((
          _,
        ) async {
          return Right(testReturn.copyWith(id: 'new_id'));
        });
        return returnsCubit;
      },
      seed: () => ReturnsState.initial().copyWith(openedReturn: testReturn),
      act: (cubit) async {
        final result = await cubit.closeReturn(VoucherDisplayType.printable);
        expect(result, 'new_id');
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<ReturnsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having(
              (state) => state.returns,
              'state.returns',
              contains(isA<Return>().having((r) => r.id, 'id', 'new_id')),
            )
            .having(
              (state) => state.openedReturn,
              'openedReturn',
              isA<Return>().having((r) => r.id, 'id', isEmpty),
            )
            .having(
              (state) => state.result,
              'result',
              Success(message: S.current.return_closed_print_voucher),
            ),
      ],
    );

    blocTest<ReturnsCubit, ReturnsState>(
      'emits [loading, loaded + failure] when closeReturn fails',
      build: () {
        when(() => mockReturnsUsecases.closeReturn(any<Return>())).thenAnswer((
          _,
        ) async {
          return Left(failure);
        });
        return returnsCubit;
      },
      seed: () => ReturnsState.initial().copyWith(openedReturn: testReturn),
      act: (cubit) async {
        final result = await cubit.closeReturn(VoucherDisplayType.printable);
        expect(result, isNull);
      },
      expect: () => [
        isA<ReturnsState>().having(
          (state) => state.state,
          'state',
          GeneralState.loading,
        ),
        isA<ReturnsState>()
            .having((state) => state.state, 'state', GeneralState.loaded)
            .having((state) => state.result, 'result', failure),
      ],
    );
  });
}
