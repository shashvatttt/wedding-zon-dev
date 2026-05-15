import 'package:flutter/foundation.dart';
import 'photo_model.dart';
import '../../features/franchise/models/franchise_details.dart';
import '../../features/vendor/models/vendor_details.dart';
import '../../features/profile/models/partner_preference.dart';

class User {
  final String id;
  final String? username;
  final String? email;
  final String? phone;
  final String? authProvider;
  final String? role;
  final String? adminRole;
  final bool isPhoneVerified;
  final bool isProfileComplete;
  final String? status;

  final String? firstName;
  final String? lastName;
  final DateTime? dob;
  final String? gender;
  final String? createdFor;
  final String? height;
  final String? maritalStatus;
  final String? profileManagedBy;
  final String? motherTongue;
  final String? disability;
  final String? disabilityDescription;
  final String? aadharNumber;
  final String? bloodGroup;

  final String? country;
  final String? state;
  final String? city;
  final String? placeOfBirth;

  final String? fatherName;
  final String? motherName;
  final String? fatherOccupation;
  final String? motherOccupation;
  final String? fatherStatus;
  final String? motherStatus;
  final int? brothers;
  final int? sisters;
  final String? familyStatus;
  final String? familyType;
  final String? familyValues;
  final String? annualIncome;
  final String? familyLocation;
  final String? liveWithFamily;

  final String? highestEducation;
  final String? collegeName;
  final String? educationalDetails;
  final String? occupation;
  final String? employedIn;
  final String? personalIncome;
  final String? workingSector;
  final String? workingLocation;

  final String? religion;
  final String? manglikStatus;
  final String? community;
  final String? subCommunity;
  final String? appearance;
  final String? livingStatus;
  final String? physicalStatus;
  final String? eatingHabits;
  final String? smokingHabits;
  final String? drinkingHabits;
  final List<String> hobbies;

  final String? landArea;
  final String? propertyType;
  final List<String>? propertyTypes;
  final List<String>? landTypes;
  final List<String>? houseTypes;
  final String? propertyPossessionType;
  final List<String>? businessTypes;

  final String? franchiseStatus;
  final FranchiseDetails? franchiseDetails;

  final String? vendorStatus;
  final VendorDetails? vendorDetails;

  final PartnerPreference? partnerPreferences;

  final String? alternateMobile;
  final String? suitableTimeToCall;

  final String? aboutMe;
  final String? profilePhoto;
  final List<Photo> photos;

  final double? latitude;
  final double? longitude;

  User({
    required this.id,
    this.username,
    this.email,
    this.phone,
    this.authProvider,
    this.role,
    this.adminRole,
    this.isPhoneVerified = false,
    this.isProfileComplete = false,
    this.status,
    this.firstName,
    this.lastName,
    this.dob,
    this.gender,
    this.createdFor,
    this.height,
    this.maritalStatus,
    this.motherTongue,
    this.disability,
    this.disabilityDescription,
    this.aadharNumber,
    this.bloodGroup,
    this.country,
    this.state,
    this.city,
    this.fatherName,
    this.motherName,
    this.fatherOccupation,
    this.motherOccupation,
    this.fatherStatus,
    this.motherStatus,
    this.brothers,
    this.sisters,
    this.familyStatus,
    this.familyType,
    this.familyValues,
    this.placeOfBirth,
    this.manglikStatus,
    this.annualIncome,
    this.familyLocation,
    this.liveWithFamily,
    this.highestEducation,
    this.collegeName,
    this.educationalDetails,
    this.occupation,
    this.employedIn,
    this.personalIncome,
    this.workingSector,
    this.workingLocation,
    this.religion,
    this.community,
    this.subCommunity,
    this.appearance,
    this.livingStatus,
    this.physicalStatus,
    this.eatingHabits,
    this.smokingHabits,
    this.drinkingHabits,
    this.hobbies = const [],
    this.landArea,
    this.propertyType,
    this.propertyTypes,
    this.landTypes,
    this.houseTypes,
    this.propertyPossessionType,
    this.businessTypes,
    this.franchiseStatus,
    this.franchiseDetails,
    this.vendorStatus,
    this.vendorDetails,
    this.partnerPreferences,
    this.alternateMobile,
    this.suitableTimeToCall,
    this.profileManagedBy,
    this.aboutMe,
    this.profilePhoto,
    this.photos = const [],
    this.latitude,
    this.longitude,
  });

  String? get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName;
  }

  String? get name => fullName;
  String? get phoneNumber => phone;

  factory User.fromJson(Map<String, dynamic> json) {
    if (json['_id'] != null) {
      debugPrint('[USER_MODEL] 🔵 Parsing user: ${json['_id']}');
    }

    final photos =
        (json['photos'] as List?)?.map((p) {
          return Photo.fromJson(p);
        }).toList() ??
        [];

    final latitude =
        json['location'] != null &&
            json['location']['coordinates'] is List &&
            json['location']['coordinates'].length == 2
        ? (json['location']['coordinates'][1] as num).toDouble()
        : null;

    final longitude =
        json['location'] != null &&
            json['location']['coordinates'] is List &&
            json['location']['coordinates'].length == 2
        ? (json['location']['coordinates'][0] as num).toDouble()
        : null;

    return User(
      id: json['_id'] ?? '',
      username: json['username'],
      email: json['email'],
      phone: json['phone']?.toString(),
      authProvider: json['auth_provider'],
      role: json['role'] is Map ? json['role']['type'] : json['role'],
      adminRole: json['admin_role'],
      isPhoneVerified: json['is_phone_verified'] ?? false,
      isProfileComplete: json['is_profile_complete'] ?? false,
      status: json['status'] is Map ? json['status']['type'] : json['status'],

      firstName: json['first_name'],
      lastName: json['last_name'],
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      gender: json['gender'],
      createdFor: json['created_for'],
      height: json['height'],
      maritalStatus: json['marital_status'],
      motherTongue: json['mother_tongue'],
      bloodGroup: json['blood_group'],
      aadharNumber: json['aadhar_number'],

      disability: json['disability']?.toString(),
      disabilityDescription: json['disability_description'],

      country: json['country'],
      state: json['state'],
      city: json['city'],

      fatherName: json['father_name'],
      motherName: json['mother_name'],
      fatherOccupation: json['father_occupation'],
      motherOccupation: json['mother_occupation'],
      fatherStatus: json['father_status'],
      motherStatus: json['mother_status'],
      brothers: _parseInt(json['brothers']),
      sisters: _parseInt(json['sisters']),
      familyStatus: json['family_status'],
      familyType: json['family_type'],
      familyValues: json['family_values'],
      annualIncome: json['annual_income'],
      familyLocation: json['family_location'],
      liveWithFamily: json['live_with_family'],
      placeOfBirth: json['place_of_birth'],
      manglikStatus: json['manglik_status'],
      profileManagedBy: json['profile_managed_by'],
      alternateMobile: json['alternate_mobile'],

      highestEducation: json['highest_education'],
      collegeName: json['college_name'],
      educationalDetails: json['educational_details'],
      occupation: json['occupation'],
      employedIn: json['employed_in'],
      personalIncome: json['personal_income'],
      workingSector: json['working_sector'],
      workingLocation: json['working_location'],

      religion: json['religion'],
      community: json['community'],
      subCommunity: json['sub_community'],
      appearance: json['appearance'],
      livingStatus: json['living_status'],
      physicalStatus: json['physical_status'],
      eatingHabits: json['eating_habits'],
      smokingHabits: json['smoking_habits'],
      drinkingHabits: json['drinking_habits'],
      hobbies: _parseList(json['hobbies']) ?? const [],

      landArea: (json['land_area'] ?? json['landArea'])?.toString(),
      propertyType: json['property_type'],
      propertyTypes: _parseList(json['property_types']),
      landTypes: _parseList(json['land_types']),
      houseTypes: _parseList(json['house_types']),
      propertyPossessionType: json['property_possession_type'],
      businessTypes: _parseList(json['business_types']),

      franchiseStatus: json['franchise_status'],
      franchiseDetails: json['franchise_details'] != null
          ? FranchiseDetails.fromJson(json['franchise_details'])
          : null,

      vendorStatus: json['vendor_status'],
      vendorDetails: json['vendor_details'] != null
          ? VendorDetails.fromJson(json['vendor_details'])
          : null,

      partnerPreferences: json['partner_preferences'] != null
          ? PartnerPreference.fromJson(json['partner_preferences'])
          : null,

      suitableTimeToCall: json['suitable_time_to_call'],

      aboutMe: json['about_me'] ?? json['aboutMe'],
      profilePhoto: json['profilePhoto'] ?? json['profile_photo'],
      photos: photos,

      latitude: latitude,
      longitude: longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'auth_provider': authProvider,
      'role': role,
      'admin_role': adminRole,
      'is_phone_verified': isPhoneVerified,
      'is_profile_complete': isProfileComplete,
      'status': status,
      'first_name': firstName,
      'last_name': lastName,
      'dob': dob?.toIso8601String(),
      'gender': gender,
      'created_for': createdFor,
      'height': height,
      'marital_status': maritalStatus,
      'mother_tongue': motherTongue,
      'disability': disability,
      'disability_description': disabilityDescription,
      'aadhar_number': aadharNumber,
      'blood_group': bloodGroup,
      'country': country,
      'state': state,
      'city': city,
      'father_name': fatherName,
      'mother_name': motherName,
      'father_occupation': fatherOccupation,
      'mother_occupation': motherOccupation,
      'father_status': fatherStatus,
      'mother_status': motherStatus,
      'brothers': brothers,
      'sisters': sisters,
      'family_status': familyStatus,
      'family_type': familyType,
      'family_values': familyValues,
      'annual_income': annualIncome,
      'family_location': familyLocation,
      'live_with_family': liveWithFamily,
      'place_of_birth': placeOfBirth,
      'manglik_status': manglikStatus,
      'profile_managed_by': profileManagedBy,
      'alternate_mobile': alternateMobile,
      'highest_education': highestEducation,
      'college_name': collegeName,
      'educational_details': educationalDetails,
      'occupation': occupation,
      'employed_in': employedIn,
      'personal_income': personalIncome,
      'working_sector': workingSector,
      'working_location': workingLocation,
      'religion': religion,
      'community': community,
      'sub_community': subCommunity,
      'appearance': appearance,
      'living_status': livingStatus,
      'physical_status': physicalStatus,
      'eating_habits': eatingHabits,
      'smoking_habits': smokingHabits,
      'drinking_habits': drinkingHabits,
      'hobbies': hobbies,
      'land_area': landArea,
      'property_type': propertyType,
      'property_types': propertyTypes,
      'land_types': landTypes,
      'house_types': houseTypes,
      'property_possession_type': propertyPossessionType,
      'business_types': businessTypes,
      'suitable_time_to_call': suitableTimeToCall,
      'about_me': aboutMe,
      'profile_photo': profilePhoto,
      'photos': photos.map((p) => p.toJson()).toList(),
      'franchise_status': franchiseStatus,
      'franchise_details': franchiseDetails?.toJson(),
      'vendor_status': vendorStatus,
      'vendor_details': vendorDetails?.toJson(),
      'partner_preferences': partnerPreferences?.toJson(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? authProvider,
    String? role,
    String? adminRole,
    bool? isPhoneVerified,
    bool? isProfileComplete,
    String? status,
    String? firstName,
    String? lastName,
    DateTime? dob,
    String? gender,
    String? createdFor,
    String? height,
    String? maritalStatus,
    String? motherTongue,
    String? disability,
    String? disabilityDescription,
    String? bloodGroup,
    String? aadharNumber,
    String? country,
    String? state,
    String? city,
    String? fatherName,
    String? motherName,
    String? fatherOccupation,
    String? motherOccupation,
    String? fatherStatus,
    String? motherStatus,
    int? brothers,
    int? sisters,
    String? familyStatus,
    String? familyType,
    String? familyValues,
    String? placeOfBirth,
    String? manglikStatus,
    String? annualIncome,
    String? familyLocation,
    String? liveWithFamily,
    String? highestEducation,
    String? collegeName,
    String? educationalDetails,
    String? occupation,
    String? employedIn,
    String? personalIncome,
    String? workingSector,
    String? workingLocation,
    String? religion,
    String? community,
    String? subCommunity,
    String? appearance,
    String? livingStatus,
    String? physicalStatus,
    String? eatingHabits,
    String? smokingHabits,
    String? drinkingHabits,
    List<String>? hobbies,
    String? landArea,
    String? propertyType,
    List<String>? propertyTypes,
    List<String>? landTypes,
    List<String>? houseTypes,
    String? propertyPossessionType,
    List<String>? businessTypes,
    String? franchiseStatus,
    FranchiseDetails? franchiseDetails,
    String? vendorStatus,
    VendorDetails? vendorDetails,
    PartnerPreference? partnerPreferences,
    String? profileManagedBy,
    String? aboutMe,
    String? profilePhoto,
    List<Photo>? photos,
    double? latitude,
    double? longitude,
    String? alternateMobile,
    String? suitableTimeToCall,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      authProvider: authProvider ?? this.authProvider,
      role: role ?? this.role,
      adminRole: adminRole ?? this.adminRole,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      status: status ?? this.status,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      createdFor: createdFor ?? this.createdFor,
      height: height ?? this.height,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      motherTongue: motherTongue ?? this.motherTongue,
      disability: disability ?? this.disability,
      disabilityDescription:
          disabilityDescription ?? this.disabilityDescription,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      fatherOccupation: fatherOccupation ?? this.fatherOccupation,
      motherOccupation: motherOccupation ?? this.motherOccupation,
      fatherStatus: fatherStatus ?? this.fatherStatus,
      motherStatus: motherStatus ?? this.motherStatus,
      brothers: brothers ?? this.brothers,
      sisters: sisters ?? this.sisters,
      familyStatus: familyStatus ?? this.familyStatus,
      familyType: familyType ?? this.familyType,
      familyValues: familyValues ?? this.familyValues,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      manglikStatus: manglikStatus ?? this.manglikStatus,
      annualIncome: annualIncome ?? this.annualIncome,
      familyLocation: familyLocation ?? this.familyLocation,
      liveWithFamily: liveWithFamily ?? this.liveWithFamily,
      highestEducation: highestEducation ?? this.highestEducation,
      collegeName: collegeName ?? this.collegeName,
      educationalDetails: educationalDetails ?? this.educationalDetails,
      occupation: occupation ?? this.occupation,
      employedIn: employedIn ?? this.employedIn,
      personalIncome: personalIncome ?? this.personalIncome,
      workingSector: workingSector ?? this.workingSector,
      workingLocation: workingLocation ?? this.workingLocation,
      religion: religion ?? this.religion,
      community: community ?? this.community,
      subCommunity: subCommunity ?? this.subCommunity,
      appearance: appearance ?? this.appearance,
      livingStatus: livingStatus ?? this.livingStatus,
      physicalStatus: physicalStatus ?? this.physicalStatus,
      eatingHabits: eatingHabits ?? this.eatingHabits,
      smokingHabits: smokingHabits ?? this.smokingHabits,
      drinkingHabits: drinkingHabits ?? this.drinkingHabits,
      hobbies: hobbies ?? this.hobbies,
      landArea: landArea ?? this.landArea,
      propertyType: propertyType ?? this.propertyType,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      landTypes: landTypes ?? this.landTypes,
      houseTypes: houseTypes ?? this.houseTypes,
      propertyPossessionType:
          propertyPossessionType ?? this.propertyPossessionType,
      businessTypes: businessTypes ?? this.businessTypes,
      franchiseStatus: franchiseStatus ?? this.franchiseStatus,
      franchiseDetails: franchiseDetails ?? this.franchiseDetails,
      vendorStatus: vendorStatus ?? this.vendorStatus,
      vendorDetails: vendorDetails ?? this.vendorDetails,
      partnerPreferences: partnerPreferences ?? this.partnerPreferences,
      profileManagedBy: profileManagedBy ?? this.profileManagedBy,
      aboutMe: aboutMe ?? this.aboutMe,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      photos: photos ?? this.photos,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      alternateMobile: alternateMobile ?? this.alternateMobile,
      suitableTimeToCall: suitableTimeToCall ?? this.suitableTimeToCall,
    );
  }

  static int? _parseInt(dynamic value) {
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
}
