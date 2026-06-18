import 'package:flutter/material.dart';

import '../maize_theme.dart';

class MaizeAppBar extends StatelessWidget {
  const MaizeAppBar({
    super.key,
    this.centerTitle = 'MaizeDetect',
    this.leading,
    this.trailing,
    this.showLogo = true,
  });

  final String centerTitle;
  final Widget? leading;
  final Widget? trailing;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: MaizeColors.surfaceContainerLowest,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF5F5F4))),
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                centerTitle,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: const Color(0xFF064E3B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
