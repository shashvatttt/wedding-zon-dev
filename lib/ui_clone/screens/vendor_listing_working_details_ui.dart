import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/vendor/providers/vendor_registration_provider.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/localization/app_localizations.dart';

class VendorListingWorkingDetailsScreenUI extends StatefulWidget {
  const VendorListingWorkingDetailsScreenUI({super.key});

  @override
  State<VendorListingWorkingDetailsScreenUI> createState() =>
      _VendorListingWorkingDetailsScreenUIState();
}

class _VendorListingWorkingDetailsScreenUIState
    extends State<VendorListingWorkingDetailsScreenUI> {
  late TextEditingController _workingHoursController;
  late TextEditingController _paymentTermsController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<VendorRegistrationProvider>();
    _workingHoursController = TextEditingController(
      text: provider.workingHours,
    );
    _paymentTermsController = TextEditingController(
      text: provider.paymentTerms,
    );
    _descriptionController = TextEditingController(text: provider.description);

    _workingHoursController.addListener(() {
      provider.updateWorkingDetails(workingHours: _workingHoursController.text);
    });
    _paymentTermsController.addListener(() {
      provider.updateWorkingDetails(paymentTerms: _paymentTermsController.text);
    });
    _descriptionController.addListener(() {
      provider.updateWorkingDetails(description: _descriptionController.text);
    });
  }

  @override
  void dispose() {
    _workingHoursController.dispose();
    _paymentTermsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onNext() {
    Navigator.pushNamed(context, '/ui-clone/vendor-listing-social-links');
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

                  Center(
                    child: Text(
                      l10n.appName,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: WzColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.vendorListing,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.workingDetails,
                          style: const TextStyle(
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
                          hint: l10n.workingHours,
                          controller: _workingHoursController,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          hint: l10n.paymentTerms,
                          controller: _paymentTermsController,
                        ),
                        const SizedBox(height: 24),

                        Text(
                          l10n.description,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          height: 137,
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
                          child: TextField(
                            controller: _descriptionController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF111827),
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.workDescriptionHint,
                              hintStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF9CA3AF),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 120),

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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.next,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
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
}
