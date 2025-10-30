part of '../ok_mobile_admin.dart';

class AdminState extends Equatable implements BaseState {
  const AdminState({
    required this.state,
    this.result,
    this.selectedPrinterMacAddress,
  });

  factory AdminState.initial() => const AdminState(state: GeneralState.loaded);

  final Result? result;
  final GeneralState state;
  final String? selectedPrinterMacAddress;

  AdminState copyWith({
    Result? result,
    GeneralState? state,
    String? selectedPrinterMacAddress,
  }) {
    return AdminState(
      result: result,
      state: state ?? this.state,
      selectedPrinterMacAddress: selectedPrinterMacAddress,
    );
  }

  @override
  List<Object?> get props => [result, state, selectedPrinterMacAddress];

  @override
  GeneralState get generalState => state;

  @override
  Result? get resultObject => result;
}
