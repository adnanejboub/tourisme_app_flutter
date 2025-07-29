import 'package:flutter/material.dart';
import 'package:tourisme_app_flutter/core/providers/theme_provider.dart';

class ThemeToggleButton extends StatefulWidget {
  @override
  _ThemeToggleButtonState createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider();

    if (themeProvider.isDarkMode) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    return GestureDetector(
      onTap: () {
        themeProvider.toggleTheme();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode
              ? Color(0xFF2C2C2C)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value * 3.14159,
                  child: AnimatedOpacity(
                    opacity: 1 - _animation.value,
                    duration: Duration(milliseconds: 150),
                    child: Icon(
                      Icons.wb_sunny,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation.value * 3.14159,
                  child: AnimatedOpacity(
                    opacity: _animation.value,
                    duration: Duration(milliseconds: 150),
                    child: Icon(
                      Icons.nightlight_round,
                      color: Colors.indigo[200],
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}