import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nafas_os/core/design/app_palette.dart';
import 'package:nafas_os/core/widgets/frosted_card.dart';
import 'package:nafas_os/core/widgets/nafas_page_scaffold.dart';
import 'package:nafas_os/shared/models/lab_settings.dart';
import 'package:nafas_os/shared/state/nafas_engine_controller.dart';

class LabScreen extends ConsumerStatefulWidget {
  const LabScreen({super.key, required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  ConsumerState<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends ConsumerState<LabScreen> {
  bool _hydrated = false;
  bool _audioGuardEnabled = false;
  bool _geofencingEnabled = true;
  bool _healthGuardEnabled = true;
  bool _backgroundInterventionsEnabled = true;
  bool _bluetoothContextEnabled = true;
  bool _activityInferenceEnabled = true;
  double _threshold = 0.72;
  int _followUpMinutes = 8;
  int _rescueDurationSeconds = 45;
  int _notificationCooldownMinutes = 12;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<NafasDashboardState> dashboard = ref.watch(
      nafasEngineControllerProvider,
    );

    return NafasPageScaffold(
      title: 'المختبر / الاستوديو الذكي',
      subtitle: 'العتبات، الإشارات السياقية، وصفات الإنقاذ، وسلوك التنبيهات.',
      action: IconButton.filledTonal(
        onPressed: widget.onOpenSettings,
        icon: const Icon(Icons.settings_suggest_rounded),
      ),
      child: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            FrostedCard(child: Text('تعذر تحميل المختبر.\n$error')),
        data: (NafasDashboardState state) {
          if (!_hydrated) {
            final LabSettings settings = state.labSettings;
            _threshold = state.profile.criticalThreshold;
            _audioGuardEnabled = settings.guardedAudioEnabled;
            _geofencingEnabled = settings.geofencingEnabled;
            _healthGuardEnabled = settings.healthGuardEnabled;
            _backgroundInterventionsEnabled =
                settings.backgroundInterventionsEnabled;
            _bluetoothContextEnabled = settings.bluetoothContextEnabled;
            _activityInferenceEnabled = settings.activityInferenceEnabled;
            _followUpMinutes = settings.followUpMinutes;
            _rescueDurationSeconds = settings.rescueDurationSeconds;
            _notificationCooldownMinutes = settings.notificationCooldownMinutes;
            _hydrated = true;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'عتبة الإنقاذ الحرج',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'اختر النقطة التي يتحول عندها نفس إلى تدخل أكثر حزماً ووضوحًا.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _threshold,
                      min: 0.45,
                      max: 0.95,
                      onChanged: (double value) =>
                          setState(() => _threshold = value),
                    ),
                    Text(
                      'الحالي: ${(_threshold * 100).round()}%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppPalette.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FrostedCard(
                child: Column(
                  children: <Widget>[
                    _switchTile(
                      value: _geofencingEnabled,
                      onChanged: (bool value) =>
                          setState(() => _geofencingEnabled = value),
                      title: 'ذاكرة الأماكن',
                      subtitle: 'استخدم الأماكن المتكررة كجزء من درجة الخطر.',
                    ),
                    const Divider(color: AppPalette.stroke),
                    _switchTile(
                      value: _bluetoothContextEnabled,
                      onChanged: (bool value) =>
                          setState(() => _bluetoothContextEnabled = value),
                      title: 'سياق البلوتوث',
                      subtitle: 'اعتبر السيارة أو السماعات إشارة سياقية.',
                    ),
                    const Divider(color: AppPalette.stroke),
                    _switchTile(
                      value: _activityInferenceEnabled,
                      onChanged: (bool value) =>
                          setState(() => _activityInferenceEnabled = value),
                      title: 'استدلال الحركة',
                      subtitle: 'استخدم الحركة والسرعة لتقدير خطر القيادة.',
                    ),
                    const Divider(color: AppPalette.stroke),
                    _switchTile(
                      value: _backgroundInterventionsEnabled,
                      onChanged: (bool value) => setState(
                        () => _backgroundInterventionsEnabled = value,
                      ),
                      title: 'تدخلات الخلفية',
                      subtitle:
                          'اسمح بتنبيهات الخطر والمتابعات الناعمة حتى عندما تكون بعيدًا عن التطبيق.',
                    ),
                    const Divider(color: AppPalette.stroke),
                    _switchTile(
                      value: _audioGuardEnabled,
                      onChanged: (bool value) =>
                          setState(() => _audioGuardEnabled = value),
                      title: 'الحراسة الصوتية',
                      subtitle: state.permissions.microphone
                          ? 'فعّل جلسات الميكروفون الصريحة والمؤقتة.'
                          : 'إذن الميكروفون غير مفعّل بعد.',
                    ),
                    const Divider(color: AppPalette.stroke),
                    _switchTile(
                      value: _healthGuardEnabled,
                      onChanged: (bool value) =>
                          setState(() => _healthGuardEnabled = value),
                      title: 'وضع الحذر الصحي',
                      subtitle:
                          'حوّل المؤشرات التنفسية إلى سلوك حماية أكثر صرامة.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _StepperCard(
                title: 'متابعة بعد الإنذار',
                subtitle: 'تذكير لاحق إذا بقيت موجة الخطر العالية بدون حسم.',
                value: _followUpMinutes,
                unit: 'د',
                onMinus: () => setState(
                  () => _followUpMinutes = (_followUpMinutes - 1).clamp(1, 60),
                ),
                onPlus: () => setState(
                  () => _followUpMinutes = (_followUpMinutes + 1).clamp(1, 60),
                ),
              ),
              const SizedBox(height: 12),
              _StepperCard(
                title: 'مدة جلسة الإنقاذ',
                subtitle: 'المدة الافتراضية لأي موجة إنقاذ نشطة.',
                value: _rescueDurationSeconds,
                unit: 'ث',
                onMinus: () => setState(
                  () => _rescueDurationSeconds = (_rescueDurationSeconds - 15)
                      .clamp(30, 180),
                ),
                onPlus: () => setState(
                  () => _rescueDurationSeconds = (_rescueDurationSeconds + 15)
                      .clamp(30, 180),
                ),
              ),
              const SizedBox(height: 12),
              _StepperCard(
                title: 'تبريد التنبيهات',
                subtitle: 'أقل فترة هدوء بين إنذارات الخطر.',
                value: _notificationCooldownMinutes,
                unit: 'د',
                onMinus: () => setState(
                  () => _notificationCooldownMinutes =
                      (_notificationCooldownMinutes - 1).clamp(3, 90),
                ),
                onPlus: () => setState(
                  () => _notificationCooldownMinutes =
                      (_notificationCooldownMinutes + 1).clamp(3, 90),
                ),
              ),
              const SizedBox(height: 16),
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'تشغيل النظام',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _PriorityRow(
                      label: 'حالة التطبيق',
                      value: _lifecycleLabel(state.appLifecycleState.name),
                    ),
                    _PriorityRow(
                      label: 'بلوتوث صوتي',
                      value:
                          state.latestContext?.bluetoothAudioConnected == true
                          ? 'متصل'
                          : 'خامل',
                    ),
                    _PriorityRow(
                      label: 'تشغيل صوت بالخلفية',
                      value: state.latestContext?.musicActive == true
                          ? 'نعم'
                          : 'لا',
                    ),
                    _PriorityRow(
                      label: 'الشحن',
                      value: state.latestContext?.charging == true
                          ? 'نعم'
                          : 'لا',
                    ),
                    _PriorityRow(
                      label: 'الشاشة تفاعلية',
                      value: state.latestContext?.screenInteractive == true
                          ? 'نعم'
                          : 'لا',
                    ),
                    _PriorityRow(
                      label: 'إذن الموقع',
                      value: state.permissions.location ? 'مفعّل' : 'ناقص',
                    ),
                    _PriorityRow(
                      label: 'إذن النشاط',
                      value: state.permissions.activityRecognition
                          ? 'مفعّل'
                          : 'ناقص',
                    ),
                    _PriorityRow(
                      label: 'إذن البلوتوث',
                      value: state.permissions.bluetooth ? 'مفعّل' : 'ناقص',
                    ),
                    _PriorityRow(
                      label: 'إذن الميكروفون',
                      value: state.permissions.microphone ? 'مفعّل' : 'ناقص',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'العوامل الحية',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...state.riskAssessment.factors.entries.map(
                      (MapEntry<String, double> entry) => _PriorityRow(
                        label: _factorLabel(entry.key),
                        value: '${(entry.value * 100).round()}%',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FrostedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'حلقة إعادة تدريب الصوت',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'النموذج الحالي يعمل محليًا، وهذه الشاشة تبين مدى اقترابه من بياناتك الحقيقية. الهدف هنا ليس تشغيل تدريب على الجوال، بل جمع جلسات موسومة ثم تصدير dataset نظيف للبناء التالي.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPalette.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _PriorityRow(
                      label: 'إجمالي الجلسات المحفوظة',
                      value: '${state.totalGuardedAudioSamples}',
                    ),
                    _PriorityRow(
                      label: 'الجلسات الموسومة',
                      value: '${state.labeledGuardedAudioSamples}',
                    ),
                    _PriorityRow(
                      label: 'آخر حكم متوقع',
                      value: state.recentGuardedAudioSamples.isEmpty
                          ? 'لا يوجد'
                          : state.recentGuardedAudioSamples.first.predictedLabel,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: state.labeledGuardedAudioSamples == 0
                                ? null
                                : () async {
                                    final String? exportedPath = await ref
                                        .read(
                                          nafasEngineControllerProvider.notifier,
                                        )
                                        .exportGuardedAudioDataset();
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          exportedPath == null
                                              ? 'تعذر تصدير dataset الصوتي.'
                                              : 'تم تصدير dataset الصوتي إلى: $exportedPath',
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.file_download_rounded),
                            label: const Text('تصدير dataset موسوم'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          await ref
                              .read(nafasEngineControllerProvider.notifier)
                              .saveLabSettings(
                                criticalThreshold: _threshold,
                                geofencingEnabled: _geofencingEnabled,
                                guardedAudioEnabled: _audioGuardEnabled,
                                healthGuardEnabled: _healthGuardEnabled,
                                backgroundInterventionsEnabled:
                                    _backgroundInterventionsEnabled,
                                bluetoothContextEnabled:
                                    _bluetoothContextEnabled,
                                activityInferenceEnabled:
                                    _activityInferenceEnabled,
                                followUpMinutes: _followUpMinutes,
                                rescueDurationSeconds: _rescueDurationSeconds,
                                notificationCooldownMinutes:
                                    _notificationCooldownMinutes,
                              );
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم حفظ إعدادات المختبر محليًا.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('حفظ إعدادات المختبر'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          final LabSettings defaults = LabSettings.defaults;
                          _threshold = 0.72;
                          _audioGuardEnabled = defaults.guardedAudioEnabled;
                          _geofencingEnabled = defaults.geofencingEnabled;
                          _healthGuardEnabled = defaults.healthGuardEnabled;
                          _backgroundInterventionsEnabled =
                              defaults.backgroundInterventionsEnabled;
                          _bluetoothContextEnabled =
                              defaults.bluetoothContextEnabled;
                          _activityInferenceEnabled =
                              defaults.activityInferenceEnabled;
                          _followUpMinutes = defaults.followUpMinutes;
                          _rescueDurationSeconds =
                              defaults.rescueDurationSeconds;
                          _notificationCooldownMinutes =
                              defaults.notificationCooldownMinutes;
                        });
                      },
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('استعادة الافتراضيات'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _switchTile({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String title,
    required String subtitle,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  String _factorLabel(String key) {
    return switch (key) {
      'time' => 'الوقت',
      'location' => 'المكان',
      'activity' => 'النشاط',
      'recentPattern' => 'النمط القريب',
      'postMeal' => 'بعد الأكل',
      'coffee' => 'نافذة القهوة',
      'driving' => 'سياق القيادة',
      'stress' => 'التوتر',
      'symptomModifier' => 'المؤشر الصحي',
      _ => key,
    };
  }

  String _lifecycleLabel(String value) {
    return switch (value) {
      'resumed' => 'مفتوح',
      'inactive' => 'غير نشط',
      'paused' => 'في الخلفية',
      'detached' => 'منفصل',
      'hidden' => 'مخفي',
      _ => value,
    };
  }
}

class _PriorityRow extends StatelessWidget {
  const _PriorityRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppPalette.textSecondary),
            ),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppPalette.primary),
          ),
        ],
      ),
    );
  }
}

class _StepperCard extends StatelessWidget {
  const _StepperCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.unit,
    required this.onMinus,
    required this.onPlus,
  });

  final String title;
  final String subtitle;
  final int value;
  final String unit;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filledTonal(
            onPressed: onMinus,
            icon: const Icon(Icons.remove_rounded),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$value $unit',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton.filled(
            onPressed: onPlus,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}
