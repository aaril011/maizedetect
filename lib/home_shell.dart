import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'maize_theme.dart';
import 'history_screen.dart';
import 'scan_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(onTapScan: () => setState(() => _index = 1)),
          const ScanScreen(),
          const HistoryScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: MaizeColors.navActiveBackground,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected
                  ? const Color(0xFF064E3B)
                  : Colors.grey.shade500,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          backgroundColor: Colors.white.withValues(alpha: 0.95),
          surfaceTintColor: Colors.transparent,
          shadowColor: MaizeColors.primaryContainer.withValues(alpha: 0.08),
          elevation: 8,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.center_focus_strong_outlined),
              selectedIcon: Icon(Icons.center_focus_strong),
              label: 'Pindai',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              selectedIcon: Icon(Icons.history),
              label: 'Riwayat',
            ),
          ],
        ),
      ),
    );
  }
}
