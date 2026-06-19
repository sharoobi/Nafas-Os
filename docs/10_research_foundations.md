# Research Foundations for Nafas OS

## Purpose

This note captures the external product and technical patterns used to shape the next phase of `Nafas OS`.

The goal is not to copy another app mechanically. The goal is to extract repeatable patterns from:

- adaptive sensing products such as Sleep Cycle
- JITAI style intervention research
- Android and iOS platform constraints for background sensing and recovery

## 1. What apps like Sleep Cycle get right

### Multi-signal sensing, not one signal

The Sleep Cycle Android SDK documentation describes a sensing model that combines audio and motion rather than depending on a single trigger source. It also exposes real-time events, breathing-rate updates, audio-health monitoring, and session resume behavior.

Source:
- https://sdk.sleepcycle.com/android

Implication for Nafas OS:
- `Nafas OS` should not depend on one fragile cue such as lighter sound.
- The stronger model is:
  - passive context
  - explicit short audio sessions
  - runtime health checks for the audio path
  - resumable local sessions and state recovery

### Foreground work must be explicit

Sleep Cycle’s Android SDK documentation also makes the operational point clearly: continuous analysis on Android must be hosted in a foreground service with the right service types, and session resumption matters after interruption.

Source:
- https://sdk.sleepcycle.com/android

Implication for Nafas OS:
- use explicit, user-started guarded audio sessions
- keep always-on sensing lightweight
- use restart-safe scheduling and resumable local state instead of pretending background audio can run forever

## 2. JITAI principles that matter here

The broader JITAI direction in digital health is to deliver the right intervention at the right time using momentary context rather than generic reminders.

Useful background source:
- https://pure.manchester.ac.uk/ws/portalfiles/portal/1574773670/FULL_TEXT.PDF

Implication for Nafas OS:
- the main product loop should remain:
  - sense context
  - estimate near-term risk
  - choose one small intervention
  - capture the outcome
  - adapt the next decision

This supports several design decisions already in the app:
- quick manual check-ins
- rescue missions instead of long flows
- context-aware intervention choice
- confidence-based follow-up scheduling

## 3. Android background constraints that shape the architecture

Android background work is constrained. Alarm delivery, foreground services, and long-running access to sensors all need to be justified and implemented within the platform’s rules.

Official references:
- https://developer.android.com/develop/background-work/services/alarms
- https://developer.android.com/develop/background-work/services/foreground-services

Implication for Nafas OS:
- use `AlarmManager` for durable follow-up reminders
- reschedule on `BOOT_COMPLETED`
- avoid promising invisible continuous capture that the OS will eventually kill
- keep “deep” sensing in explicit modes and keep passive sensing cheap

## 4. Activity recognition should be event-driven where possible

Google’s activity-recognition model is built around detected movement states and transitions, which is a better fit than constant polling for many behavior-change use cases.

Reference:
- https://developers.google.com/location-context/activity-recognition/transitions

Implication for Nafas OS:
- prefer activity transitions such as:
  - in vehicle
  - walking
  - still
- store the last known transition state locally
- combine that state with speed, route, and Bluetooth context rather than trusting one stream alone

## 5. iOS motion and background realities

Apple’s motion stack is centered on managed activity streams rather than unconstrained background sensing.

Official reference:
- https://developer.apple.com/documentation/coremotion/cmmotionactivitymanager

Implication for Nafas OS:
- the shared product design must remain:
  - context-first
  - session-based when deeper sensing is needed
  - local and resumable
- camera and microphone should stay explicit and user-started on iOS as well

## 6. Product decisions reinforced by the research

The research and platform review support these choices:

1. `Rules + local adaptation` remains the correct first architecture.
2. `Guarded audio` should evolve from amplitude-only to pattern-aware heuristics and later to a local classifier.
3. `Activity transitions + Bluetooth route inference + speed` is stronger than any one source alone.
4. `Persistent follow-up after reboot` is useful and realistic; permanent invisible capture is not.
5. `Short rescue missions` fit JITAI logic better than long coaching flows in the critical moment.

## 7. Near-term engineering implications

Based on this review, the next slices of Nafas OS should prioritize:

1. richer activity context through transition monitoring
2. richer Bluetooth and audio-route classification
3. explicit reboot-safe scheduling verification
4. profile editing so the prediction model reflects the real user baseline
5. stronger guarded-audio feature extraction before any full classifier work

## 8. What is still intentionally deferred

The following remain intentionally deferred because they need real data or a narrower experimental loop:

- a trained audio classifier with labeled smoking-session data
- always-on microphone sensing
- covert camera logic
- heavyweight background inference loops that are likely to be killed by the OS

That is deliberate engineering discipline, not missing ambition.
