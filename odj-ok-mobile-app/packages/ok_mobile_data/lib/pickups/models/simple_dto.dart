part of '../../../ok_mobile_data.dart';

class SimpleDto {
  SimpleDto({required this.id});

  final String id;

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
