import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/vendor_repository.dart';

class VendorRegistrationProvider extends ChangeNotifier {
  final VendorRepository _repository;
  static const String _storageKey = 'vendor_registration_draft';

  VendorRegistrationProvider(this._repository) {
    _loadDraft();
  }

  bool _isLoading = false;
  String? _error;

  String name = '';
  String companyName = '';
  String aadharNumber = '';
  String email = '';
  String mobileNumber = '';
  String country = 'India';
  String state = '';
  String city = '';
  String address = '';
  String pinCode = '';
  String serviceType = '';
  String productType = '';
  String priceRangeStart = '10000';
  String priceRangeEnd = '50000';

  String accountHolderName = '';
  String accountNumber = '';
  String bankName = '';
  String ifscCode = '';
  String accountType = 'Savings';
  String upiId = '';
  String linkedMobileNumber = '';
  String gstin = '';

  String workingHours = '';
  String paymentTerms = '';
  String description = '';

  String instagramLink = '';
  String youtubeLink = '';
  String facebookLink = '';
  String twitterLink = '';
  String? profilePhoto;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateBasicDetails({
    String? name,
    String? companyName,
    String? aadharNumber,
    String? email,
    String? mobileNumber,
    String? country,
    String? state,
    String? city,
    String? address,
    String? pinCode,
    String? serviceType,
    String? productType,
    String? priceRangeStart,
    String? priceRangeEnd,
  }) {
    if (name != null) this.name = name;
    if (companyName != null) this.companyName = companyName;
    if (aadharNumber != null) this.aadharNumber = aadharNumber;
    if (email != null) this.email = email;
    if (mobileNumber != null) this.mobileNumber = mobileNumber;
    if (country != null) this.country = country;
    if (state != null) this.state = state;
    if (city != null) this.city = city;
    if (address != null) this.address = address;
    if (pinCode != null) this.pinCode = pinCode;
    if (serviceType != null) this.serviceType = serviceType;
    if (productType != null) this.productType = productType;
    if (priceRangeStart != null) this.priceRangeStart = priceRangeStart;
    if (priceRangeEnd != null) this.priceRangeEnd = priceRangeEnd;

    _saveDraft();
    notifyListeners();
  }

  void updateBankDetails({
    String? accountHolderName,
    String? accountNumber,
    String? bankName,
    String? ifscCode,
    String? accountType,
    String? upiId,
    String? linkedMobileNumber,
    String? gstin,
  }) {
    if (accountHolderName != null) this.accountHolderName = accountHolderName;
    if (accountNumber != null) this.accountNumber = accountNumber;
    if (bankName != null) this.bankName = bankName;
    if (ifscCode != null) this.ifscCode = ifscCode;
    if (accountType != null) this.accountType = accountType;
    if (upiId != null) this.upiId = upiId;
    if (linkedMobileNumber != null) {
      this.linkedMobileNumber = linkedMobileNumber;
    }
    if (gstin != null) this.gstin = gstin;

    _saveDraft();
    notifyListeners();
  }

  void updateWorkingDetails({
    String? workingHours,
    String? paymentTerms,
    String? description,
  }) {
    if (workingHours != null) this.workingHours = workingHours;
    if (paymentTerms != null) this.paymentTerms = paymentTerms;
    if (description != null) this.description = description;

    _saveDraft();
    notifyListeners();
  }

  void updateSocialLinks({
    String? instagram,
    String? youtube,
    String? facebook,
    String? twitter,
    String? photo,
  }) {
    if (instagram != null) instagramLink = instagram;
    if (youtube != null) youtubeLink = youtube;
    if (facebook != null) facebookLink = facebook;
    if (twitter != null) twitterLink = twitter;
    if (photo != null) profilePhoto = photo;

    _saveDraft();
    notifyListeners();
  }

  Future<void> _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'name': name,
        'companyName': companyName,
        'aadharNumber': aadharNumber,
        'email': email,
        'mobileNumber': mobileNumber,
        'country': country,
        'state': state,
        'city': city,
        'address': address,
        'pinCode': pinCode,
        'serviceType': serviceType,
        'productType': productType,
        'priceRangeStart': priceRangeStart,
        'priceRangeEnd': priceRangeEnd,
        'accountHolderName': accountHolderName,
        'accountNumber': accountNumber,
        'bankName': bankName,
        'ifscCode': ifscCode,
        'accountType': accountType,
        'upiId': upiId,
        'linkedMobileNumber': linkedMobileNumber,
        'gstin': gstin,
        'workingHours': workingHours,
        'paymentTerms': paymentTerms,
        'description': description,
        'instagramLink': instagramLink,
        'youtubeLink': youtubeLink,
        'facebookLink': facebookLink,
        'twitterLink': twitterLink,
        'profilePhoto': profilePhoto,
      };
      await prefs.setString(_storageKey, jsonEncode(data));
      debugPrint('[VENDOR_REG] 💾 Draft saved');
    } catch (e) {
      debugPrint('[VENDOR_REG] ⚠️ Failed to save draft: $e');
    }
  }

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        name = data['name'] ?? '';
        companyName = data['companyName'] ?? '';
        aadharNumber = data['aadharNumber'] ?? '';
        email = data['email'] ?? '';
        mobileNumber = data['mobileNumber'] ?? '';
        country = data['country'] ?? 'India';
        state = data['state'] ?? '';
        city = data['city'] ?? '';
        address = data['address'] ?? '';
        pinCode = data['pinCode'] ?? '';
        serviceType = data['serviceType'] ?? '';
        productType = data['productType'] ?? '';
        priceRangeStart = data['priceRangeStart'] ?? '10000';
        priceRangeEnd = data['priceRangeEnd'] ?? '50000';

        accountHolderName = data['accountHolderName'] ?? '';
        accountNumber = data['accountNumber'] ?? '';
        bankName = data['bankName'] ?? '';
        ifscCode = data['ifscCode'] ?? '';
        accountType = data['accountType'] ?? 'Savings';
        upiId = data['upiId'] ?? '';
        linkedMobileNumber = data['linkedMobileNumber'] ?? '';
        gstin = data['gstin'] ?? '';

        workingHours = data['workingHours'] ?? '';
        paymentTerms = data['paymentTerms'] ?? '';
        description = data['description'] ?? '';

        instagramLink = data['instagramLink'] ?? '';
        youtubeLink = data['youtubeLink'] ?? '';
        facebookLink = data['facebookLink'] ?? '';
        twitterLink = data['twitterLink'] ?? '';
        profilePhoto = data['profilePhoto'];

        notifyListeners();
        debugPrint('[VENDOR_REG] 📂 Draft loaded');
      }
    } catch (e) {
      debugPrint('[VENDOR_REG] ⚠️ Failed to load draft: $e');
    }
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);

    name = '';
    companyName = '';
    aadharNumber = '';
    email = '';
    mobileNumber = '';
    country = 'India';
    state = '';
    city = '';
    address = '';
    pinCode = '';
    serviceType = '';
    productType = '';
    priceRangeStart = '10000';
    priceRangeEnd = '50000';
    accountHolderName = '';
    accountNumber = '';
    bankName = '';
    ifscCode = '';
    accountType = 'Savings';
    upiId = '';
    linkedMobileNumber = '';
    gstin = '';
    workingHours = '';
    paymentTerms = '';
    description = '';
    instagramLink = '';
    youtubeLink = '';
    facebookLink = '';
    twitterLink = '';
    profilePhoto = null;
    notifyListeners();
  }

  Future<bool> submitRegistration() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('');
      debugPrint(
        '╔════════════════════════════════════════════════════════════╗',
      );
      debugPrint(
        '║ [VENDOR_PROVIDER] 📋 PREPARING REGISTRATION DATA           ║',
      );
      debugPrint(
        '╚════════════════════════════════════════════════════════════╝',
      );

      debugPrint('[VENDOR_PROVIDER] 👤 Basic Details:');
      debugPrint('[VENDOR_PROVIDER]    name: "$name"');
      debugPrint('[VENDOR_PROVIDER]    companyName: "$companyName"');
      debugPrint('[VENDOR_PROVIDER]    aadharNumber: "$aadharNumber"');
      debugPrint('[VENDOR_PROVIDER]    email: "$email"');
      debugPrint('[VENDOR_PROVIDER]    mobileNumber: "$mobileNumber"');
      debugPrint('[VENDOR_PROVIDER]    country: "$country"');
      debugPrint('[VENDOR_PROVIDER]    state: "$state"');
      debugPrint('[VENDOR_PROVIDER]    city: "$city"');
      debugPrint('[VENDOR_PROVIDER]    address: "$address"');
      debugPrint('[VENDOR_PROVIDER]    pinCode: "$pinCode"');
      debugPrint('[VENDOR_PROVIDER]    serviceType: "$serviceType"');
      debugPrint('[VENDOR_PROVIDER]    productType: "$productType"');
      debugPrint(
        '[VENDOR_PROVIDER]    priceRange: "$priceRangeStart-$priceRangeEnd"',
      );

      debugPrint('[VENDOR_PROVIDER] 🏦 Bank Details:');
      debugPrint(
        '[VENDOR_PROVIDER]    accountHolderName: "$accountHolderName"',
      );
      debugPrint('[VENDOR_PROVIDER]    accountNumber: "$accountNumber"');
      debugPrint('[VENDOR_PROVIDER]    bankName: "$bankName"');
      debugPrint('[VENDOR_PROVIDER]    ifscCode: "$ifscCode"');
      debugPrint('[VENDOR_PROVIDER]    accountType: "$accountType"');
      debugPrint('[VENDOR_PROVIDER]    upiId: "$upiId"');
      debugPrint(
        '[VENDOR_PROVIDER]    linkedMobileNumber: "$linkedMobileNumber"',
      );
      debugPrint('[VENDOR_PROVIDER]    gstin: "$gstin"');

      debugPrint('[VENDOR_PROVIDER] 💼 Working Details:');
      debugPrint('[VENDOR_PROVIDER]    workingHours: "$workingHours"');
      debugPrint('[VENDOR_PROVIDER]    paymentTerms: "$paymentTerms"');
      debugPrint('[VENDOR_PROVIDER]    description: "$description"');

      debugPrint('[VENDOR_PROVIDER] 🔗 Social Links:');
      debugPrint('[VENDOR_PROVIDER]    instagram: "$instagramLink"');
      debugPrint('[VENDOR_PROVIDER]    youtube: "$youtubeLink"');
      debugPrint('[VENDOR_PROVIDER]    facebook: "$facebookLink"');
      debugPrint('[VENDOR_PROVIDER]    twitter: "$twitterLink"');
      debugPrint('[VENDOR_PROVIDER]    profilePhoto: "$profilePhoto"');

      String? uploadedPhotoUrl;
      if (profilePhoto != null && profilePhoto!.isNotEmpty) {
        debugPrint('[VENDOR_PROVIDER] 📸 Uploading profile photo...');
        uploadedPhotoUrl = await _repository.uploadImage(profilePhoto!);
        debugPrint('[VENDOR_PROVIDER] ✅ Uploaded URL: $uploadedPhotoUrl');
      }

      final nameParts = name.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      final registrationData = {
        'role': 'vendor',
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': mobileNumber,
        'aadhar_number': aadharNumber,
        'city': city,
        'state': state,
        'country': country,
        'vendor_details': {
          'business_name': companyName,
          'business_address': address,
          'pincode': pinCode,
          'service_type': serviceType,
          'product': productType,
          'price_range': '$priceRangeStart-$priceRangeEnd',
          'description': description,
          'working_hours': workingHours,
          'payment_terms': paymentTerms,
          'bank_details': {
            'account_holder_name': accountHolderName,
            'account_number': accountNumber,
            'bank_name': bankName,
            'ifsc_code': ifscCode,
            'account_type': accountType,
            'upi_id': upiId,
            'linked_mobile_number': linkedMobileNumber,
            'gstin': gstin,
          },
          'social_links': {
            'instagram': instagramLink,
            'youtube': youtubeLink,
            'facebook': facebookLink,
            'twitter': twitterLink,
          },
        },
      };

      if (uploadedPhotoUrl != null) {
        registrationData['profile_photo'] = uploadedPhotoUrl;
      }

      debugPrint('');
      debugPrint('[VENDOR_PROVIDER] 📦 FINAL REGISTRATION DATA STRUCTURE:');
      debugPrint('[VENDOR_PROVIDER] ═══════════════════════════════════════');
      registrationData.forEach((key, value) {
        if (value is Map) {
          debugPrint('[VENDOR_PROVIDER] $key: {');
          value.forEach((k, v) {
            if (v is Map) {
              debugPrint('[VENDOR_PROVIDER]   $k: {');
              v.forEach((k2, v2) {
                debugPrint('[VENDOR_PROVIDER]     $k2: "$v2"');
              });
              debugPrint('[VENDOR_PROVIDER]   }');
            } else {
              debugPrint('[VENDOR_PROVIDER]   $k: "$v"');
            }
          });
          debugPrint('[VENDOR_PROVIDER] }');
        } else {
          debugPrint('[VENDOR_PROVIDER] $key: "$value"');
        }
      });
      debugPrint('[VENDOR_PROVIDER] ═══════════════════════════════════════');
      debugPrint('');

      await _repository.registerAsVendor(registrationData);

      await clearDraft();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
