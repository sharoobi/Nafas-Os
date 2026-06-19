import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nafas_os/core/design/app_palette.dart';
import 'package:nafas_os/core/widgets/frosted_card.dart';
import 'package:nafas_os/shared/services/platform_context_bridge_service.dart';
import 'package:nafas_os/shared/state/nafas_engine_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _followUpStatus;
  bool? _ignoringBatteryOptimizations;
  bool? _exactAlarmAllowed;
  bool? _usageAccessGranted;
  bool? _isSamsung;
  bool? _samsungBatteryWarning;
  String? _manufacturer;
  String? _model;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDiagnostics();
    });
  }

  Future<void> _loadDiagnostics() async {
    final PlatformContextBridgeService bridge = ref.read(
      platformContextBridgeServiceProvider,
    );
    final Map<String, dynamic> followUp = await bridge
        .getBootResilienceStatus()
        .catchError((Object _) => <String, dynamic>{});
    final Map<String, dynamic> capabilities = await bridge
        .getPlatformCapabilities()
        .catchError((Object _) => <String, dynamic>{});

    if (!mounted) {
      return;
    }

    setState(() {
      _followUpStatus = followUp['status'] as String?;
      _ignoringBatteryOptimizations =
          followUp['ignoringBatteryOptimizations'] as bool?;
      _exactAlarmAllowed = followUp['exactAlarmAllowed'] as bool?;
      _isSamsung = followUp['isSamsung'] as bool?;
      _samsungBatteryWarning = followUp['samsungBatteryWarning'] as bool?;
      _manufacturer = followUp['manufacturer'] as String?;
      _model = followUp['model'] as String?;
      _usageAccessGranted = capabilities['usageAccessGranted'] as bool?;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<NafasDashboardState> dashboard = ref.watch(
      nafasEngineControllerProvider,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppPalette.appGradient),
        child: SafeArea(
          child: dashboard.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stackTrace) => Center(
              child: FrostedCard(child: Text('تعذر تحميل الإعدادات.\n$error')),
            ),
            data: (NafasDashboardState state) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'الإعدادات',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: _loadDiagnostics,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const FrostedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'محلي بالكامل',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Nafas OS مصمم ليعمل محليًا. البيانات الحساسة تبقى على الجهاز ما لم تقرر أنت تصديرها.',
                          style: TextStyle(
                            color: AppPalette.textSecondary,
                            height: 1.5,
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
                          'التشغيل والاستعادة',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'هذه الحالة مهمة خصوصًا على سامسونج حتى لا تضيع التدخلات بعد إعادة التشغيل أو قيود البطارية.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppPalette.textSecondary),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: <Widget>[
                            _StatusPill(
                              label: 'تحسين البطارية',
                              ok: _ignoringBatteryOptimizations ?? false,
                              okText: 'مستثنى',
                              badText: 'مقيد',
                            ),
                            _StatusPill(
                              label: 'المنبهات الدقيقة',
                              ok: _exactAlarmAllowed ?? true,
                              okText: 'مسموح',
                              badText: 'غير مسموح',
                            ),
                            _StatusPill(
                              label: 'حالة المتابعة',
                              ok: _followUpStatus == 'scheduled',
                              okText: 'مجدولة',
                              badText: _followUpStatus ?? 'غير معروفة',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: FilledButton.tonalIcon(
                                onPressed: () async {
                                  await ref
                                      .read(
                                        platformContextBridgeServiceProvider,
                                      )
                                      .openBatteryOptimizationSettings();
                                },
                                icon: const Icon(Icons.battery_saver_outlined),
                                label: const Text('إعدادات البطارية'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await ref
                                      .read(
                                        platformContextBridgeServiceProvider,
                                      )
                                      .openExactAlarmSettings();
                                },
                                icon: const Icon(Icons.alarm_on_rounded),
                                label: const Text('إذن المنبهات'),
                              ),
                            ),
                          ],
                        ),
                        if (_isSamsung == true) ...<Widget>[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppPalette.amber.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppPalette.amber.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              (_samsungBatteryWarning ?? false)
                                  ? 'الجهاز $_manufacturer $_model يفرض عادةً قيودًا أقسى بعد إعادة التشغيل. أبقِ التطبيق مستثنى من البطارية وفعّل المنبهات الدقيقة لضمان استعادة المتابعة.'
                                  : 'الجهاز $_manufacturer $_model في حالة أفضل لمسار الاستعادة بعد إعادة التشغيل، لكن يبقى الاختبار الدوري مهمًا على سامسونج.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FrostedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'ذكاء استخدام الهاتف',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'يسمح لـ Nafas بفهم زمن الجلسات، التبديل بين التطبيقات، والانجراف الرقمي الذي قد يسبق الرغبة.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppPalette.textSecondary),
                        ),
                        const SizedBox(height: 14),
                        _StatusPill(
                          label: 'Usage Access',
                          ok: _usageAccessGranted ?? false,
                          okText: 'مفعّل',
                          badText: 'غير مفعّل',
                        ),
                        const SizedBox(height: 14),
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            await ref
                                .read(platformContextBridgeServiceProvider)
                                .openUsageAccessSettings();
                          },
                          icon: const Icon(Icons.insights_rounded),
                          label: const Text('فتح Usage Access'),
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
                          'ملفك السلوكي',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'عدّل baseline اليومي، ساعة أول سيجارة، شدة التدخل، والمحفزات التي تريد أن يراقبها Nafas.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppPalette.textSecondary),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: <Widget>[
                            _QuickMetric(
                              label: 'الأساس اليومي',
                              value:
                                  '${state.profile.cigarettesPerDayBaseline} سيجارة',
                            ),
                            _QuickMetric(
                              label: 'أول سيجارة',
                              value:
                                  '${state.profile.firstSmokeHour.toString().padLeft(2, '0')}:00',
                            ),
                            _QuickMetric(
                              label: 'عتبة الإنقاذ',
                              value:
                                  '${(state.profile.criticalThreshold * 100).round()}%',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: () => context.push('/profile-setup'),
                          icon: const Icon(Icons.person_search_rounded),
                          label: const Text('فتح الملف السلوكي الكامل'),
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
                          'مفاتيح المختبر السريعة',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('الحراسة الصوتية'),
                          subtitle: const Text('جلسات صوتية صريحة ومحدودة المدة.'),
                          value: state.labSettings.guardedAudioEnabled,
                          onChanged: (bool value) async {
                            await ref
                                .read(nafasEngineControllerProvider.notifier)
                                .saveLabSettings(guardedAudioEnabled: value);
                          },
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('التدخلات الخلفية'),
                          subtitle: const Text('متابعة نافذة الخطر حتى عندما لا يكون التطبيق مفتوحًا.'),
                          value: state.labSettings.backgroundInterventionsEnabled,
                          onChanged: (bool value) async {
                            await ref
                                .read(nafasEngineControllerProvider.notifier)
                                .saveLabSettings(
                                  backgroundInterventionsEnabled: value,
                                );
                          },
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('ذكاء البلوتوث والقيادة'),
                          subtitle: const Text('يدمج السيارة والسماعة ومسارات الحركة في قراءة الخطر.'),
                          value: state.labSettings.bluetoothContextEnabled,
                          onChanged: (bool value) async {
                            await ref
                                .read(nafasEngineControllerProvider.notifier)
                                .saveLabSettings(
                                  bluetoothContextEnabled: value,
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.ok,
    required this.okText,
    required this.badText,
  });

  final String label;
  final bool ok;
  final String okText;
  final String badText;

  @override
  Widget build(BuildContext context) {
    final Color tint = ok ? AppPalette.emerald : AppPalette.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tint.withValues(alpha: 0.32)),
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
          Text(
            ok ? okText : badText,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _QuickMetric extends StatelessWidget {
  const _QuickMetric({required this.label, required this.value});

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
