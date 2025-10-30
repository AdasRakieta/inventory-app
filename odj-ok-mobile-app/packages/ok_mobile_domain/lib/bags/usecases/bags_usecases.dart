part of '../../ok_mobile_domain.dart';

@lazySingleton
class BagsUsecases {
  BagsUsecases(this._bagsRepository, this._deviceConfigUsecases);

  final IBagsRepository _bagsRepository;
  final DeviceConfigUsecases _deviceConfigUsecases;
  List<Bag> get _allBags => [..._openBags, ..._closedBags];
  final List<Bag> _openBags = <Bag>[];
  final List<Bag> _closedBags = <Bag>[];

  List<Bag> get openBags => _openBags;
  List<Bag> get closedBags => _closedBags;

  Future<Either<Failure, Bag>> addBag(BagMetadata bag) async {
    final result = await _bagsRepository.addBag(bag);

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (bagWithId) {
        _openBags.add(bagWithId);

        return Right(bagWithId);
      },
    );
  }

  Future<Either<Failure, List<Bag>?>> fetchOpenBags() async {
    final result = await _bagsRepository.fetchOpenBags(
      collectionPointId: _deviceConfigUsecases.collectionPointData.id,
    );

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (openBags) {
        _openBags
          ..clear()
          ..addAll(openBags);

        return Right(
          openBags..sort((a, b) => -a.openedTime!.compareTo(b.openedTime!)),
        );
      },
    );
  }

  Future<Either<Failure, List<Bag>?>> fetchClosedBags() async {
    final result = await _bagsRepository.fetchClosedBags(
      collectionPointId: _deviceConfigUsecases.collectionPointData.id,
    );

    return result.fold(
      (failure) {
        return Left(failure);
      },
      (closedBags) {
        _closedBags
          ..clear()
          ..addAll(closedBags);

        return Right(
          closedBags..sort((a, b) => -a.closedTime!.compareTo(b.closedTime!)),
        );
      },
    );
  }

  Bag? getBagById(String id) =>
      _allBags.firstWhereOrNull((Bag bag) => bag.id == id);

  Bag? getBagByLabel(String bagLabel) =>
      _allBags.firstWhereOrNull((Bag bag) => bag.label == bagLabel);

  Bag? getBagBySeal(String bagSeal) =>
      _allBags.firstWhereOrNull((Bag bag) => bag.seal == bagSeal);

  List<Bag> getBags({
    List<BagType>? selectedTypes,
    List<BagState>? selectedStates,
  }) {
    final types = selectedTypes ?? BagType.values;

    var filteredSortedOpenBags = <Bag>[];
    var filteredSortedClosedBags = <Bag>[];

    if (selectedStates!.contains(BagState.open)) {
      filteredSortedOpenBags =
          _openBags
              .where(
                (element) => (types.contains(element.type) || types.isEmpty),
              )
              .toList()
            ..sort((a, b) => -a.openedTime!.compareTo(b.openedTime!));
    }

    if (selectedStates.contains(BagState.closed)) {
      filteredSortedClosedBags =
          _closedBags
              .where(
                (element) => (types.contains(element.type) || types.isEmpty),
              )
              .toList()
            ..sort((a, b) => -a.closedTime!.compareTo(b.closedTime!));
    }

    return [...filteredSortedOpenBags, ...filteredSortedClosedBags];
  }

  Future<Either<Failure, Success?>> updateBagLabel(
    String bagId, {
    required String newLabel,
    required ActionReason reason,
  }) async {
    final result = await _bagsRepository.updateBagLabel(
      bagId,
      newLabel: newLabel,
      reason: reason,
    );

    return result.fold(Left.new, (_) {
      final changedBag = _allBags.firstWhere((bag) => bag.id == bagId);

      if (changedBag.state == BagState.closed) {
        _closedBags
          ..remove(changedBag)
          ..add(changedBag.copyWith(label: newLabel));
        if (reason == ActionReason.tornBag) {
          _closedBags
            ..remove(changedBag)
            ..add(changedBag.copyWith(seal: () => null, label: newLabel));
        }
      } else if (changedBag.state == BagState.open) {
        _openBags
          ..remove(changedBag)
          ..add(changedBag.copyWith(label: newLabel));
      }

      return Right(Success(message: S.current.label_has_been_changed));
    });
  }

  Future<Either<Failure, Success?>> updateBagSeal(
    String bagId, {
    required String newSeal,
    required ActionReason reason,
  }) async {
    final result = await _bagsRepository.updateBagSeal(
      bagId,
      newSeal: newSeal,
      reason: reason,
    );

    return result.fold(Left.new, (_) {
      final changedBag = _allBags.firstWhere((bag) => bag.id == bagId);
      // Only closed bags may have their seal changed
      _closedBags
        ..remove(changedBag)
        ..add(changedBag.copyWith(seal: () => newSeal));
      return Right(Success(message: S.current.seal_was_added_successfully));
    });
  }

  Future<Either<Failure, Success?>> updateBag(
    String bagId, {
    required String newLabel,
    required String newSeal,
    required ActionReason reason,
  }) async {
    final result = await _bagsRepository.updateBag(
      bagId,
      newLabel: newLabel,
      newSeal: newSeal,
      reason: reason,
    );

    return result.fold(Left.new, (_) {
      final changedBag = _allBags.firstWhere((bag) => bag.id == bagId);
      // Only closed bags may have their seal changed
      _closedBags
        ..remove(changedBag)
        ..add(changedBag.copyWith(label: newLabel, seal: () => newSeal));
      return Right(Success(message: S.current.label_and_seal_changed));
    });
  }

  Future<Either<Failure, Success?>> closeAndSealBag(
    String bagId, {
    required String seal,
  }) async {
    final result = await _bagsRepository.closeAndSealBag(bagId, seal: seal);

    return result.fold(Left.new, (_) {
      final changedBag = _allBags.firstWhere((bag) => bag.id == bagId);
      _openBags.remove(changedBag);
      _closedBags.add(changedBag.close().copyWith(seal: () => seal));
      return Right(Success(message: S.current.seal_added_successfully));
    });
  }
}
