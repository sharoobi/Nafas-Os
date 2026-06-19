# Execution Plan

## Delivery strategy

Build `Nafas OS` as a sequence of usable slices, not as a giant speculative shell.

## Phase 0: Foundations

Deliverables:

- project scaffold
- package identity
- design tokens
- routing skeleton
- state management setup
- local storage setup
- fake data mode

## Phase 1: Personal MVP

Deliverables:

- onboarding
- home
- rescue
- smoking log
- craving log
- symptom log
- simple rules engine
- local notifications
- insights v1

Success condition:

- the app is genuinely usable for daily personal testing

## Phase 2: Context intelligence

Deliverables:

- location clusters
- activity recognition
- bluetooth/car context
- post-meal/coffee windows
- smarter rescue selection

Success condition:

- risk windows become meaningfully personal

## Phase 3: Lab and tuning

Deliverables:

- thresholds
- feature flags
- rule builder
- logs viewer
- replay
- export/import config

Success condition:

- the user can shape the engine without code changes

## Phase 4: Guarded audio

Deliverables:

- explicit audio session mode
- local audio feature extraction experiments
- audio-trigger-informed rescue

Success condition:

- the product gains another real signal source without becoming invasive

## Phase 5: Personal ML

Deliverables:

- model snapshots
- feature importance
- local retraining flow
- prediction quality review

Success condition:

- the engine starts adapting beyond rules

## Initial technical stack

- Flutter 3.41.6
- Dart 3.11.4
- Riverpod
- GoRouter
- Freezed
- Isar or Drift
- flutter_local_notifications
- permission_handler
- geolocator
- sensors_plus as a bootstrap layer
- Pigeon for native bridges

## Short-term implementation order

1. scaffold app
2. install packages
3. wire theme and router
4. create feature shells
5. create local models
6. create fake repositories
7. build onboarding and home
8. build rescue flows
9. build logging flows
10. build first insight and lab slices

## Definition of done for the current round

- docs exist and are coherent
- app scaffold exists
- design system exists
- routes exist
- first features render
- analyze passes
- baseline tests pass
