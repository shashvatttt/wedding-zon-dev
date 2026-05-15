import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../features/vendor/providers/vendor_registration_provider.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/wz_toast.dart';

class VendorListingBankDetailsScreenUI extends StatefulWidget {
  const VendorListingBankDetailsScreenUI({super.key});

  @override
  State<VendorListingBankDetailsScreenUI> createState() =>
      _VendorListingBankDetailsScreenUIState();
}

class _VendorListingBankDetailsScreenUIState
    extends State<VendorListingBankDetailsScreenUI> {
  late TextEditingController _accountHolderController;
  late TextEditingController _accountNumberController;
  late TextEditingController _bankNameController;
  late TextEditingController _ifscController;
  late TextEditingController _upiController;
  late TextEditingController _linkedMobileController;
  late TextEditingController _gstinController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<VendorRegistrationProvider>();
    _accountHolderController = TextEditingController(
      text: provider.accountHolderName,
    );
    _accountNumberController = TextEditingController(
      text: provider.accountNumber,
    );
    _bankNameController = TextEditingController(text: provider.bankName);
    _ifscController = TextEditingController(text: provider.ifscCode);
    _upiController = TextEditingController(text: provider.upiId);
    _linkedMobileController = TextEditingController(
      text: provider.linkedMobileNumber,
    );
    _gstinController = TextEditingController(text: provider.gstin);

    _accountHolderController.addListener(() {
      provider.updateBankDetails(
        accountHolderName: _accountHolderController.text,
      );
    });
    _accountNumberController.addListener(() {
      provider.updateBankDetails(accountNumber: _accountNumberController.text);
    });
    _bankNameController.addListener(() {
      provider.updateBankDetails(bankName: _bankNameController.text);
    });
    _ifscController.addListener(() {
      provider.updateBankDetails(ifscCode: _ifscController.text);
    });
    _upiController.addListener(() {
      provider.updateBankDetails(upiId: _upiController.text);
    });
    _linkedMobileController.addListener(() {
      provider.updateBankDetails(
        linkedMobileNumber: _linkedMobileController.text,
      );
    });
    _gstinController.addListener(() {
      provider.updateBankDetails(gstin: _gstinController.text);
    });
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    _linkedMobileController.dispose();
    _gstinController.dispose();
    super.dispose();
  }

  void _onVerifyIFSC() {
    WzToast.show(
      context,
      message: 'IFSC verification simulated',
      type: WzToastType.success,
    );
  }

  void _onNext() {
    Navigator.pushNamed(context, '/ui-clone/vendor-listing-working-details');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Consumer<VendorRegistrationProvider>(
          builder: (context, provider, _) {
            final l10n = AppLocalizations.of(context)!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vendor Listing',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Bank Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          hint: 'Account Holder Name',
                          controller: _accountHolderController,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          hint: 'Account Number',
                          controller: _accountNumberController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(18),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          hint: 'Bank Name',
                          controller: _bankNameController,
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                hint: 'IFSC Code',
                                controller: _ifscController,
                                textCapitalization:
                                    TextCapitalization.characters,
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: _onVerifyIFSC,
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: WzColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: WzColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'Verify',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildDropdown(
                          value: provider.accountType.isEmpty
                              ? null
                              : provider.accountType,
                          hint: 'Account Type',
                          items: const ['Savings', 'Current', 'Salary'],
                          onChanged: (val) => provider.updateBankDetails(
                            accountType: val ?? '',
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          hint: 'UPI ID',
                          controller: _upiController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '+91',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 20,
                                    color: Color(0xFF6B7280),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                hint: 'Linked Mobile Number',
                                controller: _linkedMobileController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          hint: 'GSTIN',
                          controller: _gstinController,
                          textCapitalization: TextCapitalization.characters,
                        ),
                        const SizedBox(height: 48),

                        Center(
                          child: GestureDetector(
                            onTap: _onNext,
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                              ),
                              decoration: BoxDecoration(
                                color: WzColors.primary,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: WzColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Color(0xFF111827),
        ),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? hint,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: hint != null
              ? Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9CA3AF),
                  ),
                )
              : null,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Color(0xFF6B7280),
          ),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF111827),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
