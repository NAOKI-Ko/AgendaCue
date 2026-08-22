# WU-10 Phase B.4 — Final App Store Screenshots

Audit date: 2026-08-22.

## Candidate and capture environment

1. Branch: `wu-10-release-gate`.
2. Accepted UI candidate: `50fc6258384f0ac80cc88661132dbec1a7bca2da`.
3. Simulator: iPhone 17 Pro Max (`F9006C43-A464-4C67-9B9E-D564B1975BC6`).
4. Runtime: iOS 26.5.
5. Language/locale: Japanese / `ja_JP`.
6. Appearance/text size: Light / standard Large.
7. Build: one Debug Simulator build from the exact accepted UI candidate. DEBUG-only allowlisted scenarios supplied deterministic presentation data; no debug/test/sample labels are visible.

## Final package

Location: `docs/release/screenshots/final-ja/`. Count: exactly six raw screenshots.

| Order | File | Screen | Dimensions / format | SHA-256 |
|---|---|---|---|---|
| 01 | `01.jpg` | Alarm Timeline, selected `アラーム` tab | 1320×2868 JPEG, RGB, no alpha | `c2da797f76904cb05065bd3fd65589dd93129ba789465224b9bcc0ce03b7bebf` |
| 02 | `02.jpg` | Event Detail / Default Lead | 1320×2868 JPEG, RGB, no alpha | `4948756f351771044e33f1a11cbaa1fef7c5697ce39ee2a68ddade3bed1f02fb` |
| 03 | `03.jpg` | Event Detail / Custom Lead | 1320×2868 JPEG, RGB, no alpha | `78f8e4c40bd146e2743ab96e108ec03a2783c0ce92e8eb30d1bca1e7abcc1e06` |
| 04 | `04.jpg` | Multi-Date Timeline | 1320×2868 JPEG, RGB, no alpha | `4b502f8a3aac4fcc7c85df20d56fd5f7ac12a96b5ab029d7d2d1e7a8102fbeec` |
| 05 | `05.jpg` | Calendar Selection | 1320×2868 JPEG, RGB, no alpha | `b65330e4dee884f180228bc24c5e8b4061129799ce2b22b239a2d721f7d1581e` |
| 06 | `06.jpg` | Settings | 1320×2868 JPEG, RGB, no alpha | `a7753ff8dbc496a12af1c3343349c68a6b04c43f54a53164f781ac98155d5faa` |

`file` and `sips` independently confirmed baseline JPEG, 1320×2868 portrait dimensions, RGB color, three components, and no alpha for all six images. Hash uniqueness confirms there are no duplicate files. Visual inspection confirmed no accidental crop, clipping, Simulator window chrome, marketing decoration, debug artifacts, or empty/awkward composition.

## Visual and privacy audit

- `01` immediately presents the core Today-first alarm timeline, selected Alarm tab, an ended earlier-today event, actual current-time divider, two upcoming-today events and readable alarm times.
- `02` presents the same generic `チーム定例` event with alarm enabled and the default five-minute lead state.
- `03` presents that event with alarm enabled and a distinct 15-minute per-event override.
- `04` expands the same synchronized timeline to Today, Tomorrow, and August 25; it contains no yesterday or older section.
- `05` shows synthetic `仕事` and `プライベート` calendars under device calendar sources with clear selection controls. The display does not imply direct provider API integration.
- `06` shows default lead time, calendar selection entry, current permission states, and local/read-only product explanation.
- All event, calendar, and source content is deterministic synthetic data. No real events, locations, personal account names, email addresses, phone numbers, secrets, or private identifiers appear.

## Timeline and sticky-header confirmation

The final timeline images begin with Today and contain only Today/future dates. Earlier-today content remains visible, upcoming content follows the real current-time divider, and no historical section was manufactured. A separate Accessibility Dynamic Type QA launch forced the real `LazyVStack` header into its pinned state: the date header and navigation transition region remained opaque, with no content bleed, transparent/translucent gap, seam, flash, or vertical jump. That QA image is temporary and is not part of the App Store package.

## Source freeze and repository status

- Production Swift/Xcode project/configuration diff: **NONE**.
- Changed content is limited to the six final screenshots and release/evidence documentation.
- Screenshot/evidence commit: the single commit containing this document; exact SHA is recorded in the final handoff because a commit cannot embed its own hash.
- Working tree: clean after that commit.
- Push: not performed.
- Merge: not performed.
- Tag: not performed.
- Distribution archive/IPA regeneration: not performed. The B.2 IPA remains stale.
- Upload: not performed.
- Submission: not performed.

**FINAL APP STORE SCREENSHOTS CAPTURED**  
**OWNER VISUAL APPROVAL PENDING**
