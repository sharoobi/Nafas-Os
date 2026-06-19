import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBootstrapState {
  const AppBootstrapState({required this.onboardingCompleted});

  final bool onboardingCompleted;

  AppBootstrapState copyWith({bool? onboardingCompleted}) {
    return AppBootstrapState(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}

final appBootstrapControllerProvider =
    AsyncNotifierProvider<AppBootstrapController, AppBootstrapState>(
      AppBootstrapController.new,
    );

class AppBootstrapController extends AsyncNotifier<AppBootstrapState> {
  static const String _onboardingKey = 'nafas.onboardingCompleted';

  @override
  Future<AppBootstrapState> build() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return AppBootstrapState(
      onboardingCompleted: preferences.getBool(_onboardingKey) ?? false,
    );
  }

  Future<void> completeOnboarding() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingKey, true);
    state = const AsyncData(AppBootstrapState(onboardingCompleted: true));
  }

  Future<void> resetOnboarding() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingKey, false);
    state = const AsyncData(AppBootstrapState(onboardingCompleted: false));
  }
}
