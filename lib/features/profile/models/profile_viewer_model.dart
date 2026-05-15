class ProfileViewer {
  final Map<String, dynamic> viewer;
  final DateTime viewedAt;

  ProfileViewer({required this.viewer, required this.viewedAt});

  factory ProfileViewer.fromJson(Map<String, dynamic> json) {
    return ProfileViewer(
      viewer: json['viewer'] as Map<String, dynamic>? ?? {},
      viewedAt:
          DateTime.tryParse(json['viewedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String get id => viewer['_id']?.toString() ?? '';
  String get username => viewer['username']?.toString() ?? 'Unknown';
  String get firstName =>
      viewer['firstName']?.toString() ?? viewer['first_name']?.toString() ?? '';
  String get lastName =>
      viewer['lastName']?.toString() ?? viewer['last_name']?.toString() ?? '';
  String get profilePhoto => viewer['profilePhoto']?.toString() ?? '';

  String get fullName {
    final first = firstName;
    final last = lastName;
    if (first.isNotEmpty && last.isNotEmpty) {
      return '$first $last';
    } else if (first.isNotEmpty) {
      return first;
    } else if (last.isNotEmpty) {
      return last;
    }

    final fullNameField =
        viewer['full_name']?.toString() ?? viewer['fullName']?.toString() ?? '';
    if (fullNameField.isNotEmpty) {
      return fullNameField;
    }

    return username;
  }
}
