# WU-16 Visual Evidence

Work Unit: **WU-16 — App Review 5.1.1(iv) Permission CTA Correction**

Environment: Xcode 26.6 (17F113), iPhone 17 Pro Simulator, iOS 26.5, Debug configuration, Light appearance, 1206×2622 PNG captures.

## Evidence

| File | Locale | Screen | Expected CTA | Result |
|---|---|---|---|---|
| `ui/01-ja-calendar-pre-permission.png` | Japanese | Calendar custom pre-permission explanation | `続ける` | PASS |
| `ui/02-en-calendar-pre-permission.png` | English | Calendar custom pre-permission explanation | `Continue` | PASS |
| `ui/03-ja-alarm-pre-permission.png` | Japanese | Alarm custom pre-permission explanation | `続ける` | PASS |
| `ui/04-en-alarm-pre-permission.png` | English | Alarm custom pre-permission explanation | `Continue` | PASS |

SHA-256:

- `01-ja-calendar-pre-permission.png`: `3fe430e683ddcf1e8c62b373a1170aab59effeef9784af099d9a5ad444c59832`
- `02-en-calendar-pre-permission.png`: `f84398271dc5d7fba9816d5a479574f7b5b021007a8709946eedb6741ee8a09e`
- `03-ja-alarm-pre-permission.png`: `005e8ed3809022be9121ceb4b010cf237b8fa1139ca787b51809111a52ecdeb9`
- `04-en-alarm-pre-permission.png`: `f1d6f2b2371db9fea07d624ac761e6b341fb6e9c8b7b8549ecf66b29d7cdecce`

All four captures were inspected directly. CTA copy is correct and fully visible; no truncation, overlap, horizontal overflow, OS-alert imitation, arrow, or additional permission-grant instruction is present. Existing explanatory copy remains intact, and button prominence/layout is unchanged apart from the shorter label.

## Functional boundary

Static flow inspection confirms the unchanged path from the custom button through `continueCalendarOnboarding()` / `continueAlarmOnboarding()` to the existing EventKit `requestFullAccessToEvents()` / AlarmKit `requestAuthorization()` providers. The complete XCTest suite covers not-determined, authoritative refresh, denial, already-authorized, and Settings-recovery policies.

The screenshots prove the custom UI state immediately before the system request. Physical-device native Calendar/AlarmKit dialog presentation and the user's independent allow/deny choice are **DEVICE_VERIFICATION_DEFERRED** and are not claimed by this Simulator evidence. Existing H01–H46 remain unpassed.
