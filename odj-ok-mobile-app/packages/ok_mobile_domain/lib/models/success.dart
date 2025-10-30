part of '../ok_mobile_domain.dart';

enum SuccessType { general }

class Success extends Equatable implements Result {
  const Success({this.type = SuccessType.general, this.message});

  final SuccessType type;
  @override
  final String? message;

  @override
  List<Object?> get props => [type, message];
}
