class VendorAvailability {
  final String? id;
  final DateTime date;
  final String status;
  final String? note;

  VendorAvailability({
    this.id,
    required this.date,
    required this.status,
    this.note,
  });

  factory VendorAvailability.fromJson(Map<String, dynamic> json) {
    return VendorAvailability(
      id: json['_id'] ?? json['id'],
      date: DateTime.parse(json['date']),
      status: json['status'] ?? 'available',
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'date': date.toIso8601String(),
      'status': status,
      if (note != null) 'note': note,
    };
  }

  bool get isBooked => status == 'booked';
  bool get isAvailable => status == 'available';
  bool get isUnavailable => status == 'unavailable';
}
