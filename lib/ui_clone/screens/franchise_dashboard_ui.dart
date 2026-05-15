import 'package:flutter/material.dart';
import '../../core/theme/wz_colors.dart';
import '../../core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/localization/app_localizations.dart';

class FranchiseDashboardScreenUI extends StatelessWidget {
  const FranchiseDashboardScreenUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.translate('franchise_dashboard'),
          style: WzTextStyles.heading2.copyWith(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.translate('welcome_back'),
              style: WzTextStyles.heading1.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.translate('franchise_overview'),
              style: WzTextStyles.body1.copyWith(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    AppLocalizations.of(context)!.translate('total_revenue'),
                    '₹2,45,000',
                    Icons.currency_rupee,
                    WzColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    AppLocalizations.of(context)!.translate('active_members'),
                    '156',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    AppLocalizations.of(context)!.translate('pending_requests'),
                    '12',
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    AppLocalizations.of(context)!.translate('this_month'),
                    '₹45,000',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Text(
              AppLocalizations.of(context)!.translate('quick_actions'),
              style: WzTextStyles.heading2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(
                  Icons.person_add,
                  AppLocalizations.of(context)!.translate('add_member'),
                ),
                _buildQuickAction(
                  Icons.payment,
                  AppLocalizations.of(context)!.translate('payments'),
                ),
                _buildQuickAction(
                  Icons.analytics,
                  AppLocalizations.of(context)!.translate('reports'),
                ),
                _buildQuickAction(
                  Icons.settings,
                  AppLocalizations.of(context)!.translate('settings'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Text(
              AppLocalizations.of(context)!.translate('recent_activities'),
              style: WzTextStyles.heading2.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            _buildActivityItem(
              AppLocalizations.of(
                context,
              )!.translate('new_member_registration'),
              'John Doe ${AppLocalizations.of(context)!.translate('joined_franchise')}',
              '2 ${AppLocalizations.of(context)!.translate('hours_ago')}',
            ),
            _buildActivityItem(
              AppLocalizations.of(context)!.translate('payment_received'),
              '${AppLocalizations.of(context)!.translate('membership_fee_from')} Jane Smith',
              '5 ${AppLocalizations.of(context)!.translate('hours_ago')}',
            ),
            _buildActivityItem(
              AppLocalizations.of(context)!.translate('profile_updated'),
              'Mike Johnson ${AppLocalizations.of(context)!.translate('updated_profile')}',
              '1 ${AppLocalizations.of(context)!.translate('day_ago')}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFBC3CF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: WzTextStyles.body2.copyWith(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: WzTextStyles.heading2.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: WzColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: WzColors.primary, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: WzTextStyles.body2.copyWith(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFBC3CF)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: WzColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.notifications, color: WzColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: WzTextStyles.body1.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: WzTextStyles.body2.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: WzTextStyles.body2.copyWith(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
