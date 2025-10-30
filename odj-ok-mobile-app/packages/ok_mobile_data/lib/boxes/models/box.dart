part of '../../../ok_mobile_data.dart';

class Box {
  Box({
    required this.id,
    required this.label,
    required this.dateOpened,
    bool? isOpen,
    DateTime? dateClosed,
    this.bags = const [],
  }) {
    _isOpen = isOpen ?? _isOpen;
    _dateClosed = dateClosed;
  }

  factory Box.fromJson(Map<String, dynamic> json) {
    return Box(
      id: json['id'] as String,
      label: json['label'] as String,
      dateOpened: DateTime.parse(
        DatesHelper.asUTC(json['dateOpened'] as String?),
      ).toLocal(),
      dateClosed: DateTime.parse(
        DatesHelper.asUTC(json['dateClosed'] as String?),
      ).toLocal(),
      isOpen: json['isOpen'] as bool?,
    );
  }

  factory Box.empty() {
    return Box(label: '', id: '', dateOpened: DateTime.now(), isOpen: true);
  }

  @override
  String toString() {
    return 'Box(id: $id, label: $label, dateOpened: $dateOpened, isOpen: '
        '$isOpen, dateClosed: $dateClosed, bags: $bags)';
  }

  void close() {
    _isOpen = false;
    _dateClosed = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'dateOpened': dateOpened,
      'dateClosed': dateClosed,
      'isOpen': isOpen,
      'bags': bags,
    };
  }

  bool get isEmpty => label.isEmpty;

  final String id;
  final String label;
  final DateTime dateOpened;
  bool _isOpen = true;
  DateTime? _dateClosed;
  final List<Bag> bags;

  bool get isOpen => _isOpen;
  DateTime? get dateClosed => _dateClosed;

  Box copyWith({
    String? id,
    String? label,
    DateTime? dateOpened,
    DateTime? dateClosed,
    bool? isOpen,
    List<Bag>? bags,
  }) {
    return Box(
      id: id ?? this.id,
      label: label ?? this.label,
      dateOpened: dateOpened ?? this.dateOpened,
      dateClosed: dateClosed ?? this.dateClosed,
      isOpen: isOpen ?? this.isOpen,
      bags: bags ?? this.bags,
    );
  }
}
