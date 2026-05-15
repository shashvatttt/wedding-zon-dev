class PartnerPreference {
  final int? minAge;
  final int? maxAge;
  final String? heightMin;
  final String? heightMax;
  final String? religion;
  final String? community;
  final String? location;
  final List<String>? maritalStatus;
  final String? eatingHabits;
  final String? smokingHabits;
  final String? drinkingHabits;
  final String? highestEducation;
  final String? occupation;
  final String? annualIncome;

  final String? country;
  final String? state;
  final String? city;
  final String? motherTongue;
  final List<String>? profileManagedBy;
  final String? familyStatus;
  final String? manglikStatus;

  PartnerPreference({
    this.minAge,
    this.maxAge,
    this.heightMin,
    this.heightMax,
    this.religion,
    this.community,
    this.location,
    this.maritalStatus,
    this.eatingHabits,
    this.smokingHabits,
    this.drinkingHabits,
    this.highestEducation,
    this.occupation,
    this.annualIncome,
    this.country,
    this.state,
    this.city,
    this.motherTongue,
    this.profileManagedBy,
    this.familyStatus,
    this.manglikStatus,
  });

  factory PartnerPreference.fromJson(Map<String, dynamic> json) {
    print('[PartnerPreference] JSON keys: ${json.keys.toList()}');

    return PartnerPreference(
      minAge: _parseIntFromDynamic(json['minAge'] ?? json['age_min']),
      maxAge: _parseIntFromDynamic(json['maxAge'] ?? json['age_max']),
      heightMin: (json['heightMin'] ?? json['height_min'])?.toString(),
      heightMax: (json['heightMax'] ?? json['height_max'])?.toString(),
      religion: json['religion']?.toString(),
      community: json['community']?.toString(),
      location: json['location']?.toString(),
      maritalStatus: _parseList(
        json['marital_status'] ?? json['maritalStatus'],
      ),
      eatingHabits: json['eating_habits']?.toString(),
      smokingHabits: json['smoking_habits']?.toString(),
      drinkingHabits: json['drinking_habits']?.toString(),
      highestEducation: json['highest_education']?.toString(),
      occupation: json['occupation']?.toString(),
      annualIncome: json['annual_income']?.toString(),
      country: json['country']?.toString(),
      state: json['state']?.toString(),
      city: json['city']?.toString(),
      motherTongue: json['mother_tongue']?.toString(),
      profileManagedBy: _parseList(
        json['profile_managed_by'] ?? json['profileManagedBy'],
      ),
      familyStatus: json['family_status']?.toString(),
      manglikStatus: json['manglik_status']?.toString(),
    );
  }

  static int? _parseIntFromDynamic(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static List<String>? _parseList(dynamic value) {
    if (value == null) return null;
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      if (value.contains(',')) {
        return value.split(',').map((e) => e.trim()).toList();
      }
      return [value];
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (minAge != null) {
      data['minAge'] = minAge;
      data['age_min'] = minAge;
    }
    if (maxAge != null) {
      data['maxAge'] = maxAge;
      data['age_max'] = maxAge;
    }
    if (heightMin != null) {
      data['heightMin'] = heightMin;
      data['height_min'] = heightMin;
    }
    if (heightMax != null) {
      data['heightMax'] = heightMax;
      data['height_max'] = heightMax;
    }
    if (religion != null) data['religion'] = religion;
    if (community != null) data['community'] = community;
    if (location != null) data['location'] = location;
    if (maritalStatus != null) data['marital_status'] = maritalStatus;
    if (eatingHabits != null) data['eating_habits'] = eatingHabits;
    if (smokingHabits != null) data['smoking_habits'] = smokingHabits;
    if (drinkingHabits != null) data['drinking_habits'] = drinkingHabits;
    if (highestEducation != null) data['highest_education'] = highestEducation;
    if (occupation != null) data['occupation'] = occupation;
    if (annualIncome != null) data['annual_income'] = annualIncome;
    if (country != null) data['country'] = country;
    if (state != null) data['state'] = state;
    if (city != null) data['city'] = city;
    if (motherTongue != null) data['mother_tongue'] = motherTongue;
    if (profileManagedBy != null) data['profile_managed_by'] = profileManagedBy;
    if (familyStatus != null) data['family_status'] = familyStatus;
    if (manglikStatus != null) data['manglik_status'] = manglikStatus;
    return data;
  }
}
