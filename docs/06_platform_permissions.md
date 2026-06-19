# Platform, Permissions, and Constraints

## Core principle

Build around real platform capabilities, not imagined covert behavior.

## Android strategy

Likely permission and capability set over time:

- notifications
- location
- activity recognition
- bluetooth
- microphone for explicit guarded sessions
- camera for explicit guided modes

Likely native capabilities:

- foreground service where justified
- geofencing
- activity transitions
- motion sensors
- local notifications

## iOS strategy

Likely capability set:

- notifications
- location
- motion
- bluetooth where needed
- microphone for explicit sessions
- camera for guided modes

## Progressive permissions

Do not ask everything on first launch.

Sequence:

1. notifications
2. basic usage without advanced context
3. activity and location once value is clear
4. bluetooth when car/drive mode is enabled
5. microphone only when guarded audio sessions are enabled
6. camera only when mirror or posture mode is enabled

## Camera policy

Do not center the product around covert camera usage.

Valid camera roles:

- mirror interruption
- guided breathing posture
- manual cough/self-check support

## Microphone policy

Do not assume always-on audio capture.

Use microphone as:

- explicit guarded session
- driving guard
- coffee guard
- short high-risk monitoring window

## Privacy model

- local-only by default
- explicit control for sensitive sensors
- raw data retention controls
- exportable local data
- removable local data

## Degradation rules

If a permission is denied:

- the app still works
- the app switches to simpler rescue and logging flows
- the lab shows what intelligence is unavailable

## Respiratory safety note

The app may support symptom tracking and behavioral correlation, but must not present itself as a medical diagnosis system.
