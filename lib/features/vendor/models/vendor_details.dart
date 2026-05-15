import 'availability_entry.dart';

class VendorDetails {
  final String? name;
  final String? businessName;
  final String? email;
  final String? aadharNumber;
  final String? mobileNo;
  final String? priceRange;
  final String? businessAddress;
  final String? pincode;
  final String? serviceType;
  final String? product;
  final String? embeddedMapLink;
  final String? country;
  final String? state;

  final String? accountHolderName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? accountType;
  final String? upiId;
  final String? linkedMobileNumber;
  final String? gstin;

  final String? instagramLink;
  final String? facebookLink;
  final String? youtubeLink;
  final String? twitterLink;
  final String? businessGlance;

  final String? workingHours;
  final String? description;
  final num? experienceYears;

  final List<AvailabilityEntry> availability;

  VendorDetails({
    this.name,
    this.businessName,
    this.email,
    this.aadharNumber,
    this.mobileNo,
    this.priceRange,
    this.businessAddress,
    this.pincode,
    this.serviceType,
    this.product,
    this.embeddedMapLink,
    this.country,
    this.state,
    this.accountHolderName,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.accountType,
    this.upiId,
    this.linkedMobileNumber,
    this.gstin,
    this.instagramLink,
    this.facebookLink,
    this.youtubeLink,
    this.twitterLink,
    this.businessGlance,
    this.workingHours,
    this.description,
    this.experienceYears,
    this.availability = const [],
  });

  factory VendorDetails.fromJson(Map<String, dynamic> json) {
    final availabilityList =
        (json['availability'] as List?)
            ?.map((e) => AvailabilityEntry.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return VendorDetails(
      name: json['name'],
      businessName:
          json['business_name'] ?? json['businessName'] ?? json['company_name'],
      email: json['email'],
      aadharNumber: json['aadhar_number'],
      mobileNo: json['mobile_no'],
      priceRange: json['price_range'] ?? json['priceRange'],
      businessAddress: json['business_address'],
      pincode: json['pincode'],
      serviceType: json['service_type'] ?? json['serviceType'],
      product: json['product'],
      embeddedMapLink: json['embedded_map_link'],
      country: json['country'],
      state: json['state'],

      accountHolderName: json['account_holder_name'],
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      ifscCode: json['ifsc_code'],
      accountType: json['account_type'],
      upiId: json['upi_id'],
      linkedMobileNumber: json['linked_mobile_number'],
      gstin: json['gstin'],

      instagramLink: json['instagram_link'],
      facebookLink: json['facebook_link'],
      youtubeLink: json['youtube_link'],
      twitterLink: json['twitter_link'],
      businessGlance: json['business_glance'],

      workingHours: json['working_hours'],
      description: json['description'],
      experienceYears: json['experience_years'] ?? json['experienceYears'],
      availability: availabilityList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'business_name': businessName,
      'company_name': businessName,
      'email': email,
      'aadhar_number': aadharNumber,
      'mobile_no': mobileNo,
      'price_range': priceRange,
      'business_address': businessAddress,
      'pincode': pincode,
      'service_type': serviceType,
      'product': product,
      'embedded_map_link': embeddedMapLink,
      'country': country,
      'state': state,

      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'account_type': accountType,
      'upi_id': upiId,
      'linked_mobile_number': linkedMobileNumber,
      'gstin': gstin,

      'instagram_link': instagramLink,
      'facebook_link': facebookLink,
      'youtube_link': youtubeLink,
      'twitter_link': twitterLink,
      'business_glance': businessGlance,

      'working_hours': workingHours,
      'description': description,
      'experience_years': experienceYears,
      'availability': availability.map((e) => e.toJson()).toList(),
    };
  }
}
