class FranchiseDetails {
  final String? businessName;
  final String? gstNumber;
  final String? businessAddress;
  final String? city;
  final String? state;
  final String? pincode;

  final String? contactPersonName;
  final int? yearsAsFranchise;
  final String? priceRange;
  final String? googleMapLink;
  final String? country;

  final String? accountHolderName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? accountType;
  final String? upiId;

  final String? instagramLink;
  final String? youtubeLink;
  final String? facebookLink;
  final String? twitterLink;

  final String? startingPrice;
  final String? description;

  FranchiseDetails({
    this.businessName,
    this.gstNumber,
    this.businessAddress,
    this.city,
    this.state,
    this.pincode,
    this.contactPersonName,
    this.yearsAsFranchise,
    this.priceRange,
    this.googleMapLink,
    this.country,
    this.accountHolderName,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.accountType,
    this.upiId,
    this.instagramLink,
    this.youtubeLink,
    this.facebookLink,
    this.twitterLink,
    this.startingPrice,
    this.description,
  });

  factory FranchiseDetails.fromJson(Map<String, dynamic> json) {
    return FranchiseDetails(
      businessName: json['business_name'] ?? json['businessName'],
      gstNumber: json['gst_number'] ?? json['gstNumber'],
      businessAddress: json['business_address'] ?? json['businessAddress'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'] ?? json['pin_code'],

      contactPersonName: json['contact_person_name'],
      yearsAsFranchise: json['years_as_franchise'] is String
          ? int.tryParse(json['years_as_franchise'])
          : json['years_as_franchise'],
      priceRange: json['price_range'],
      googleMapLink: json['google_map_link'],
      country: json['country'],

      accountHolderName: json['account_holder_name'],
      bankName: json['bank_name'],
      accountNumber: json['account_number'],
      ifscCode: json['ifsc_code'],
      accountType: json['account_type'],
      upiId: json['upi_id'],

      instagramLink: json['instagram_link'],
      youtubeLink: json['youtube_link'],
      facebookLink: json['facebook_link'],
      twitterLink: json['twitter_link'],

      startingPrice: json['starting_price'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_name': businessName,
      'gst_number': gstNumber,
      'business_address': businessAddress,
      'city': city,
      'state': state,
      'pincode': pincode,

      'contact_person_name': contactPersonName,
      'years_as_franchise': yearsAsFranchise,
      'price_range': priceRange,
      'google_map_link': googleMapLink,
      'country': country,

      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'account_type': accountType,
      'upi_id': upiId,

      'instagram_link': instagramLink,
      'youtube_link': youtubeLink,
      'facebook_link': facebookLink,
      'twitter_link': twitterLink,

      'starting_price': startingPrice,
      'description': description,
    };
  }
}
