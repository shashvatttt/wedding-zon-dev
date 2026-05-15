# Vendor App Bar

A custom app bar widget inspired by Blinkkit's design, adapted for the WeddingZon matrimonial vendor section.

## Features

- Vertical gradient background matching the navbar color scheme (pink/red)
- Customizable top text, main text, and location text
- Optional wallet and profile action buttons
- Seamless gradient continuation into the body
- **Smooth fade effect on scroll** - App bar fades out as user scrolls down
- Responsive and touch-friendly design

## Usage

### Basic Usage with Scroll Fade Effect

```dart
class _VendorScreenState extends State<VendorScreen> {
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final maxScroll = 150.0;
    
    setState(() {
      _appBarOpacity = (1.0 - (offset / maxScroll)).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VendorAppBar(
        topText: 'Find vendors for',
        mainText: 'Your Wedding',
        locationText: 'Browse All Categories',
        opacity: _appBarOpacity, // Dynamic opacity based on scroll
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6B8A).withValues(alpha: _appBarOpacity * 0.8),
              Color(0xFFF8F9FB),
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Your content here
          ],
        ),
      ),
    );
  }
}
```

### Static App Bar (No Fade)

```dart
Scaffold(
  appBar: const VendorAppBar(
    topText: 'Find vendors for',
    mainText: 'Your Wedding',
    locationText: 'Browse All Categories',
    opacity: 1.0, // Always visible
  ),
  body: YourContent(),
)
```

### With Action Callbacks

```dart
VendorAppBar(
  topText: 'Service ready in',
  mainText: '21 minutes',
  locationText: 'HOME - Abhijeet Dubey',
  showWallet: true,
  showProfile: true,
  onWalletTap: () {
    // Handle wallet tap
  },
  onProfileTap: () {
    // Handle profile tap
  },
  onLocationTap: () {
    // Handle location tap
  },
)
```

### Hide Wallet Button

```dart
VendorAppBar(
  topText: 'Find vendors for',
  mainText: 'Your Wedding',
  locationText: 'Browse All Categories',
  showWallet: false, // Hide wallet button
)
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `topText` | String | 'Service ready in' | Small text above main text |
| `mainText` | String | '21 minutes' | Large bold text |
| `locationText` | String | 'Select Location' | Location text with dropdown arrow |
| `showWallet` | bool | true | Show/hide wallet button |
| `showProfile` | bool | true | Show/hide profile button |
| `opacity` | double | 1.0 | Opacity of entire app bar (0.0 to 1.0) |
| `onWalletTap` | VoidCallback? | null | Wallet button tap handler |
| `onProfileTap` | VoidCallback? | null | Profile button tap handler |
| `onLocationTap` | VoidCallback? | null | Location row tap handler |

## Scroll Fade Effect

The app bar supports a smooth fade effect when scrolling:

1. **Add ScrollController** to your state
2. **Listen to scroll events** and calculate opacity based on scroll offset
3. **Pass opacity** to the VendorAppBar
4. **Sync body gradient** with the same opacity for seamless transition

The fade effect creates a modern, polished feel where the app bar gracefully disappears as users scroll down, giving more screen space to content.

### Fade Calculation

```dart
void _onScroll() {
  final offset = _scrollController.offset;
  final maxScroll = 150.0; // Fade completes after 150px scroll
  
  setState(() {
    _appBarOpacity = (1.0 - (offset / maxScroll)).clamp(0.0, 1.0);
  });
}
```

- At scroll offset 0px: opacity = 1.0 (fully visible)
- At scroll offset 75px: opacity = 0.5 (50% visible)
- At scroll offset 150px+: opacity = 0.0 (fully transparent)

## Color Scheme

The app bar uses a vertical gradient that matches the navbar:
- Top: `Color(0xFFEF2F55)` (primary pink/red)
- Bottom: `Color(0xFFFF6B8A)` (lighter pink)

The gradient continues seamlessly into the body for a cohesive design.

## Implementation Details

- Height: 130px (including SafeArea)
- Implements `PreferredSizeWidget` for use as Scaffold appBar
- Uses SafeArea to avoid system UI overlap
- Circular white buttons with colored icons
- Text overflow handling with ellipsis
