# Decision Log

## Confirmed decisions

### D-001

Use `Flutter shell + native capability engines`.

Reason:

- best mix of UI velocity and platform depth

### D-002

No backend in v1.

Reason:

- local-first personal product
- simpler privacy model
- faster iteration

### D-003

Use `rules-first` intelligence before depending on ML.

Reason:

- works with sparse early data
- easier to debug
- easier to trust

### D-004

Use progressive permissions.

Reason:

- lower friction
- better trust
- less breakage

### D-005

Do not build the product around covert camera usage.

Reason:

- platform reality
- reliability
- privacy

### D-006

Microphone features are explicit-session features, not always-on by default.

Reason:

- platform constraints
- battery
- trust

### D-007

Keep an internal `Lab` from the beginning.

Reason:

- this product needs tuning
- the target user wants control

## Open decisions

### O-001

Choose between `Isar` and `Drift`.

Current leaning:

- `Isar` for speed and simpler local-first iteration

### O-002

Choose initial animation stack.

Current leaning:

- use native Flutter animation primitives first
- add `Rive` selectively for rescue hero visuals

### O-003

Choose exact native bridge split.

Current leaning:

- a single bridge package first
- split into multiple federated internal modules only when native surface grows
