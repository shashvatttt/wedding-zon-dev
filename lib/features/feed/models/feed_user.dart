import 'package:flutter/foundation.dart';
import '../../../core/models/photo_model.dart';

class FeedUser {
  final String id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? profilePhoto;
  final List<Photo> photos;
  final String? aboutMe;
  final String? dob;
  final int? ageFromApi;
  final String? city;
  final String? state;
  final String? country;
  final String? occupation;
  final String? religion;
  final String? gender;
  final String? height;
  final String? maritalStatus;
  final String? motherTongue;

  final String? fatherStatus;
  final String? motherStatus;
  final int? brothers;
  final int? sisters;
  final String? familyStatus;
  final String? familyType;
  final String? familyValues;
  final String? annualIncome;
  final String? familyLocation;

  final String? highestEducation;
  final String? educationalDetails;
  final String? employedIn;
  final String? personalIncome;
  final String? workingSector;
  final String? workingLocation;

  final String? eatingHabits;
  final String? smokingHabits;
  final String? drinkingHabits;
  final String? community;
  final String? subCommunity;
  final String? manglikStatus;
  final String? appearance;
  final String? livingStatus;
  final String? physicalStatus;
  final List<String>? hobbies;

  final String? propertyType;
  final String? landArea;
  final List<String>? landTypes;
  final List<String>? houseTypes;
  final List<String>? businessTypes;
  final String? propertyPossessionType;

  final String? connectionStatus;
  final String? photoRequestStatus;
  final String? profileManagedBy;
  final String? lastSeen;

  final String? role;
  final String? vendorStatus;
  final Map<String, dynamic>? vendorDetails;
  final String? email;
  final String? phone;
  final int? experienceYears;
  final double? averageRating;
  final int? reviewCount;
  final List<Map<String, dynamic>>? products;

  FeedUser({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.profilePhoto,
    this.photos = const [],
    this.aboutMe,
    this.dob,
    this.ageFromApi,
    this.city,
    this.state,
    this.country,
    this.occupation,
    this.religion,
    this.gender,
    this.height,
    this.maritalStatus,
    this.motherTongue,
    this.fatherStatus,
    this.motherStatus,
    this.brothers,
    this.sisters,
    this.familyStatus,
    this.familyType,
    this.familyValues,
    this.annualIncome,
    this.familyLocation,
    this.highestEducation,
    this.educationalDetails,
    this.employedIn,
    this.personalIncome,
    this.workingSector,
    this.workingLocation,
    this.eatingHabits,
    this.smokingHabits,
    this.drinkingHabits,
    this.community,
    this.subCommunity,
    this.manglikStatus,
    this.appearance,
    this.livingStatus,
    this.physicalStatus,
    this.hobbies,
    this.propertyType,
    this.landArea,
    this.landTypes,
    this.houseTypes,
    this.businessTypes,
    this.propertyPossessionType,
    this.connectionStatus,
    this.photoRequestStatus,
    this.profileManagedBy,
    this.lastSeen,
    this.role,
    this.vendorStatus,
    this.vendorDetails,
    this.email,
    this.phone,
    this.experienceYears,
    this.averageRating,
    this.reviewCount,
    this.products,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? username;
  }

  int? get age {
    if (ageFromApi != null) return ageFromApi;

    if (dob == null) return null;
    try {
      final birthDate = DateTime.parse(dob!);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  String? get location {
    final parts = <String>[];
    if (city != null) parts.add(city!);
    if (state != null) parts.add(state!);
    if (country != null) parts.add(country!);
    return parts.isEmpty ? null : parts.join(', ');
  }

  String getActivityStatus() {
    if (lastSeen == null) return 'Active recently';

    try {
      final lastSeenDate = DateTime.parse(lastSeen!);
      final now = DateTime.now();
      final difference = now.difference(lastSeenDate);

      if (difference.inHours < 24) {
        return 'Active today';
      } else if (difference.inDays == 1) {
        return 'Active yesterday';
      } else if (difference.inDays < 7) {
        return 'Active this week';
      } else if (difference.inDays < 30) {
        return 'Active recently';
      } else {
        return 'Active a while ago';
      }
    } catch (e) {
      return 'Active recently';
    }
  }

  String? get businessName => vendorDetails?['business_name'];
  String? get businessAddress => vendorDetails?['business_address'];
  String? get serviceType => vendorDetails?['service_type'];
  String? get product => vendorDetails?['product'];
  String? get priceRange => vendorDetails?['price_range'];
  String? get description => vendorDetails?['description'];
  String? get pincode => vendorDetails?['pincode'];
  String? get workingHours => vendorDetails?['working_hours'];
  String? get paymentTerms => vendorDetails?['payment_terms'];
  String? get embeddedMapLink => vendorDetails?['embedded_map_link'];
  String? get mapLink => vendorDetails?['map_link'];
  Map<String, dynamic>? get socialLinks =>
      vendorDetails?['social_links'] as Map<String, dynamic>?;
  Map<String, dynamic>? get bankDetails =>
      vendorDetails?['bank_details'] as Map<String, dynamic>?;

  factory FeedUser.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 [FeedUser.fromJson] Parsing user: ${json['username']}');
    debugPrint('🔍 [FeedUser.fromJson] Role: ${json['role']}');
    debugPrint(
      '🔍 [FeedUser.fromJson] Vendor Status: ${json['vendor_status']}',
    );
    debugPrint(
      '🔍 [FeedUser.fromJson] Vendor Details: ${json['vendor_details']}',
    );
    debugPrint('🔍 [FeedUser.fromJson] Photos in JSON: ${json['photos']}');
    debugPrint(
      '🎓 [FeedUser.fromJson] Education - highestEducation: ${json['highestEducation']}, highest_education: ${json['highest_education']}, education: ${json['education']}',
    );
    debugPrint(
      '💰 [FeedUser.fromJson] Income - annualIncome: ${json['annualIncome']}, annual_income: ${json['annual_income']}, income: ${json['income']}',
    );
    debugPrint(
      '💼 [FeedUser.fromJson] Occupation - occupation: ${json['occupation']}, workingSector: ${json['workingSector']}, working_sector: ${json['working_sector']}',
    );
    debugPrint(
      '👤 [FeedUser.fromJson] ProfileManagedBy - profileManagedBy: ${json['profileManagedBy']}, profile_managed_by: ${json['profile_managed_by']}, created_for: ${json['created_for']}, createdFor: ${json['createdFor']}',
    );
    debugPrint(
      '⏰ [FeedUser.fromJson] LastSeen - lastSeen: ${json['lastSeen']}, last_seen: ${json['last_seen']}',
    );

    final photos =
        (json['photos'] as List<dynamic>?)
            ?.map((p) => Photo.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    debugPrint('🔍 [FeedUser.fromJson] Parsed ${photos.length} photos');

    return FeedUser(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      firstName: json['firstName'] ?? json['first_name'] ?? json['firstname'],
      lastName: json['lastName'] ?? json['last_name'] ?? json['lastname'],
      profilePhoto:
          json['profilePhoto'] ?? json['profile_photo'] ?? json['profilephoto'],
      photos: photos,
      aboutMe:
          json['aboutMe'] ?? json['about_me'] ?? json['bio'] ?? json['aboutme'],
      dob: json['dob'] ?? json['dateOfBirth'] ?? json['date_of_birth'],
      ageFromApi: json['age'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      occupation:
          json['occupation'] ??
          json['workingSector'] ??
          json['working_sector'] ??
          json['employedIn'] ??
          json['employed_in'],
      religion: json['religion'],
      gender: json['gender'],
      height: json['height'],
      maritalStatus:
          json['maritalStatus'] ??
          json['marital_status'] ??
          json['maritalstatus'],
      motherTongue:
          json['motherTongue'] ?? json['mother_tongue'] ?? json['mothertongue'],
      fatherStatus:
          json['fatherStatus'] ?? json['father_status'] ?? json['fatherstatus'],
      motherStatus:
          json['motherStatus'] ?? json['mother_status'] ?? json['motherstatus'],
      brothers: json['brothers'],
      sisters: json['sisters'],
      familyStatus:
          json['familyStatus'] ?? json['family_status'] ?? json['familystatus'],
      familyType:
          json['familyType'] ?? json['family_type'] ?? json['familytype'],
      familyValues:
          json['familyValues'] ?? json['family_values'] ?? json['familyvalues'],
      annualIncome:
          json['annualIncome'] ??
          json['annual_income'] ??
          json['income'] ??
          json['personalIncome'] ??
          json['personal_income'],
      familyLocation:
          json['familyLocation'] ??
          json['family_location'] ??
          json['familylocation'],
      highestEducation:
          json['highestEducation'] ??
          json['highest_education'] ??
          json['education'] ??
          json['highesteducation'],
      educationalDetails:
          json['educationalDetails'] ??
          json['educational_details'] ??
          json['educationdetails'] ??
          json['educationDetails'],
      employedIn:
          json['employedIn'] ?? json['employed_in'] ?? json['employedin'],
      personalIncome:
          json['personalIncome'] ??
          json['personal_income'] ??
          json['personalincome'],
      workingSector:
          json['workingSector'] ??
          json['working_sector'] ??
          json['workingsector'],
      workingLocation:
          json['workingLocation'] ??
          json['working_location'] ??
          json['workinglocation'],
      eatingHabits:
          json['eatingHabits'] ?? json['eating_habits'] ?? json['eatinghabits'],
      smokingHabits:
          json['smokingHabits'] ??
          json['smoking_habits'] ??
          json['smokinghabits'],
      drinkingHabits:
          json['drinkingHabits'] ??
          json['drinking_habits'] ??
          json['drinkinghabits'],
      community: json['community'],
      subCommunity:
          json['subCommunity'] ?? json['sub_community'] ?? json['subcommunity'],
      manglikStatus:
          json['manglikStatus'] ??
          json['manglik_status'] ??
          json['manglikstatus'],
      appearance: json['appearance'],
      livingStatus:
          json['livingStatus'] ?? json['living_status'] ?? json['livingstatus'],
      physicalStatus:
          json['physicalStatus'] ??
          json['physical_status'] ??
          json['physicalstatus'],
      hobbies: (json['hobbies'] as List<dynamic>?)?.cast<String>(),
      propertyType:
          json['propertyType'] ?? json['property_type'] ?? json['propertytype'],
      landArea: json['landArea'] ?? json['land_area'] ?? json['landarea'],
      landTypes:
          (json['landTypes'] as List<dynamic>?)?.cast<String>() ??
          (json['land_types'] as List<dynamic>?)?.cast<String>(),
      houseTypes:
          (json['houseTypes'] as List<dynamic>?)?.cast<String>() ??
          (json['house_types'] as List<dynamic>?)?.cast<String>(),
      businessTypes:
          (json['businessTypes'] as List<dynamic>?)?.cast<String>() ??
          (json['business_types'] as List<dynamic>?)?.cast<String>(),
      propertyPossessionType:
          json['propertyPossessionType'] ??
          json['property_possession_type'] ??
          json['propertypossessiontype'],
      connectionStatus: json['connectionStatus'] ?? json['connection_status'],
      photoRequestStatus:
          json['photoRequestStatus'] ?? json['photo_request_status'],
      profileManagedBy:
          json['profileManagedBy'] ??
          json['profile_managed_by'] ??
          json['created_for'] ??
          json['createdFor'] ??
          json['profilemanagedby'] ??
          json['managedBy'] ??
          json['managed_by'],
      lastSeen: json['lastSeen'] ?? json['last_seen'] ?? json['lastseen'],
      role: json['role'],
      vendorStatus:
          json['vendor_status'] ?? json['vendorStatus'] ?? json['vendorstatus'],
      vendorDetails: json['vendor_details'] as Map<String, dynamic>?,
      email: json['email'],
      phone: json['phone'],
      experienceYears:
          json['experience_years'] ??
          json['experienceYears'] ??
          json['experienceyears'] ??
          (json['vendor_details']
              as Map<String, dynamic>?)?['experience_years'],
      averageRating: _parseDouble(
        (json['vendor_details'] as Map<String, dynamic>?)?['averageRating'] ??
            json['averageRating'] ??
            json['average_rating'],
      ),
      reviewCount:
          (json['vendor_details'] as Map<String, dynamic>?)?['reviewCount'] ??
          json['reviewCount'] ??
          json['review_count'],
      products: (json['products'] as List<dynamic>?)
          ?.map((p) => p as Map<String, dynamic>)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'profilePhoto': profilePhoto,
      'photos': photos.map((p) => p.toJson()).toList(),
      'about_me': aboutMe,
      'dob': dob,
      'age': ageFromApi,
      'city': city,
      'state': state,
      'country': country,
      'occupation': occupation,
      'religion': religion,
      'gender': gender,
      'height': height,
      'marital_status': maritalStatus,
      'mother_tongue': motherTongue,
      'father_status': fatherStatus,
      'mother_status': motherStatus,
      'brothers': brothers,
      'sisters': sisters,
      'family_status': familyStatus,
      'family_type': familyType,
      'family_values': familyValues,
      'annual_income': annualIncome,
      'family_location': familyLocation,
      'highest_education': highestEducation,
      'educational_details': educationalDetails,
      'employed_in': employedIn,
      'personal_income': personalIncome,
      'working_sector': workingSector,
      'working_location': workingLocation,
      'eating_habits': eatingHabits,
      'smoking_habits': smokingHabits,
      'drinking_habits': drinkingHabits,
      'community': community,
      'sub_community': subCommunity,
      'manglik_status': manglikStatus,
      'appearance': appearance,
      'living_status': livingStatus,
      'physical_status': physicalStatus,
      'hobbies': hobbies,
      'property_type': propertyType,
      'land_area': landArea,
      'land_types': landTypes,
      'house_types': houseTypes,
      'business_types': businessTypes,
      'property_possession_type': propertyPossessionType,
      'connectionStatus': connectionStatus,
      'photoRequestStatus': photoRequestStatus,
      'profile_managed_by': profileManagedBy,
      'last_seen': lastSeen,
      'role': role,
      'vendor_status': vendorStatus,
      'vendor_details': vendorDetails,
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;

    try {
      final doubleValue = value is num
          ? value.toDouble()
          : double.tryParse(value.toString());
      if (doubleValue != null && doubleValue.isFinite) {
        return doubleValue;
      }
      return null;
    } catch (e) {
      debugPrint(
        '⚠️ [FeedUser] Failed to parse double value: $value, error: $e',
      );
      return null;
    }
  }
}
