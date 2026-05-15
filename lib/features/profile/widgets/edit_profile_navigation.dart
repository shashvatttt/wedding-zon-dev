import 'package:flutter/material.dart';
import 'package:weddingzon/core/routes/app_routes.dart';

class EditProfileNavigation {
  static final List<Map<String, dynamic>> sections = [
    {
      'key': 'basic',
      'title': 'Basic Details',
      'route': AppRoutes.editBasicDetails,
    },
    {
      'key': 'additional',
      'title': 'Additional Details',
      'route': AppRoutes.editAdditionalDetails,
    },
    {'key': 'about', 'title': 'About Me', 'route': AppRoutes.editAbout},
    {'key': 'location', 'title': 'Location', 'route': AppRoutes.editLocation},
    {
      'key': 'religious',
      'title': 'Religious',
      'route': AppRoutes.editReligious,
    },
    {
      'key': 'education',
      'title': 'Education',
      'route': AppRoutes.editEducation,
    },
    {'key': 'family', 'title': 'Family', 'route': AppRoutes.editFamily},
    {
      'key': 'lifestyle',
      'title': 'Lifestyle',
      'route': AppRoutes.editLifestyle,
    },
    {'key': 'assets', 'title': 'Assets', 'route': AppRoutes.editProperty},
    {'key': 'contact', 'title': 'Contact', 'route': AppRoutes.editContact},
  ];

  static int getSectionIndex(String sectionKey) {
    return sections.indexWhere((s) => s['key'] == sectionKey);
  }

  static void navigateToSection(BuildContext context, int index) {
    if (index >= 0 && index < sections.length) {
      Navigator.pushReplacementNamed(context, sections[index]['route']);
    }
  }

  static void goToPrevious(BuildContext context, String currentSection) {
    final currentIndex = getSectionIndex(currentSection);
    if (currentIndex > 0) {
      navigateToSection(context, currentIndex - 1);
    } else {
      Navigator.pop(context);
    }
  }

  static void goToNext(BuildContext context, String currentSection) {
    final currentIndex = getSectionIndex(currentSection);
    if (currentIndex < sections.length - 1) {
      navigateToSection(context, currentIndex + 1);
    } else {
      Navigator.pop(context);
    }
  }
}

class EditProfileProgressIndicator extends StatelessWidget {
  final String currentSection;

  const EditProfileProgressIndicator({super.key, required this.currentSection});

  @override
  Widget build(BuildContext context) {
    final currentIndex = EditProfileNavigation.getSectionIndex(currentSection);
    final totalSections = EditProfileNavigation.sections.length;

    if (currentIndex == -1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Section ${currentIndex + 1} of $totalSections',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              Text(
                '${((currentIndex + 1) / totalSections * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF2F55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentIndex + 1) / totalSections,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFEF2F55),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfileNavigationButtons extends StatelessWidget {
  final String currentSection;
  final Future<void> Function()? onSave;
  final bool isLoading;

  const EditProfileNavigationButtons({
    super.key,
    required this.currentSection,
    this.onSave,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = EditProfileNavigation.getSectionIndex(currentSection);
    final isFirstSection = currentIndex == 0;
    final isLastSection =
        currentIndex == EditProfileNavigation.sections.length - 1;

    if (currentIndex == -1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isFirstSection)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading
                    ? null
                    : () => EditProfileNavigation.goToPrevious(
                        context,
                        currentSection,
                      ),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF2F55),
                  side: const BorderSide(color: Color(0xFFEF2F55)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          if (!isFirstSection) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLoading || onSave == null
                  ? null
                  : () async {
                      await onSave!();
                      if (context.mounted) {
                        EditProfileNavigation.goToNext(context, currentSection);
                      }
                    },
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(isLastSection ? Icons.check : Icons.arrow_forward),
              label: Text(
                isLoading
                    ? 'Saving...'
                    : (isLastSection ? 'Done' : 'Save & Next'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF2F55),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
