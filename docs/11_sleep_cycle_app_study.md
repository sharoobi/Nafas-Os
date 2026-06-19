# Sleep Cycle App Study

Date: 2026-04-14
Studied app: `com.northcube.sleepcycle`
Installed version on device: `4.26.06-production`
Device: `SM-N986U`

## Goal

This study documents the installed `Sleep Cycle` app from four angles:

1. Product structure
2. Interaction and visual design
3. Data/analysis model visible from the UI
4. Platform capabilities and permission strategy

The purpose is practical:
extract patterns worth adapting into `Nafas OS`, not to copy the app superficially.

## Evidence Captured

Local device captures:

- `sleep_cycle_study/2026-04-14/01_current.png`
- `sleep_cycle_study/2026-04-14/01_current.xml`
- `sleep_cycle_study/2026-04-14/02_programs.png`
- `sleep_cycle_study/2026-04-14/02_programs.xml`
- `sleep_cycle_study/2026-04-14/03_journal.png`
- `sleep_cycle_study/2026-04-14/03_journal.xml`
- `sleep_cycle_study/2026-04-14/06_after_parallel.png`
- `sleep_cycle_study/2026-04-14/06_after_parallel.xml`
- `sleep_cycle_study/2026-04-14/07_profile_clean.png`
- `sleep_cycle_study/2026-04-14/07_profile_clean.xml`
- `sleep_cycle_study/2026-04-14/08_statistics_sleep_quality.png`
- `sleep_cycle_study/2026-04-14/08_statistics_sleep_quality.xml`
- `sleep_cycle_study/2026-04-14/09_journal_clean.png`
- `sleep_cycle_study/2026-04-14/09_journal_clean.xml`
- `sleep_cycle_study/2026-04-14/10_program_detail.png`
- `sleep_cycle_study/2026-04-14/10_program_detail.xml`

ADB/package inspection:

- `dumpsys package com.northcube.sleepcycle`
- `dumpsys activity activities`

Official references used as interpretation support:

- Sleep Cycle motion detection support docs
- Sleep Cycle Smart Alarm docs
- Sleep Cycle Statistics docs
- Sleep Cycle microphone/privacy docs

## High-Level Product Shape

Bottom navigation:

- `Sleep`
- `Programs`
- `Journal`
- `Statistics`
- `Profile`

This is a disciplined information architecture.
It separates the product into five distinct jobs:

1. Start and run the primary session
2. Consume structured behavior-change content
3. Review time-based logs/events
4. Inspect trends and metrics
5. Configure the product and tracking method

This is important for `Nafas OS`.
We already have overlapping concepts, but Sleep Cycle shows the value of keeping each job visually and cognitively separate.

## Screen-by-Screen Findings

### 1. Sleep

Evidence:

- `01_current.xml`

Visible structure:

- small top `Sleep aid` utility
- one large central time picker
- one secondary concept: wake-up window
- one dominant CTA: `Start`
- compact premium upsell at the bottom

What matters:

- The landing screen is not a dashboard.
- It is a session launcher.
- The screen is optimized for one nightly decision, not for browsing.

Transferable lesson for `Nafas OS`:

- `Home` should show status, but one rescue or protection action must dominate.
- The strongest mode should feel like a launch surface, not a noisy command center.

### 2. Programs

Evidence:

- `02_programs.xml`
- `10_program_detail.xml`

Visible structure:

- editorial cards grouped by user need, not by abstract category
- example titles:
  - `Sleep Coaching with Dr. Mike`
  - `Relax from stress`
  - `Daytime hacks`
  - `Relax the mind`
- detail page has:
  - hero/title
  - progress label like `1/3 COMPLETED`
  - clear description
  - related sub-modules

What matters:

- Sleep Cycle does not rely only on passive sensing.
- It also provides curated intervention content.
- The content is organized as guided programs, not raw articles.

Transferable lesson for `Nafas OS`:

- `Rescue` should not be a flat toolbox only.
- Add structured “missions/programs” such as:
  - after work recovery
  - driving shield
  - reels detox
  - post-meal reset
  - relapse recovery

### 3. Journal

Evidence:

- `09_journal_clean.xml`

Visible structure:

- day/date anchor at top
- week strip / day selector
- one primary night summary
- sleep quality ring
- timeline graph with events
- labeled sound/event entries such as `Talking`
- summary metrics like `In bed`, `Asleep`

What matters:

- Journal is not a raw list.
- It is a contextual event timeline centered on a single session/day.
- It combines summary, event markers, and drillable annotations.

Transferable lesson for `Nafas OS`:

- Our timeline should move toward “contextual day replay”.
- Each day should show:
  - risk windows
  - cravings
  - rescues
  - slips
  - symptom markers
  - digital triggers
- Not just a chronological list of logs.

### 4. Statistics

Evidence:

- `06_after_parallel.xml`
- `08_statistics_sleep_quality.xml`

Visible structure:

- title
- period selector: `Days / Weeks / Months / All`
- cards per metric with `More`
- drilldown page for `Sleep quality`
  - explanatory copy
  - chart
  - period selector
  - benchmark comparison
  - follow-on insight section

Visible metrics from UI/support docs:

- `Sleep quality`
- `Regularity`
- plus official docs mention additional indicators

What matters:

- Statistics are layered.
- First level: summary metrics
- Second level: focused drilldown
- Third level: explanation and benchmark framing

Transferable lesson for `Nafas OS`:

- `Insights` should not remain one long analytics screen.
- It should become:
  - overview cards
  - period switcher
  - drilldown pages
  - explanation blocks
  - “why this matters” copy

### 5. Profile

Evidence:

- `07_profile_clean.xml`

Visible structure:

- top summary metrics:
  - `Nights`
  - `Avg. Quality`
  - `Avg. time`
  - `Backup`
- settings grouped as clear, high-impact rows:
  - `Sleep Goal`
  - `Sound`
  - `Wake up phase`
  - additional rows under `More`
- `Premium` section separated lower in the hierarchy

What matters:

- Profile is not a generic settings dump.
- It uses summary + a small number of behavior-critical settings.
- Complexity is pushed into `More`, keeping the main profile clean.

Transferable lesson for `Nafas OS`:

- Our settings/profile should split into:
  - behavior profile
  - protection profile
  - advanced lab
- Core behavioral levers should be short and visible.
- Technical controls should remain in `Lab`, not pollute primary settings.

## Design and UX Patterns Worth Reusing

### 1. One-primary-action discipline

Sleep Cycle keeps the main action obvious.
It avoids making the user decide among too many equal-weight actions on entry.

For `Nafas OS`:

- on `Home`, one rescue/protection CTA should dominate based on current state
- the rest should be secondary

### 2. Calm, non-chaotic visual hierarchy

The app is visually soft:

- large whitespace
- low element count
- strong typography hierarchy
- focused cards
- minimal overload

For `Nafas OS`:

- keep the nervous system calm first
- avoid turning the app into a surveillance dashboard
- use intelligence, but present it softly

### 3. Progressive drilldown

Sleep Cycle does not show every metric at once.
It shows:

1. a summary
2. a metric family
3. a deeper explanation page

For `Nafas OS`:

- build drilldowns for:
  - trigger chains
  - places
  - apps
  - rescues
  - slips

### 4. Guided programs, not only tools

This is one of the strongest product patterns.

For `Nafas OS`:

- rescue tools remain important
- but add programmatic flows with progress and completion state

### 5. Session-centric journaling

Sleep Cycle treats one night as a coherent unit.

For `Nafas OS`:

- treat one day as a coherent behavioral unit
- add replay and interpretation, not only raw logs

## Technical and Permission Findings

From package inspection on the installed app:

- runtime-granted:
  - `RECORD_AUDIO`
  - `ACTIVITY_RECOGNITION`
  - `ACCESS_COARSE_LOCATION`
  - `POST_NOTIFICATIONS`
- requested:
  - `SYSTEM_ALERT_WINDOW`
  - `RECEIVE_BOOT_COMPLETED`
  - `USE_EXACT_ALARM`
  - multiple foreground service types
- services/components indicate:
  - active analysis service
  - alarms
  - boot restoration
  - WorkManager / system job strategy

Interpretation:

- The product mixes real-time sensing with scheduled wake/analysis behavior.
- It uses explicit permissions tied to clear user value.
- It supports both microphone-based and motion-based tracking modes.

For `Nafas OS`:

- this validates our hybrid strategy:
  - explicit sensor sessions
  - scheduled follow-ups
  - boot recovery
  - local processing

## Official Sleep Cycle Behaviors Confirmed

Based on official support material:

- microphone tracking is the recommended mode because it captures more signals than accelerometer-only tracking
- the app can also operate with accelerometer-based tracking
- smart alarm uses a user-controlled wake window and wakes in a lighter phase when possible
- Statistics officially support drilldowns across multiple time scales
- sound recordings are stored locally by default
- the product uses user labeling to improve certain sound-related features such as `Who’s Snoring?`

Why this matters for `Nafas OS`:

- the strongest pattern is not “collect everything secretly”
- the strongest pattern is:
  - explicit sensing mode
  - locally useful analysis
  - meaningful drilldowns
  - user labeling to improve future inference

## What Sleep Cycle Does Better Than Most Apps

1. It turns hard sensing into a simple user ritual.
2. It keeps the core flow obvious.
3. It separates behavior programs from raw analytics.
4. It uses logs, trends, and settings without making the app feel technical.
5. It presents analysis as something interpretable, not only measurable.

## Direct Product Implications for Nafas OS

### Changes we should make next

1. Add a `Programs`/`Missions` surface, not only ad-hoc rescue cards.
2. Rework `Timeline` into a day-centric replay model.
3. Rework `Insights` into summary cards + drilldown detail pages.
4. Expand `Profile` into a clearer behavior profile with a short top summary.
5. Expose audio verdicts and confidence in a human-readable way, like Sleep Cycle exposes sound events and sleep-quality explanations.

### Things we should not copy

1. A sleep app’s exact metric language
2. Overly passive UX for crisis moments
3. Any nighttime-only assumptions

`Nafas OS` is not a tracker-only product.
It must intervene faster and more actively than Sleep Cycle.

## Recommended Nafas OS Adaptation Plan

### Short-term

- add richer rescue verdict card
- add profile flow with concise top-level behavior settings
- add period switcher and drilldown structure in insights

### Mid-term

- add `Programs` tab or section with structured rescue programs
- add day replay timeline
- add better audio/session labeling

### Longer-term

- train a true on-device audio model
- use explicit user labeling to improve future inference
- deepen Samsung/OEM background resilience

## Sources

- Sleep Cycle support: How motion detection works
  - https://support.sleepcycle.com/hc/en-us/articles/10977968179100-How-our-motion-detection-works
- Sleep Cycle support: Microphone, why is it recommended?
  - https://support.sleepcycle.com/hc/en-us/articles/208030925-Microphone-why-is-it-recommended
- Sleep Cycle support: What is the Smart Alarm Clock?
  - https://support.sleepcycle.com/hc/en-us/articles/7858323091356-What-is-the-Smart-Alarm-Clock
- Sleep Cycle support: What is Statistics?
  - https://support.sleepcycle.com/hc/en-us/articles/7856720203676-What-is-Statistics
- Sleep Cycle support: How does the app calculate Sleep Quality?
  - https://support.sleepcycle.com/hc/en-us/articles/206704659-How-does-the-app-calculate-Sleep-Quality
- Sleep Cycle support: Do you store any sound?
  - https://support.sleepcycle.com/hc/en-us/articles/206704689-Do-you-store-any-sound
- Sleep Cycle support: Why is it asking me for permission to use the microphone when I start an alarm?
  - https://support.sleepcycle.com/hc/en-us/articles/207392665-Why-is-it-asking-me-for-permission-to-use-the-microphone-when-I-start-an-alarm
- Sleep Cycle support: How does `Who’s Snoring?` work?
  - https://support.sleepcycle.com/hc/en-us/articles/9189599693074-How-does-Who-s-Snoring-work
