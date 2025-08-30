import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';

class ThemeAwareWidget extends StatefulWidget {
  final Widget child;

  const ThemeAwareWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ThemeAwareWidget> createState() => _ThemeAwareWidgetState();
}

class _ThemeAwareWidgetState extends State<ThemeAwareWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    themeProvider.updateSystemTheme(brightness);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
