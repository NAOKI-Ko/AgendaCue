# WU-10 Required Human Gate Checklist

Owner execution is required after App Review approval and before public release. Candidate identity is AgendaCue / `com.naoki-ko.agendacue`. Record `PASS`, `FAIL`, or justified `N/A`; attach evidence references and notes. Do not reuse evidence after the candidate SHA changes.

H01–H46 status: **DEFERRED BY OWNER TO POST-REVIEW / PRE-RELEASE VALIDATION — NOT PASS**. Codex has not executed or prefilled any physical-device result. This gate does not block App Review submission under explicit owner policy.

| ID | Scenario | Setup | Steps | Expected | Result | Evidence | Notes |
|---|---|---|---|---|---|---|---|
| H01 | Fresh install | Delete app/data on real iPhone | Install signed RC and launch | Installed/displayed app name is `AgendaCue`; Calendar rationale appears first with no stale state or preceding Welcome page | PENDING | — | Deferred to post-review / pre-release owner validation |
| H02 | Calendar-first onboarding | H01 | Review Calendar rationale | Approved rationale is readable and Calendar is the first onboarding stage | PENDING | — | Deferred to post-review / pre-release owner validation |
| H03 | Calendar rationale | Calendar permission not determined | Read screen before action | Japanese rationale precedes system prompt | PENDING | — | — |
| H04 | Calendar permission allow | H03 | Request and allow full calendar access | App records authorized and advances | PENDING | — | — |
| H05 | Alarm rationale | Alarm permission not determined | Read screen before action | Japanese rationale precedes system prompt | PENDING | — | — |
| H06 | Alarm permission allow | H05 | Request and allow | Onboarding completes; normal app opens | PENDING | — | — |
| H07 | Calendar denied path | Fresh install/reset permission | Deny Calendar and continue | No trap; completion remains possible; recovery clear | PENDING | — | — |
| H08 | Alarm denied path | Calendar step completed | Deny Alarm and finish | No trap; normal recovery UI appears | PENDING | — | — |
| H09 | Revoked Calendar recovery | Completed onboarding | Revoke Calendar in Settings; reopen app | Onboarding does not replay; Settings recovery shown | PENDING | — | — |
| H10 | Revoked Alarm recovery | Completed onboarding | Revoke Alarm; reopen app | Onboarding does not replay; recovery shown; no active claim | PENDING | — | — |
| H11 | iCloud events load | iCloud Calendar with safe test event | Authorize, select source, foreground app | Event title/time appears accurately | PENDING | — | — |
| H12 | Google events load | Google account added to iOS Calendar | Select Google calendar and refresh | EventKit-visible Google event appears | PENDING | — | — |
| H13 | Other EventKit source | Optional configured source | Select and foreground app | Event appears if iOS exposes it through EventKit | PENDING | — | — |
| H14 | Default lead event | Future timed event; default 5 min | Enable event and foreground reconcile | One alarm targets start minus 5 minutes | PENDING | — | — |
| H15 | Custom lead event | Future timed event | Select supported custom lead | Alarm is replaced at exact custom lead | PENDING | — | — |
| H16 | Event alarm OFF | Future enabled event | Turn event alarm off | Managed alarm is cancelled; UI says no alarm | PENDING | — | — |
| H17 | Event edit replacement | Scheduled test event | Change start time in Calendar; reopen app | Existing managed alarm is replaced, not duplicated | PENDING | — | — |
| H18 | Event deletion cancellation | Scheduled test event | Delete event; reopen app | Managed alarm is cancelled after trustworthy fetch | PENDING | — | — |
| H19 | Calendar disable cancellation | Selected calendar with scheduled event | Disable calendar in app | Owned alarm is cancelled; selection reflected | PENDING | — | — |
| H20 | Foreground/relaunch reconciliation | Change event while app inactive | Foreground, then terminate/relaunch | Both paths converge without duplicates | PENDING | — | — |
| H21 | Real one-shot AlarmKit firing | Future event with near safe time | Schedule and wait on real iPhone | AlarmKit alarm fires at calculated instant | PENDING | — | — |
| H22 | Exact AlarmKit title | H21 event with distinctive nonblank title | Observe system presentation | Custom title equals event title exactly and does not prepend/append `AgendaCue` | PENDING | — | — |
| H23 | Blank title fallback | Only if Calendar permits safe blank title | Schedule blank/whitespace event | Custom title is `予定` | PENDING | — | Use N/A if not safely reproducible |
| H24 | Locked-screen alarm | Scheduled near-term alarm | Lock device and wait | Native alarm appears/fires on lock screen | PENDING | — | — |
| H25 | Backgrounded alarm | Scheduled near-term alarm | Background app and wait | Alarm fires without app foreground | PENDING | — | — |
| H26 | Terminated alarm | Scheduled near-term alarm | Terminate app and wait | System-scheduled alarm fires | PENDING | — | — |
| H27 | Silent Mode | Real device in Silent Mode | Schedule and wait | Observe and record native behavior | PENDING | — | Do not infer expected OS guarantee |
| H28 | Focus Mode | Enable representative Focus | Schedule and wait | Observe and record native behavior | PENDING | — | — |
| H29 | Dismiss behavior | Alarm firing | Dismiss on iPhone; reopen app | Record system/app state and next reconcile result | PENDING | — | — |
| H30 | Live minute divider | Keep Alarm screen active across minute | Observe divider/time classification | Time advances without forced scroll | PENDING | — | — |
| H31 | Foreground current refresh | Background across a minute | Return to app | Current time refreshes immediately | PENDING | — | — |
| H32 | Midnight/date transition | Practical test window or controlled device time | Observe across day change | Sections/current position refresh correctly | PENDING | — | N/A only with reason |
| H33 | Paired Watch display/haptic | Compatible paired Apple Watch | Let AlarmKit alarm fire | Record Watch presentation and haptic | PENDING | — | N/A if no Watch available |
| H34 | iPhone/Watch dismiss state | H33 | Dismiss from each device separately | Record cross-device and app state behavior | PENDING | — | N/A if no Watch available |
| H35 | VoiceOver onboarding | Real iPhone; VoiceOver on; fresh state | Traverse all onboarding steps | Logical order, labels, traits, actions; no trap | PENDING | — | — |
| H36 | VoiceOver Alarm timeline | Populated data; VoiceOver on | Traverse dates/current/events/tabs | One conceptual event row; status understandable | PENDING | — | — |
| H37 | VoiceOver detail/settings | VoiceOver on | Operate event controls and Settings | Labels/values/actions clear and usable | PENDING | — | — |
| H38 | Dynamic Type large | Set a large standard size | Walk primary journeys | Content wraps/scrolls; controls reachable | PENDING | — | — |
| H39 | Accessibility XXXL | Set Accessibility XXXL | Walk onboarding/timeline/detail/settings | No essential clipping or unreachable action | PENDING | — | — |
| H40 | Dark Mode | Real device Dark appearance | Walk representative screens | Readable semantic contrast and hierarchy | PENDING | — | — |
| H41 | Physical touch targets | Real device, normal operation | Tap all primary controls repeatedly | Targets are comfortably usable without mis-taps | PENDING | — | — |
| H42 | Final Alarm screen acceptance | Final RC and representative data | Owner reviews timeline | Owner explicitly accepts layout/copy/behavior | PENDING | — | — |
| H43 | Event Detail acceptance | Final RC | Owner reviews default/custom/OFF/past | Owner explicitly accepts | PENDING | — | — |
| H44 | Settings acceptance | Final RC | Owner reviews controls/privacy/recovery | Owner explicitly accepts | PENDING | — | — |
| H45 | Onboarding acceptance | Final RC/fresh install | Owner completes allow and deny variants | Owner explicitly accepts | PENDING | — | — |
| H46 | Final App Icon acceptance | Phase A.4 approved artwork on device/store context | Owner reviews integrated result at multiple sizes | Integrated icon matches the approved exact artwork | PENDING | — | Artwork approved/integrated; device Human Gate evidence remains pending |

Final Owner Decision: **PENDING**. Any failure requires diagnosis and a new SHA-bound gate run before release approval.
