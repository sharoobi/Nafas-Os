# Product Requirements Document

## Problem statement

Most quit-smoking apps are weak because they focus on static tracking:

- day counters
- money saved
- generic reminders

They do not intervene at the exact moment the urge becomes actionable.

`Nafas OS` solves this by combining:

- passive context sensing
- just-in-time risk prediction
- rescue interventions
- sensory replacement rituals
- behavioral micro-therapy
- local analytics and experimentation

## Primary user

The first user is a highly motivated personal user who:

- wants deep configuration
- accepts advanced permissions for personal benefit
- values local data ownership
- wants an app that is practical, not motivational fluff
- may have respiratory symptoms and wants correlation insight

## Secondary users

- close friends with similar smoking patterns
- power users who want to tune rules and interventions

## Jobs to be done

1. `When I am about to smoke, help me survive the next 30 to 90 seconds.`
2. `When I smoke, help me log it with near-zero friction so the system learns.`
3. `When I review my behavior, show me why and where I fail.`
4. `When I feel physically worse, show me the behavioral correlation quickly.`
5. `When default logic is not enough, let me tune the system myself.`

## Core feature set

### 1. Onboarding and baseline capture

- cigarettes-per-day baseline
- first cigarette timing
- strongest trigger contexts
- symptom severity baseline
- intervention preference profile
- observation mode activation

### 2. Home

- current risk
- time since last cigarette
- current mode
- quick actions:
  - `I smoked`
  - `I resisted`
  - `I am about to smoke`
  - `Rescue now`

### 3. Rescue

- breathing mode
- ghost cigarette mode
- quick walk task
- water prompt
- sensory ritual mode
- friend SOS placeholder

### 4. Smoking event capture

- trigger tag
- stress level
- context tags
- notes optional
- did the app predict it
- did the user ignore a prior intervention

### 5. Craving event capture

- intensity
- duration
- outcome
- intervention used
- resolved without smoking

### 6. Symptom tracking

- cough severity
- sputum severity
- sputum blood flag
- breathlessness
- chest pain
- wheeze
- sleep disturbance

### 7. Insights

- top trigger windows
- top trigger locations
- delay in first cigarette
- intervention success rates
- symptom correlations
- risk heatmaps

### 8. Lab

- rule builder
- thresholds
- feature toggles
- live sensor visibility
- false positive review
- missed event review
- export/import config

## Success criteria

### Behavioral

- reduced daily cigarette count
- increased time to first cigarette
- increased resisted craving count
- reduced automatic smoking episodes

### Product

- user continues using rescue flows after first week
- logging remains quick enough to be sustainable
- notification aggressiveness stays tolerable
- the system avoids obvious false-positive spam

## Non-functional requirements

- offline-first
- local-only default
- robust without backend
- resilient with missing permissions
- responsive under 1 second for rescue entry
- low perceived friction
- future-proof for modular native engines

## Out of scope for v1

- social community platform
- therapist backend
- cloud accounts
- hidden background camera capture
- always-on covert microphone mode
- medical diagnosis claims
