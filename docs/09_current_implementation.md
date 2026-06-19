# Current Implementation Snapshot

## What is already working

- Flutter shell with premium dark design system
- Arabic-first UX across the main tested surfaces
- package identity `com.nafas.sharoobi`
- onboarding persistence
- SQLite local persistence
- risk scoring engine
- smoke/craving/symptom/intervention/context logging
- manual trigger-aware craving logging with stress + urge capture
- Lab settings persistence
- notification orchestration with cooldowns and background-aware follow-up timers
- persistent Android follow-up scheduling that survives reboot through native alarm rescheduling
- boot-resilience diagnostics in Settings for:
  - battery-optimization status
  - exact-alarm status
  - restart follow-up testing
  - manufacturer/model visibility
  - Samsung-specific restart warning
- Android native context bridge
- explicit guarded audio session status on Android
- deeper Android context intelligence:
  - Activity Recognition transition monitoring
  - vehicle-context scoring
  - audio-route classification for car/headset/wired output
- deeper guarded audio heuristics:
  - lighter-like spikes
  - cough-like bursts
  - steady breath cycles
  - restlessness bursts
  - derived audio risk score
- real guarded-audio TFLite inference running on-device over engineered audio features
- real guarded-audio training sample logging with:
  - persisted session-end feature capture
  - predicted label/confidence storage
  - manual confirmation labels from Rescue
  - CSV export path for retraining
- Home-level adaptive coaching and quick manual check-in UX
- Home-level companion intelligence for:
  - place identity
  - stationary duration
  - dominant app
  - digital drift score
  - short-video/social/messaging exposure
- Programs surface inspired by the Sleep Cycle information architecture
- Programs surface now split into:
  - recommended-now hero
  - live daily missions
  - reusable behavior-program library
- mission-memory persistence with:
  - started count
  - success/failure count
  - streak memory
  - momentum score
- richer mission-memory visualization in Programs
- fuller profile flow screen for behavior tuning
- adaptive profile persistence with learned bias fields:
  - reels
  - stress
  - boredom/stillness
  - driving
  - adaptation confidence
- Rescue-level audio verdict card with:
  - classification title
  - confidence
  - recommended next action
- Rescue-level guarded-audio setup wizard so the microphone flow is no longer hidden behind Lab
- Rescue missions with clearer Arabic task language and intervention-specific scripts
- Rescue interactive mission layer with three modes:
  - tap sequence
  - hold shield
  - breath cycle
- Insights layer now includes:
  - companion interpretation card
  - period summary drilldowns
  - daily experiment prompt
- Lab controls fully translated and persisted
- Settings-level `Usage Access` orchestration for app-usage intelligence
- release APK build and installation on real device

## Main implemented layers

### Presentation

- `Home` reads live dashboard state
- `Home` now includes:
  - adaptive coaching copy
  - quick manual check-in sheet
  - trigger-aware summary chips
  - direct entry to guided programs
- `Timeline` renders recent logged events
- `Insights` renders current factor-derived chart
- `Rescue` supports:
  - active rescue state
  - next-approach rotation
  - duration presets
  - guided scripts
  - guarded-audio status banner
  - guarded-audio verdict summary card
- `Programs` provides structured, contextual intervention packs
- `Settings` now provides:
  - restart/battery diagnostics
  - usage-access diagnostics
  - quick lab toggles
  - entry to the full behavior-profile flow
- `Profile flow` now provides:
  - baseline tuning
  - first-smoke timing
  - trigger toggles
  - intervention-style presets
- `Lab` renders live factors, permission-dependent toggles, and platform/runtime capabilities

### Data

- database bootstrap:
  - `app/lib/shared/data/local/nafas_database.dart`
- repository contract:
  - `app/lib/shared/data/repositories/nafas_repository.dart`
- SQLite repository implementation:
  - `app/lib/shared/data/repositories/isar_nafas_repository.dart`

### Intelligence

- risk engine:
  - `app/lib/shared/services/risk_engine.dart`
- guarded audio classifier:
  - `app/lib/shared/services/guarded_audio_classifier.dart`
- adaptive profile engine:
  - `app/lib/shared/services/adaptive_profile_engine.dart`
- dashboard state orchestration:
  - `app/lib/shared/state/nafas_engine_controller.dart`

### Platform and system services

- notifications:
  - `app/lib/shared/services/notification_service.dart`
- permissions:
  - `app/lib/shared/services/permission_orchestrator_service.dart`
- context sampling:
  - `app/lib/shared/services/context_sampling_service.dart`
- Android native bridge:
  - `app/android/app/src/main/kotlin/com/nafas/sharoobi/MainActivity.kt`
- Android background follow-up scheduler:
  - `app/android/app/src/main/kotlin/com/nafas/sharoobi/BackgroundFollowUpScheduler.kt`
  - `app/android/app/src/main/kotlin/com/nafas/sharoobi/FollowUpAlarmReceiver.kt`
  - `app/android/app/src/main/kotlin/com/nafas/sharoobi/BootRescheduleReceiver.kt`
- Android activity transition monitor:
  - `app/android/app/src/main/kotlin/com/nafas/sharoobi/ActivityContextMonitor.kt`
  - `app/android/app/src/main/kotlin/com/nafas/sharoobi/ActivityTransitionReceiver.kt`

## Real issues found and fixed on device

- startup crash from a transitive `PathUtils` issue:
  - removed `google_fonts` and switched to a local Material text theme
- `LateInitializationError` when opening `Rescue`:
  - `NafasEngineController` repository initialization is now rebuild-safe
- broken UI copy:
  - tested screens now use clean strings instead of garbled mojibake

## Real-device verification evidence

Latest successful captures:

- Sleep Cycle inspired home/programs/settings/profile round:
  - `device_checks/2026-04-14-sleepcycle-inspired/11_home_updated.png`
  - `device_checks/2026-04-14-sleepcycle-inspired/11_home_updated.xml`
  - `device_checks/2026-04-14-sleepcycle-inspired/12_programs_screen.png`
  - `device_checks/2026-04-14-sleepcycle-inspired/12_programs_screen.xml`
  - `device_checks/2026-04-14-sleepcycle-inspired/13_settings_screen.png`
  - `device_checks/2026-04-14-sleepcycle-inspired/13_settings_screen.xml`
  - `device_checks/2026-04-14-sleepcycle-inspired/14_settings_scrolled.png`
  - `device_checks/2026-04-14-sleepcycle-inspired/14_settings_scrolled.xml`
  - `device_checks/2026-04-14-sleepcycle-inspired/15_profile_flow.png`
  - `device_checks/2026-04-14-sleepcycle-inspired/15_profile_flow.xml`

- Home:
  - `device_checks/80_home_final.png`
  - `device_checks/80_home_final.xml`
- Home refresh:
  - `device_checks/2026-04-13/01_home.png`
  - `device_checks/2026-04-13/01_home.xml`
- Home smart layer:
  - `device_checks/93_home_manual_intelligence.png`
  - `device_checks/93_home_manual_intelligence.xml`
- Home companion layer refresh:
  - `device_checks/2026-04-14/02_app.png`
  - `device_checks/2026-04-14/02_app.xml`
- Rescue:
  - `device_checks/86_rescue_final.png`
  - `device_checks/86_rescue_final.xml`
- Rescue refresh:
  - `device_checks/2026-04-13/03_rescue.png`
  - `device_checks/2026-04-13/03_rescue.xml`
- Lab:
  - `device_checks/87_lab_final.png`
  - `device_checks/87_lab_final.xml`
- Lab refresh:
  - `device_checks/2026-04-13/04_lab.png`
  - `device_checks/2026-04-13/04_lab.xml`
- Settings boot-resilience diagnostics:
  - `device_checks/2026-04-13-final/10_settings_boot.png`
  - `device_checks/2026-04-13-final/10_settings_boot.xml`
- Settings usage-intelligence diagnostics:
- `device_checks/2026-04-14/03_settings.png`
- `device_checks/2026-04-14/03_settings.xml`
- `device_checks/2026-04-15-final/01_home.png`
- `device_checks/2026-04-15-final/01_home.xml`
- `device_checks/2026-04-15-final/02_programs.png`
- `device_checks/2026-04-15-final/02_programs.xml`
- `device_checks/2026-04-15-final/03_rescue.png`
- `device_checks/2026-04-15-final/03_rescue.xml`
- `device_checks/2026-04-15-final/04_insights.png`
- `device_checks/2026-04-15-final/04_insights.xml`
- `device_checks/2026-04-15-deep/01_launch.png`
- `device_checks/2026-04-15-deep/01_launch.xml`
- `device_checks/2026-04-15-deep/02_settings.png`
- `device_checks/2026-04-15-deep/02_settings.xml`
- `device_checks/2026-04-15-deep/03_settings_scrolled.png`
- `device_checks/2026-04-15-deep/03_settings_scrolled.xml`
- `device_checks/2026-04-15-deep/04_profile.png`
- `device_checks/2026-04-15-deep/04_profile.xml`

## Permissions currently wired

### Android manifest

- notifications
- vibration
- wake lock
- foreground service
- receive boot completed
- coarse/fine/background location
- activity recognition
- bluetooth legacy and modern permissions
- camera
- microphone

### iOS usage descriptions

- location
- motion
- bluetooth
- camera
- microphone

## Device verification

Built and installed:

- `app/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
- `app/build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
- `app/build/app/outputs/flutter-apk/app-x86_64-release.apk`

Verified on:

- `SM N986U`

Verification executed:

- `flutter pub get`
- `python tool/generate_guarded_audio_tflite.py`
- `flutter analyze`
- `flutter test`
- `flutter build apk --release --split-per-abi`
- install to connected Android device
- open and inspect Home, Settings, Profile, Rescue, and Lab via UI dumps and screenshots

## Important current limits

- guarded audio now closes the real-session loop operationally, but model quality still depends on collecting and labeling enough real sessions before retraining
- profile editing is now coupled to a persisted adaptive profile layer, but it still needs richer long-horizon context identity and explanation UX
- activity and bluetooth context are materially deeper now, but still not a complete long-horizon personal context model
- end-to-end reboot testing was executed on the connected Samsung device; receiver wiring and persistence are in place, but the actual alarm still appears to be OEM-constrained after reboot unless the app is excluded from battery restrictions
- final reinstall of this exact latest round was blocked by device storage pressure (`INSTALL_FAILED_INSUFFICIENT_STORAGE`), so live verification of the newest additions should be repeated after freeing storage

## Recommended next round

1. Expand persistent background orchestration beyond follow-up alarms into confidence-aware intervention budgets.
2. Expand Android/iOS bridge depth for activity and bluetooth context.
3. Turn adaptive profile biases into richer historical identity layers and explainable insight cards.
4. Add respiratory caution workflows with stronger symptom-driven UX.
5. Re-verify the newest build live on device after freeing storage.
