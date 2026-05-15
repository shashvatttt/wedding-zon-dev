# UI Clone Icons

This directory contains SVG icons extracted from the Figma design for the WeddingZon UI clone.

## Extracted Icons

### Navigation Icons
- `ic_chevron_backward.svg` - Back navigation arrow
- `ic_dropdown.svg` - Dropdown arrow

### Authentication Icons
- `ic_phone.svg` - Phone icon for OTP login
- `ic_google.svg` - Google logo for Google login

### Feature Icons
- `ic_notification.svg` - Notification bell
- `ic_settings.svg` - Settings gear
- `ic_filter.svg` - Filter icon
- `ic_edit.svg` - Edit pencil icon

### Profile & Social Icons
- `ic_ring.svg` - Marriage ring icon
- `ic_cross.svg` - Cross/reject icon
- `ic_heart.svg` - Heart/like icon
- `ic_chat.svg` - Chat bubble icon
- `ic_profile.svg` - Profile icon
- `ic_shopping.svg` - Shopping bag icon

### Communication Icons
- `ic_attachment.svg` - Attachment icon
- `ic_camera.svg` - Camera icon
- `ic_send.svg` - Send message icon
- `ic_mic.svg` - Microphone icon
- `ic_info.svg` - Info icon
- `ic_call.svg` - Phone call icon
- `ic_video_call.svg` - Video call icon
- `ic_menu_dots.svg` - Menu dots (more options)

### Utility Icons
- `ic_search.svg` - Search icon
- `ic_share.svg` - Share icon
- `ic_star.svg` - Rating star icon
- `ic_location_pin.svg` - Location pin icon
- `ic_play.svg` - Play button
- `ic_pause.svg` - Pause button

## Usage in Flutter

### Basic Usage
```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'assets/ui_clone/icons/ic_phone.svg',
  width: 24,
  height: 24,
)
```

### With Color
```dart
SvgPicture.asset(
  'assets/ui_clone/icons/ic_heart.svg',
  width: 24,
  height: 24,
  colorFilter: ColorFilter.mode(
    WzColors.primary,
    BlendMode.srcIn,
  ),
)
```

### In IconButton
```dart
IconButton(
  icon: SvgPicture.asset(
    'assets/ui_clone/icons/ic_notification.svg',
    width: 24,
    height: 24,
    colorFilter: ColorFilter.mode(
      Colors.white,
      BlendMode.srcIn,
    ),
  ),
  onPressed: () {},
)
```

## Icon Specifications

- **Format**: SVG (Scalable Vector Graphics)
- **Default Size**: 24x24 pixels
- **Color**: Uses `currentColor` or can be customized via `colorFilter`
- **Naming Convention**: `ic_<name>.svg` in snake_case

## Adding New Icons

1. Extract SVG from Figma using `get_design_context`
2. Save to this directory with `ic_` prefix
3. Use snake_case naming (e.g., `ic_new_icon.svg`)
4. Ensure SVG uses `currentColor` for fill to allow color customization
5. Update this README with the new icon

## Notes

- All icons use `fill="currentColor"` to allow dynamic color changes
- Icons are optimized for 24x24 size but scale well to other sizes
- For standard Material icons, consider using `material_symbols_icons` package instead
- See `ICON_STRATEGY.md` for guidance on when to use SVG vs icon packages
