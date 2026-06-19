# Data, Rules, and ML Plan

## Local-first data policy

All important product intelligence should work from local data only.

Default assumptions:

- no backend
- no cloud sync
- no third-party analytics
- no raw audio upload

## Core entities

### UserProfile

- baseline cigarettes per day
- wake/sleep approximations
- high-risk contexts
- intervention preferences
- symptom sensitivity

### SmokingEvent

- timestamp
- trigger tag
- context tags
- stress and mood
- preceded by prediction
- intervention shown

### CravingEvent

- intensity
- duration
- resolved without smoking
- intervention used
- predicted or manual

### InterventionEvent

- type
- score at trigger
- accepted
- completed
- success rating

### SensorSnapshot

- time features
- location cluster
- motion/activity state
- bluetooth state
- screen state
- charging state

### SymptomLog

- cough
- sputum
- blood flag
- breathlessness
- chest pain
- wheeze
- sleep disruption

### RuleConfig

- enabled
- conditions json
- weight
- cooldown
- priority

### ModelSnapshot

- version
- feature map
- weights
- metrics

## Rules engine

Use editable rules first.

Example classes:

- morning window rules
- coffee-linked rules
- driving rules
- post-meal rules
- stress escalation rules
- rescue preference rules

## Scoring model

Start with weighted scoring, not full ML dependency.

Example dimensions:

- time risk
- location risk
- activity risk
- recent history risk
- coffee/post-meal risk
- driving risk
- stress risk
- symptom modifier

## ML strategy

### V1

- no production-critical ML dependency
- local feature extraction
- rule score plus historical success weighting

### V2

- lightweight on-device model
- personal ranking of intervention choice
- calibration and threshold adjustment

## Lab controls

The app must expose:

- threshold sliders
- enabled feature list
- rule toggles
- weight editor
- event replay
- export/import of config

## Analytics outputs

- top trigger windows
- top trigger locations
- most effective intervention
- false positive clusters
- missed smoke clusters
- symptom correlation trends
