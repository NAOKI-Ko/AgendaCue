# WU-09-05 Automated Evidence

Environment: Xcode 26.6 (17F113), iOS SDK 26.5, iPhone 17 Pro Simulator.

## Verification

- XCTest: 160 passed, 0 failures.
- Specific iPhone 17 Pro Simulator Debug build: PASS.
- Generic iOS Simulator Debug build: PASS.
- Generic iOS Device Debug build with code signing disabled: PASS.
- Scope audit: no domain rule, alarm date, identity, lifecycle, reconciliation, background, calendar-write, target, entitlement, or dependency expansion.

## Presentation contract

- Nonblank source event title is passed unchanged to AlarmKit presentation.
- Blank or whitespace-only source title falls back to `予定`.
- No prefix, suffix, or internal identifier is added.

## Visual matrix

1. `01-onboarding-light.png` — welcome, light.
2. `02-onboarding-dark.png` — welcome, dark.
3. `03-onboarding-large.png` — welcome, Large Dynamic Type.
4. `04-onboarding-accessibility-xxxl.png` — welcome, Accessibility XXXL with scrolling.
5. `05-calendar-rationale.png` — Calendar rationale, not determined.
6. `06-alarm-rationale.png` — Alarm rationale, not determined.
7. `07-calendar-denied.png` — Calendar denial guidance and continuation.
8. `08-alarm-denied.png` — Alarm denial guidance and completion.
9. `09-completed-alarm-tab.png` — completed first launch, normal Alarm tab.
10. `10-alarm-screen.png` — populated Alarm timeline.
11. `11-settings-permission-state.png` — normal Settings permission state.
12. `12-event-detail-shell.png` — normal Event Detail shell.

Screenshots are Simulator/static evidence only. Accessibility Inspector, real VoiceOver order, system permission prompts, permission restoration, signed-device AlarmKit presentation/firing, and physical-device visual review were not automated.

Human Gate: **OWNER WAIVED / DEFERRED TO WU-10**. No human/device item is marked passed.
