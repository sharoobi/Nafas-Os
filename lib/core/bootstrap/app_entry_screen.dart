import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafas_os/core/bootstrap/app_bootstrap_controller.dart';
import 'package:nafas_os/core/design/app_palette.dart';
import 'package:nafas_os/features/onboarding/presentation/onboarding_screen.dart';
import 'package:nafas_os/features/shell/presentation/root_shell_screen.dart';

class AppEntryScreen extends ConsumerWidget {
  const AppEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppBootstrapState> bootstrap = ref.watch(
      appBootstrapControllerProvider,
    );

    return bootstrap.when(
      data: (AppBootstrapState state) {
        if (state.onboardingCompleted) {
          return const RootShellScreen();
        }
        return const OnboardingScreen();
      },
      loading: () => const _BootSplash(),
      error: (Object error, StackTrace stackTrace) =>
          const _BootSplash(message: 'جارٍ إعادة تهيئة نظام نفس...'),
    );
  }
}

class _BootSplash extends StatelessWidget {
  const _BootSplash({this.message = 'نجهّز محرك التدخل اللحظي...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppPalette.appGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: <Color>[AppPalette.primary, AppPalette.secondary],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppPalette.primary.withValues(alpha: 0.24),
                      blurRadius: 32,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.air_rounded,
                  color: AppPalette.background,
                  size: 42,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Nafas OS',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPalette.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
