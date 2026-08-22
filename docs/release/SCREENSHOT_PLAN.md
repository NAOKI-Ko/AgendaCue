# AgendaCue Japanese App Store Screenshot Plan

The Phase A.5 source set was captured on an iPhone 17 Pro Max Simulator, iOS 26.5, Japanese UI, Light appearance, default text size. Files are 1320×2868 portrait JPEG, RGB/no-alpha, matching Apple's [6.9-inch screenshot specification](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/). The target is iPhone-only (`TARGETED_DEVICE_FAMILY = 1`), so no iPad source set is required by the current target configuration. Do not fabricate system permission or AlarmKit UI.

1. **現在と次の予定** — `アラーム` timeline centered on the current divider and first future alarm. Caption candidate: `次の予定とアラーム時刻をひと目で`.
2. **複数日の予定** — past/today/future date sections. Caption: `過去14日から今後14日まで、日付ごとに確認`.
3. **予定の詳細・標準** — alarm ON and inherited five-minute lead. Caption: `予定ごとにアラームを確認`.
4. **予定の詳細・変更** — supported custom lead time. Caption: `必要な予定だけ、時間を変更`.
5. **カレンダー選択** — iCloud/Google-like source names may be shown only as controlled sample data. Caption: `使うカレンダーを選択`.
6. **設定** — default lead, permissions, local/read-only explanation. Caption: `シンプルな設定と分かりやすい権限状態`.
7. **オンボーディング（任意）** — use only if owner finds the privacy/read-only promise valuable. Caption: `カレンダーは読み取り専用で利用`.

Use `AgendaCue` consistently anywhere the installed app name is visible. Avoid debug/feasibility controls, internal IDs, permission error screens as hero images, private calendar content, fake system dialogs, fake AlarmKit presentation, guaranteed-delivery language, and direct-provider claims. The raw Phase A.5 files contain no baked marketing text. Final ordering/copy and App Store Connect acceptance remain owner decisions.

## Phase A.7A final package

Six raw captures were finalized without recompression or marketing overlays:

1. `01_alarm_timeline.jpg` → `final-ja/01.jpg`
2. `03_event_detail_default.jpg` → `final-ja/02.jpg`
3. `04_event_detail_custom.jpg` → `final-ja/03.jpg`
4. `02_alarm_timeline_dates.jpg` → `final-ja/04.jpg`
5. `05_calendar_selection.jpg` → `final-ja/05.jpg`
6. `06_settings.jpg` → `final-ja/06.jpg`

All are 1320×2868 portrait JPEG, RGB/no-alpha, and byte-identical to the visually inspected sources. `07_onboarding.jpg` remains an accepted source but is not selected because the six operational screens already provide a stronger complete product story.
