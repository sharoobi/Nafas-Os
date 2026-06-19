# Product Vision

## Product identity

- Name: `Nafas OS`
- Tagline: `It reaches the urge before the cigarette.`
- Package target: `com.nafas.sharoobi`

## Core thesis

Smoking is usually preceded by a recognizable behavioral signature:

- a time window
- a place
- a body state
- a social state
- a device usage pattern
- a ritual expectation

`Nafas OS` exists to detect that pre-smoking signature and break the loop:

`trigger -> urge -> act -> temporary relief`

The product does not fight the cigarette after ignition. It aims to break the seconds and minutes before ignition.

## Product promise

The app should not tell the user:

- `Do not smoke`

It should tell the user:

- `You are entering a known danger window. Stay with me for 45 seconds.`

## User outcomes

Within the first 2 to 6 weeks, the system should help the user:

- delay the first cigarette of the day
- reduce impulsive cigarettes
- identify top trigger contexts
- build a personal intervention profile
- correlate smoking with symptoms and stress
- replace some smoking rituals with lower-harm alternatives

## Product philosophy

### Behavioral

- No blame
- No moralizing
- Fast rescue beats long lectures
- Sensory replacement is part of treatment, not decoration
- A resisted craving matters more than a streak badge

### Engineering

- Local-first
- Privacy by default
- Rules before ML
- Fast failover when permissions are missing
- Native capability where platform depth matters

### Design

- Calm and intentional
- Soft but precise
- Therapeutic without becoming clinical by default
- Only escalate visually when symptom risk is high

## Product pillars

1. `Prediction`
   The system scores context and estimates craving/smoking likelihood.

2. `Intervention`
   The system responds quickly with the right rescue mechanism.

3. `Replacement`
   The system offers a sensory and behavioral ritual alternative.

4. `Reflection`
   The system helps the user understand patterns and outcomes.

5. `Adaptation`
   The system improves with logs, context, and experiments.

## Strategic scope

### V1

- Personal use
- Offline only
- No cloud sync
- No accounts
- No social feed
- No backend

### V2+

- Optional encrypted backup
- Optional clinician or coach workflows
- Optional accessory pairing
- Optional collaborative support

## Product risks to avoid

- Building around impossible background camera assumptions
- Excessive notification fatigue
- Overengineering ML before rules prove value
- Trying to do medical diagnosis in v1
- Creating a guilt-heavy experience that users abandon
