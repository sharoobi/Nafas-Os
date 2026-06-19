import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nafas_os/core/design/app_palette.dart';
import 'package:nafas_os/features/home/presentation/home_screen.dart';
import 'package:nafas_os/features/insights/presentation/insights_screen.dart';
import 'package:nafas_os/features/lab/presentation/lab_screen.dart';
import 'package:nafas_os/features/rescue/presentation/rescue_screen.dart';
import 'package:nafas_os/features/timeline/presentation/timeline_screen.dart';

class RootShellScreen extends StatefulWidget {
  const RootShellScreen({super.key});

  @override
  State<RootShellScreen> createState() => _RootShellScreenState();
}

class _RootShellScreenState extends State<RootShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      HomeScreen(
        onOpenSettings: () => context.push('/settings'),
        onOpenPrograms: () => context.push('/programs'),
      ),
      const RescueScreen(),
      const TimelineScreen(),
      const InsightsScreen(),
      LabScreen(onOpenSettings: () => context.push('/settings')),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppPalette.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppPalette.stroke),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: NavigationBar(
            height: 76,
            backgroundColor: Colors.transparent,
            indicatorColor: AppPalette.primary.withValues(alpha: 0.16),
            selectedIndex: _index,
            onDestinationSelected: (int value) =>
                setState(() => _index = value),
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.home_rounded),
                label: 'الرئيسية',
              ),
              NavigationDestination(
                icon: Icon(Icons.air_rounded),
                label: 'الإنقاذ',
              ),
              NavigationDestination(
                icon: Icon(Icons.timeline_rounded),
                label: 'الخط الزمني',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_rounded),
                label: 'التحليلات',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_rounded),
                label: 'المختبر',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
