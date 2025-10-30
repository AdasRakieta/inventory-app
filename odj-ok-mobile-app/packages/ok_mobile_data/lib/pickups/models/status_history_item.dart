part of '../../../ok_mobile_data.dart';

class StatusHistoryItem {
  StatusHistoryItem({required this.status, this.dateModified});

  factory StatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return StatusHistoryItem(
      dateModified: DateTime.parse(
        DatesHelper.asUTC(json['dateModified'] as String),
      ).toLocal(),
      status: PickupStatus.values.firstWhere(
        (e) => e.jsonKey == json['status'],
      ),
    );
  }

  final DateTime? dateModified;
  final PickupStatus status;

  @override
  String toString() {
    return 'StatusHistoryItem(dateModified: $dateModified, status: $status';
  }
}
