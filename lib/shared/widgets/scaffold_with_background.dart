import 'package:flutter/material.dart';

class ScaffoldWithBackground extends StatelessWidget {
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool extendBodyBehindAppBar;
  final Color backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final Key? scaffoldKey;

  const ScaffoldWithBackground({
    super.key,
    this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor = Colors.transparent,
    this.resizeToAvoidBottomInset,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -75,
            top: -3,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/ui_clone/images/backgrounds/background_pattern_1.jpg',
                width: 512,
                height: 958,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          if (body != null) body!,
        ],
      ),
    );
  }
}
