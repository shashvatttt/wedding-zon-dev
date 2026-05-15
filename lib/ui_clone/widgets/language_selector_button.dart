import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/locale_provider.dart';

class LanguageSelectorButton extends StatelessWidget {
  final Color iconColor;
  final Color backgroundColor;

  const LanguageSelectorButton({
    super.key,
    this.iconColor = Colors.white,
    this.backgroundColor = Colors.black38,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return PopupMenuButton<Locale>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.language, color: iconColor, size: 20),
          ),
          onSelected: (Locale locale) {
            localeProvider.setLocale(locale);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
            const PopupMenuItem<Locale>(
              value: Locale('en'),
              child: Text('English'),
            ),
            const PopupMenuItem<Locale>(
              value: Locale('hi'),
              child: Text('हिंदी (Hindi)'),
            ),
            const PopupMenuItem<Locale>(
              value: Locale('pa'),
              child: Text('ਪੰਜਾਬੀ (Punjabi)'),
            ),
          ],
        );
      },
    );
  }
}
