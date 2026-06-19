# UX/UI System

## Product tone

The interface should feel:

- calm
- intelligent
- reassuring
- deeply intentional

It should not feel:

- alarmist by default
- childish
- moralizing
- cluttered

## Design language

### Visual direction

- dark graphite base
- teal/cyan/emerald highlights
- muted amber for caution
- muted red only for severe health alerts
- rounded geometry
- controlled glass and blur
- subtle depth, not heavy neon

### Motion direction

- breathing-like pulses
- gentle radial transitions
- haptics aligned with inhale/exhale
- small reward confirmations
- no chaotic motion

## Navigation

Recommended bottom navigation:

- Home
- Rescue
- Timeline
- Insights
- Lab

Settings can be entered from Home and Lab.

## Core screens

### Home

Purpose:

- answer `what state am I in now`
- allow immediate action

Core blocks:

- risk ring
- time since last cigarette
- next vulnerable window
- quick actions
- symptom mini-card

### Rescue

Purpose:

- get the user from urge to control fast

Core modules:

- breath orb
- ghost cigarette
- walk now
- drink water
- urge labeling

### Timeline

Purpose:

- reveal the sequence of smoke, craving, rescue, and symptom events

### Insights

Purpose:

- show patterns, not just counts

### Lab

Purpose:

- let the user shape the engine

Style:

- more technical
- live panels
- toggles
- charts
- logs

## Hero interaction: Craving wave

When risk becomes high:

1. a focused entry appears fast
2. a breathing-centered screen opens
3. the user chooses a rescue mode
4. the session ends with:
   - `I resisted`
   - `I smoked`
   - `I need another tool`

## Key custom components

- `RiskRing`
- `BreathOrb`
- `RescueActionCard`
- `GhostCigarettePanel`
- `TriggerChipRow`
- `InsightCard`
- `SymptomSeverityBar`
- `RuleEditorTile`
- `LiveMetricPanel`

## Accessibility

- reduced motion mode
- high contrast mode
- larger text support
- haptic-only rescue option
- audio-off safe mode

## Psychological UX rules

- do not shame failure
- capture failure quickly and neutrally
- rescue starts within one or two taps
- every success gets lightweight reinforcement
- do not interrupt with noise unless confidence is high

## Style references for this project

From `ui-ux-pro-max`, the most relevant patterns here are:

- calm dark glassmorphism
- health utility clarity
- focused micro-animation
- strong touch affordance
- one primary action per screen

## Copy style

Preferred:

- `Stay with me for 45 seconds.`
- `This is a known trigger window.`
- `The wave passes. Breathe first.`

Avoid:

- guilt-heavy warnings
- overdramatic fear copy
- noisy gamified language during respiratory alerts
