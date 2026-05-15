# Icon Strategy for WeddingZon UI Clone

## Overview
This document outlines the strategy for handling icons in the UI clone layer.

## Icon Categories

### 1. Standard Library Icons (Use Flutter Packages)
Most icons in the design are from standard icon libraries. Instead of extracting SVGs, use Flutter icon packages:

**Material Symbols Icons** (use `material_symbols_icons` package):
- `material-symbols:edit`
- `material-symbols:info-outline`
- `material-symbols:call`
- `material-symbols:search`
- `material-symbols:mic`
- `material-symbols:touch-app-outline`
- `material-symbols-light:share-outline`

**MDI Icons** (use `mdi` or `flutter_icons` package):
- `mdi:filter-outline`
- `mdi:ring`
- `mdi:heart`
- `mdi:shopping`

**Other Icon Libraries**:
- `mingcute:notification-fill`
- `mingcute:settings-6-line`
- `mingcute:attachment-line`
- `mingcute:send-fill`
- `gridicons:chat`
- `gridicons:dropdown`
- `ant-design:safety-outlined`
- `bx:camera`
- `iconamoon:profile-fill`

### 2. Custom/Extracted Icons (SVG Files)
These are custom icons unique to WeddingZon or modified versions:

**Already Extracted**:
- `ic_phone.svg` - Phone icon for authentication
- `ic_google.svg` - Google logo for Google login

**To Be Extracted** (if custom):
- India flag icon (if custom design)
- WeddingZon logo
- Custom navigation icons
- Custom profile/social icons

### 3. Illustrations (SVG/PNG Files)
- Empty state illustrations
- Onboarding images
- Background patterns
- Role selection images

## Implementation Approach

### For Standard Library Icons:
```dart
import 'package:material_symbols_icons/material_symbols_icons.dart';

Icon(
  Symbols.edit,
  color: WzColors.primary,
  size: 24,
)
```

### For Custom SVG Icons:
```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'assets/ui_clone/icons/ic_phone.svg',
  width: 24,
  height: 24,
  colorFilter: ColorFilter.mode(
    WzColors.primary,
    BlendMode.srcIn,
  ),
)
```

## Recommended Packages

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_svg: ^2.0.0
  material_symbols_icons: ^4.2719.1
  # Or use a comprehensive icon package like:
  # flutter_icons: ^1.1.0
```

## Benefits of This Approach

1. **Smaller App Size**: No need to bundle hundreds of SVG files
2. **Consistency**: Icons from standard libraries are well-tested
3. **Maintainability**: Easy to update icons by changing package versions
4. **Performance**: Icon fonts are optimized for rendering
5. **Flexibility**: Easy to change icon size and color

## Custom Icon Extraction Process

For truly custom icons:
1. Identify the icon node ID in Figma
2. Call `get_design_context` to get the design
3. Extract SVG content from the response
4. Save to `assets/ui_clone/icons/` with snake_case naming
5. Update `pubspec.yaml` with asset path

## Notes

- Focus extraction efforts on custom icons unique to WeddingZon
- Use standard icon libraries for common icons
- Document which package each icon comes from
- Maintain consistent sizing (24x24 for most icons)
