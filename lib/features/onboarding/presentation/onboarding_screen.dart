import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafas_os/core/bootstrap/app_bootstrap_controller.dart';
import 'package:nafas_os/core/design/app_palette.dart';
import 'package:nafas_os/core/widgets/frosted_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  static const List<_OnboardingItem> _items = <_OnboardingItem>[
    _OnboardingItem(
      title: 'يسبق الرغبة، ولا يلاحقها',
      body:
          'Nafas OS يتعامل مع اللحظة التي تسبق السيجارة. يلتقط السياق، يحسب الخطر، ثم يفتح لك تدخلًا قصيرًا بدل أن يتركك وحدك مع الاندفاع.',
      icon: Icons.radar_rounded,
    ),
    _OnboardingItem(
      title: 'تدخل لحظي خلال ثوانٍ',
      body:
          'تنفس موجّه، بديل حسي، موجة إنقاذ، ووضع حماية ذكي وقت القهوة أو القيادة أو الضغط. الهدف إنقاذ الموقف، لا مجرد تسجيله.',
      icon: Icons.bolt_rounded,
    ),
    _OnboardingItem(
      title: 'مختبر داخلي يفهمك شخصيًا',
      body:
          'كل شيء محلي وقابل للضبط: المحفزات، الحساسات، مستويات الخطورة، والتدخلات. التطبيق يتطور معك بدل أن يفرض قالبًا واحدًا على الجميع.',
      icon: Icons.tune_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await ref
        .read(appBootstrapControllerProvider.notifier)
        .completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _index == _items.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppPalette.appGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppPalette.primary.withValues(alpha: 0.14),
                        border: Border.all(
                          color: AppPalette.primary.withValues(alpha: 0.22),
                        ),
                      ),
                      child: const Icon(
                        Icons.air_rounded,
                        color: AppPalette.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Nafas OS',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton(onPressed: _complete, child: const Text('تخطي')),
                  ],
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int value) =>
                        setState(() => _index = value),
                    itemCount: _items.length,
                    itemBuilder: (BuildContext context, int index) {
                      final _OnboardingItem item = _items[index];
                      return FrostedCard(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: <Color>[
                                    AppPalette.primary,
                                    AppPalette.secondary,
                                  ],
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: AppPalette.secondary.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 22,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                item.icon,
                                color: AppPalette.background,
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              item.body,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppPalette.textSecondary,
                                    height: 1.55,
                                  ),
                            ),
                            const Spacer(),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: <Widget>[
                                _HighlightChip(
                                  label: index == 0
                                      ? 'تدخل لحظي'
                                      : 'محلي بالكامل',
                                ),
                                _HighlightChip(
                                  label: index == 1
                                      ? 'إنقاذ سريع'
                                      : 'قواعد + تعلم',
                                ),
                                const _HighlightChip(label: 'مختبر داخلي'),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: List<Widget>.generate(
                    _items.length,
                    (int index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.only(right: 8),
                      width: _index == index ? 28 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _index == index
                            ? AppPalette.primary
                            : AppPalette.textMuted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () async {
                    if (isLast) {
                      await _complete();
                      return;
                    }
                    await _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                    backgroundColor: AppPalette.primary,
                    foregroundColor: AppPalette.background,
                  ),
                  child: Text(isLast ? 'ابدأ ببناء نمطك الشخصي' : 'التالي'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.stroke),
      ),
      child: Text(label),
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}
