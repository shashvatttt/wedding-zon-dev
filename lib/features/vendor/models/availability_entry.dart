enum AvailabilityStatus { available, booked, unavailable }

class AvailabilityEntry {
  final DateTime date;
  final AvailabilityStatus status;
  final String? note;
  final String? id;

  AvailabilityEntry({
    required this.date,
    required this.status,
    this.note,
    this.id,
  });

  factory AvailabilityEntry.fromJson(Map<String, dynamic> json) {
    return AvailabilityEntry(
      date: DateTime.parse(json['date']),
      status: AvailabilityStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => AvailabilityStatus.booked,
      ),
      note: json['note'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'status': status.toString().split('.').last,
      if (note != null) 'note': note,
      if (id != null) '_id': id,
    };
  }

  AvailabilityEntry copyWith({
    DateTime? date,
    AvailabilityStatus? status,
    String? note,
    String? id,
  }) {
    return AvailabilityEntry(
      date: date ?? this.date,
      status: status ?? this.status,
      note: note ?? this.note,
      id: id ?? this.id,
    );
  }
}
