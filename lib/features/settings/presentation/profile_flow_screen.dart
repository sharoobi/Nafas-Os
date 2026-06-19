import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nafas_os/core/design/app_palette.dart';
import 'package:nafas_os/core/widgets/frosted_card.dart';
import 'package:nafas_os/core/widgets/nafas_page_scaffold.dart';
import 'package:nafas_os/shared/models/app_enums.dart';
import 'package:nafas_os/shared/state/nafas_engine_controller.dart';

class ProfileFlowScreen extends ConsumerStatefulWidget {
  const ProfileFlowScreen({super.key});

  @override
  ConsumerState<ProfileFlowScreen> createState() => _ProfileFlowScreenState();
}

class _ProfileFlowScreenState extends ConsumerState<ProfileFlowScreen> {
  bool _hydrated = false;
  int _baseline = 12;
  int _firstSmokeHour = 8;
  double _notificationAggression = 0.72;
  double _criticalThreshold = 0.74;
  bool _coffeeRiskEnabled = true;
  bool _drivingRiskEnabled = true;
  bool _locationRiskEnabled = true;
  double _reelsSensitivity = 0.68;
  double _workStressSensitivity = 0.64;
  double _boredomSensitivity = 0.58;
  SupportTone _supportTone = SupportTone.balanced;
  InterventionType _preferredRescue = InterventionType.microCbt;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<NafasDashboardState> dashboard = ref.watch(
      nafasEngineControllerProvider,
    );

    return NafasPageScaffold(
      title: 'الملف السلوكي',
      subtitle:
          'اضبط الشخصيّة التي يقرأ بها Nafas يومك: المحفزات، الأسلوب، وطقوس النجاة المفضلة.',
      action: IconButton.filledTonal(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.close_rounded),
      ),
      child: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (Object error, StackTrace stackTrace) => FrostedCard(
              child: Text('تعذر تحميل الملف السلوكي.\n$error'),
            ),
        data: (NafasDashboardState state) {
          if (!_hydrated) {
            _baseline = state.profile.cigarettesPerDayBaseline;
            _firstSmokeHour = state.profile.firstSmokeHour;
            _notificationAggression = state.profile.notificationAggression;
            _criticalThreshold = state.profile.criticalThreshold;
            _coffeeRiskEnabled = state.profile.coffeeRiskEnabled;
            _drivingRiskEnabled = state.profile.drivingRiskEnabled;
            _locationRiskEnabled = state.profile.locationRiskEnabled;
            _reelsSensitivity = state.profile.reelsSensitivity;
            _workStressSensitivity = state.profile.workStressSensitivity;
            _boredomSensitivity = state.profile.boredomSensitivity;
            _supportTone = state.profile.supportTone;
            _preferredRescue = state.profile.preferredRescue;
            _hydrated = true;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FrostedCard(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    _MiniPill(label: 'الأساس اليومي', value: '$_baseline سيجارة'),
                    _MiniPill(
                      label: 'أول سيجارة',
                      value: '${_firstSmokeHour.toString().padLeft(2, '0')}:00',
                    ),
                    _MiniPill(
                      label: 'أسلوب القرين',
                      value: _supportToneLabel(_supportTone),
                    ),
                    _MiniPill(
                      label: 'النجاة المفضلة',
                      value: _interventionLabel(_preferredRescue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ProfileCard(
                title: 'إيقاعك الأساسي',
                subtitle:
                    'هذه القيم تحدد baseline الذي يقيس عليه Nafas نوافذ الخطر والفاصل بين السجائر.',
                child: Column(
                  children: <Widget>[
                    _StepperRow(
                      title: 'متوسط السجائر اليومي',
                      valueLabel: '$_baseline',
                      onMinus:
                          () => setState(
                            () => _baseline = (_baseline - 1).clamp(1, 60),
                          ),
                      onPlus:
                          () => setState(
                            () => _baseline = (_baseline + 1).clamp(1, 60),
                          ),
                    ),
                    const SizedBox(height: 12),
                    _StepperRow(
                      title: 'ساعة أول سيجارة',
                      valueLabel:
                          '${_firstSmokeHour.toString().padLeft(2, '0')}:00',
                      onMinus:
                          () => setState(
                            () =>
                                _firstSmokeHour = (_firstSmokeHour - 1).clamp(0, 23),
                          ),
                      onPlus:
                          () => setState(
                            () =>
                                _firstSmokeHour = (_firstSmokeHour + 1).clamp(0, 23),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ProfileCard(
                title: 'المحفزات التي يراقبها',
                subtitle:
                    'فعّل ما تريد فقط. الدقة هنا أهم من كثرة العوامل غير المفيدة.',
                child: Column(
                  children: <Widget>[
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('القهوة وما بعد الأكل'),
                      subtitle: const Text('يرفع الوزن في النوافذ المرتبطة بالطقس الغذائي المعتاد.'),
                      value: _coffeeRiskEnabled,
                      onChanged: (bool value) => setState(() => _coffeeRiskEnabled = value),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('القيادة والانتظار'),
                      subtitle: const Text('يبني قراءات أقوى للسياقات المتحركة أو الوقفات القصيرة.'),
                      value: _drivingRiskEnabled,
                      onChanged: (bool value) => setState(() => _drivingRiskEnabled = value),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('المكان المتكرر'),
                      subtitle: const Text('يعطي وزنًا أعلى للأماكن التي تتكرر فيها السقطة أو النجاة.'),
                      value: _locationRiskEnabled,
                      onChanged: (bool value) => setState(() => _locationRiskEnabled = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ProfileCard(
                title: 'شخصيّة القرين',
                subtitle:
                    'اختر النبرة التي تتدخل بها المنظومة عندما ترتفع نافذة القرار.',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: SupportTone.values.map((SupportTone tone) {
                    return ChoiceChip(
                      label: Text(_supportToneLabel(tone)),
                      selected: _supportTone == tone,
                      onSelected: (_) => setState(() => _supportTone = tone),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _ProfileCard(
                title: 'ما الذي تعلمه القرين عنك؟',
                subtitle:
                    'هذه طبقة تكيف تاريخية تُبنى من الاستخدام الفعلي، وليست فقط من الإعدادات اليدوية. كلما زادت البيانات ارتفعت الثقة.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        _MiniPill(
                          label: 'ثقة التكيف',
                          value:
                              '${(state.profile.adaptationConfidence * 100).round()}%',
                        ),
                        _MiniPill(
                          label: 'انحياز الريلز',
                          value:
                              '+${(state.profile.adaptiveReelsBias * 100).round()}%',
                        ),
                        _MiniPill(
                          label: 'انحياز الضغط',
                          value:
                              '+${(state.profile.adaptiveStressBias * 100).round()}%',
                        ),
                        _MiniPill(
                          label: 'انحياز السكون',
                          value:
                              '+${(state.profile.adaptiveBoredomBias * 100).round()}%',
                        ),
                        _MiniPill(
                          label: 'انحياز القيادة',
                          value:
                              '+${(state.profile.adaptiveDriveBias * 100).round()}%',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.profile.lastAdaptedAt == null
                          ? 'لم يُبنَ سجل تكيف كافٍ بعد.'
                          : 'آخر تحديث للتكيف: ${state.profile.lastAdaptedAt!.year}-${state.profile.lastAdaptedAt!.month.toString().padLeft(2, '0')}-${state.profile.lastAdaptedAt!.day.toString().padLeft(2, '0')} ${state.profile.lastAdaptedAt!.hour.toString().padLeft(2, '0')}:${state.profile.lastAdaptedAt!.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ProfileCard(
                title: 'طقس النجاة المفضل',
                subtitle:
                    'عند ارتفاع الخطر، هذه الوصفة تصبح الخيار الأول قبل غيرها.',
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <InterventionType>[
                    InterventionType.microCbt,
                    InterventionType.breathing,
                    InterventionType.ghostCigarette,
                    InterventionType.walk,
                    InterventionType.driveShield,
                  ].map((InterventionType type) {
                    return ChoiceChip(
                      label: Text(_interventionLabel(type)),
                      selected: _preferredRescue == type,
                      onSelected: (_) => setState(() => _preferredRescue = type),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              _ProfileCard(
                title: 'حساسياتك السلوكية',
                subtitle:
                    'هذه الرافعات تعطي Nafas فهمًا أدق للعوامل التي تحركك: الريلز، ضغط العمل، والملل.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _SensitivitySlider(
                      label: 'حساسية الريلز والانجراف الرقمي',
                      value: _reelsSensitivity,
                      onChanged: (double value) => setState(() => _reelsSensitivity = value),
                    ),
                    const SizedBox(height: 12),
                    _SensitivitySlider(
                      label: 'حساسية ضغط العمل والمراسلات',
                      value: _workStressSensitivity,
                      onChanged:
                          (double value) => setState(() => _workStressSensitivity = value),
                    ),
                    const SizedBox(height: 12),
                    _SensitivitySlider(
                      label: 'حساسية السكون والملل',
                      value: _boredomSensitivity,
                      onChanged:
                          (double value) => setState(() => _boredomSensitivity = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ProfileCard(
                title: 'حدة التدخل',
                subtitle:
                    'حدد متى يبدأ Nafas بالتصعيد ومتى يكتفي بتنبيه أهدأ.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _SensitivitySlider(
                      label: 'شدة التنبيه',
                      value: _notificationAggression,
                      onChanged:
                          (double value) => setState(() => _notificationAggression = value),
                    ),
                    const SizedBox(height: 12),
                    _SensitivitySlider(
                      label: 'عتبة الإنقاذ الحرج',
                      value: _criticalThreshold,
                      min: 0.55,
                      max: 0.9,
                      onChanged:
                          (double value) => setState(() => _criticalThreshold = value),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        _PresetChip(
                          label: 'هادئ',
                          onTap:
                              () => setState(() {
                                _notificationAggression = 0.45;
                                _criticalThreshold = 0.82;
                                _supportTone = SupportTone.calm;
                              }),
                        ),
                        _PresetChip(
                          label: 'متوازن',
                          onTap:
                              () => setState(() {
                                _notificationAggression = 0.72;
                                _criticalThreshold = 0.74;
                                _supportTone = SupportTone.balanced;
                              }),
                        ),
                        _PresetChip(
                          label: 'حارس قوي',
                          onTap:
                              () => setState(() {
                                _notificationAggression = 0.88;
                                _criticalThreshold = 0.64;
                                _supportTone = SupportTone.challenger;
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () async {
                  await ref
                      .read(nafasEngineControllerProvider.notifier)
                      .saveProfileSettings(
                        cigarettesPerDayBaseline: _baseline,
                        firstSmokeHour: _firstSmokeHour,
                        coffeeRiskEnabled: _coffeeRiskEnabled,
                        drivingRiskEnabled: _drivingRiskEnabled,
                        locationRiskEnabled: _locationRiskEnabled,
                        notificationAggression: _notificationAggression,
                        criticalThreshold: _criticalThreshold,
                        supportTone: _supportTone,
                        preferredRescue: _preferredRescue,
                        reelsSensitivity: _reelsSensitivity,
                        workStressSensitivity: _workStressSensitivity,
                        boredomSensitivity: _boredomSensitivity,
                      );
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ الملف السلوكي.')),
                  );
                  context.pop();
                },
                icon: const Icon(Icons.save_rounded),
                label: const Text('حفظ الملف السلوكي'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _supportToneLabel(SupportTone tone) {
    return switch (tone) {
      SupportTone.calm => 'هادئ',
      SupportTone.balanced => 'متوازن',
      SupportTone.challenger => 'مباشر وتحدّي',
    };
  }

  String _interventionLabel(InterventionType type) {
    return switch (type) {
      InterventionType.breathing => 'تنفس موجه',
      InterventionType.ghostCigarette => 'سيجارة شبح',
      InterventionType.guardedAudio => 'حراسة صوتية',
      InterventionType.walk => 'مشي قصير',
      InterventionType.water => 'ماء وتهدئة',
      InterventionType.microCbt => 'إعادة تسمية المحفز',
      InterventionType.driveShield => 'درع القيادة',
      InterventionType.notificationOnly => 'تنبيه سريع',
    };
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppPalette.textMuted),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.title,
    required this.valueLabel,
    required this.onMinus,
    required this.onPlus,
  });

  final String title;
  final String valueLabel;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                valueLabel,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onMinus,
          icon: const Icon(Icons.remove_circle_outline_rounded),
        ),
        IconButton(
          onPressed: onPlus,
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
      ],
    );
  }
}

class _SensitivitySlider extends StatelessWidget {
  const _SensitivitySlider({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0.2,
    this.max = 1.0,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
        Text(
          '${(value * 100).round()}%',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppPalette.textSecondary),
        ),
      ],
    );
  }
}
