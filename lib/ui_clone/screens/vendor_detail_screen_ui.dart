import 'package:flutter/material.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/theme/wz_text_styles.dart';
import '../widgets/wz_inputs.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';

class VendorDetailScreenUI extends StatelessWidget {
  const VendorDetailScreenUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 523,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFEF2F55), Color(0xFFF8F9FB)],
                        stops: [0.0, 0.718],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '9:30',
                          style: WzTextStyles.body1.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.wifi, size: 17),
                            const SizedBox(width: 6),
                            Icon(Icons.signal_cellular_alt, size: 17),
                            const SizedBox(width: 6),
                            Icon(Icons.battery_full, size: 17),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 84,
                    left: 24,
                    right: 24,
                    child: Container(
                      height: 323,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Icon(
                              Icons.share_outlined,
                              size: 24,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 42),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.translate('service_name'),
                          style: WzTextStyles.heading3.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (index) => Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)!.translate('location'),
                          style: WzTextStyles.body2.copyWith(fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          '8 ${AppLocalizations.of(context)!.translate('reviews')}',
                          style: WzTextStyles.body2.copyWith(
                            fontSize: 10,
                            color: const Color(0xFF707070),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 34),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('description'),
                      style: WzTextStyles.heading3.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Curabitur tempus urna at turpis condimentum lobortis.',
                      style: WzTextStyles.body2.copyWith(
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 34),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('gallery'),
                      style: WzTextStyles.heading3.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(
                        4,
                        (index) => Container(
                          width: 96,
                          height: 96,
                          margin: EdgeInsets.only(right: index < 3 ? 16 : 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 52),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('working_hours'),
                      style: WzTextStyles.heading3.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sunday - Saturday\n09:00 AM - 07:00 PM',
                      style: WzTextStyles.body2.copyWith(
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 34),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('availability'),
                      style: WzTextStyles.heading3.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD9D9D9)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.chevron_left),
                                onPressed: () {},
                              ),
                              Text(
                                'Sep 2025',
                                style: WzTextStyles.body1.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.chevron_right),
                                onPressed: () {},
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Text(
                            AppLocalizations.of(
                              context,
                            )!.translate('calendar_grid'),
                            style: WzTextStyles.body2.copyWith(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 34),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.translate('contact_vendor'),
                      style: WzTextStyles.heading3.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      AppLocalizations.of(context)!.translate('name_label'),
                      style: WzTextStyles.body2.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF4E4E4E).withOpacity(0.81),
                      ),
                    ),
                    const SizedBox(height: 8),
                    WzTextField(hint: ''),

                    const SizedBox(height: 16),

                    Text(
                      AppLocalizations.of(context)!.translate('phone_label'),
                      style: WzTextStyles.body2.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF4E4E4E).withOpacity(0.81),
                      ),
                    ),
                    const SizedBox(height: 8),
                    WzTextField(hint: '', keyboardType: TextInputType.phone),

                    const SizedBox(height: 16),

                    Text(
                      AppLocalizations.of(context)!.translate('date_label'),
                      style: WzTextStyles.body2.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF4E4E4E).withOpacity(0.81),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFFBC3CF)),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Text(
                                'dd/mm/yyyy',
                                style: WzTextStyles.body2.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WzColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.translate('get_quote'),
                          style: WzTextStyles.body1.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Text(
                        AppLocalizations.of(context)!.translate('write_review'),
                        style: WzTextStyles.heading3.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.edit, size: 16),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
