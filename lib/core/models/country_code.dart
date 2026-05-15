class CountryCode {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });

  static const List<CountryCode> countries = [
    CountryCode(name: 'India', code: 'IN', dialCode: '+91', flag: '🇮🇳'),
    CountryCode(
      name: 'United States',
      code: 'US',
      dialCode: '+1',
      flag: '🇺🇸',
    ),
    CountryCode(
      name: 'United Kingdom',
      code: 'GB',
      dialCode: '+44',
      flag: '🇬🇧',
    ),
    CountryCode(name: 'Canada', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
    CountryCode(name: 'Australia', code: 'AU', dialCode: '+61', flag: '🇦🇺'),
    CountryCode(name: 'Germany', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
    CountryCode(name: 'France', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
    CountryCode(name: 'Japan', code: 'JP', dialCode: '+81', flag: '🇯🇵'),
    CountryCode(name: 'South Korea', code: 'KR', dialCode: '+82', flag: '🇰🇷'),
    CountryCode(name: 'Singapore', code: 'SG', dialCode: '+65', flag: '🇸🇬'),
    CountryCode(
      name: 'United Arab Emirates',
      code: 'AE',
      dialCode: '+971',
      flag: '🇦🇪',
    ),
    CountryCode(
      name: 'Saudi Arabia',
      code: 'SA',
      dialCode: '+966',
      flag: '🇸🇦',
    ),
    CountryCode(name: 'Pakistan', code: 'PK', dialCode: '+92', flag: '🇵🇰'),
    CountryCode(name: 'Bangladesh', code: 'BD', dialCode: '+880', flag: '🇧🇩'),
    CountryCode(name: 'Sri Lanka', code: 'LK', dialCode: '+94', flag: '🇱🇰'),
    CountryCode(name: 'Nepal', code: 'NP', dialCode: '+977', flag: '🇳🇵'),
    CountryCode(name: 'Malaysia', code: 'MY', dialCode: '+60', flag: '🇲🇾'),
    CountryCode(name: 'Thailand', code: 'TH', dialCode: '+66', flag: '🇹🇭'),
    CountryCode(name: 'Indonesia', code: 'ID', dialCode: '+62', flag: '🇮🇩'),
    CountryCode(name: 'Philippines', code: 'PH', dialCode: '+63', flag: '🇵🇭'),
  ];

  static CountryCode get defaultCountry => countries.first;
}
