# System Architecture

## Architecture choice

Use `Flutter shell + native capability engines`.

Why:

- Flutter is strong for rapid, polished, cross-platform UI
- Android/iOS native layers are required for deep context sensing
- the product needs both elegant UX and platform-level intelligence

## High-level layers

### 1. Presentation layer

Flutter:

- UI
- navigation
- animations
- charts
- settings
- lab
- event review

### 2. Domain layer

Dart application core:

- entities
- use cases
- repositories contracts
- rules engine orchestration
- intervention coordinator
- risk scoring

### 3. Data layer

Flutter local persistence:

- Isar or Drift
- secure storage
- model snapshots
- export/import

### 4. Native integration layer

Bridge contracts:

- Pigeon for type-safe platform contracts
- event streams for sensor and context updates
- command calls for start/stop/configure actions

### 5. Native engines

Android Kotlin and iOS Swift:

- motion/context engine
- location engine
- bluetooth and car-state engine
- guarded audio session engine
- haptics engine
- notification orchestration

## Recommended project structure

```text
app/
  lib/
    app/
    core/
    shared/
    features/
      onboarding/
      home/
      rescue/
      smoking_log/
      craving_log/
      symptoms/
      insights/
      lab/
      settings/
  android/
  ios/
```

## Module strategy

Prefer a `feature-first modular monolith`.

This keeps:

- boundaries clear
- refactors manageable
- overhead lower than full micro-package fragmentation

## Core domain modules

### Context engine

Combines raw signals into derived features:

- time buckets
- location cluster ids
- driving flag
- post-meal window
- coffee window
- minutes since last smoke
- activity state

### Risk engine

Calculates:

- `craving_risk_score`
- `smoke_within_1_min`
- `smoke_within_3_min`
- `smoke_within_10_min`

### Intervention engine

Chooses:

- notification only
- rescue screen
- breathing
- ghost cigarette
- walk
- water
- cognitive micro-intervention

### Lab engine

Allows:

- feature gating
- threshold tuning
- rule editing
- experiment switching
- replay

## Native engine map

### Android

- `ContextCollectorService`
- `ActivityContextManager`
- `GeofenceContextManager`
- `BluetoothContextManager`
- `NotificationInterventionManager`
- `AudioGuardSessionManager`
- `AdvancedHapticsManager`

### iOS

- `MotionContextManager`
- `LocationContextManager`
- `NotificationInterventionController`
- `AudioGuardSessionController`
- `HapticsController`

## Data flow

1. Native engines emit context snapshots
2. Flutter receives normalized context events
3. Context events are persisted locally
4. Risk engine computes score
5. Intervention engine decides action
6. User outcome is logged
7. Aggregates and future weights improve

## Rules-first intelligence

V1 should not depend on ML to be useful.

Recommended sequence:

1. rule engine
2. weighted score engine
3. basic calibration
4. model-assisted ranking later

## Performance principles

- event-driven sensing where possible
- avoid constant high-frequency polling
- batch local writes
- compute aggregates lazily
- move heavier calculations off the UI isolate
