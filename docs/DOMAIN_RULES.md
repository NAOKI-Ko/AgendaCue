# Domain Rules

These rules are deterministic product intent. Platform-specific details remain subject to WU-00 verification.

## Eligibility and exclusion

- **Eligible calendar event:** a non-deleted event fetched from a user-selected readable calendar, within the active reconciliation horizon, with a usable start date, whose event alarm is enabled, whose alarm date is not past, and which violates no exclusion rule.
- **Excluded event:** an event is excluded if its calendar is not selected, access is unavailable, it is deleted/cancelled or otherwise unusable, its event override is OFF, its calculated alarm date is past, or it is all-day while the default all-day exclusion remains in effect.
- **All-day event:** an EventKit event identified as all-day. It is excluded by default. V1 does not infer a clock time from midnight or timezone conversion.

## Lead time and candidates

- **Lead time:** a non-negative duration subtracted from the event start instant. Allowed UI range and granularity must be specified in its implementation WU; invalid stored values fail closed and must not schedule.
- **Default rule:** absent an event-specific override, use the current user default lead time and enabled policy.
- **Event override:** local app-owned state that may disable the event alarm or replace the default lead time. It never modifies EventKit data.
- **Alarm candidate:** an immutable domain value containing the source-event reference, event start instant, effective lead time, calculated absolute alarm date, and duplicate identity. Candidate creation has no scheduling side effect.
- **WU-03 exact rule:** for a timed event, `alarmDate = event.startDate - effectiveLeadTime`. A candidate exists only when `alarmDate > now`. Equality is excluded. All-day events are excluded without assigning a clock time.
- **WU-06 precedence:** explicit OFF disables the candidate; explicit ON with custom lead uses that lead; explicit ON without custom lead and no override both use the current app default. Reset deletes the override and restores inherited behavior.
- Event ON never bypasses WU-03 eligibility. All-day events and `alarmDate <= now` remain excluded.
- Overrides are local app-owned intent keyed by `CalendarEvent.id`; they never modify EventKit. Missing/nil `eventIdentifier` is safe because the mapped domain fallback identity is used without force unwrap.
- EventKit identity can change after account or occurrence mutations. WU-06 does not fuzzy-rebind an orphan override to another event; conservative cleanup/recovery remains WU-08 risk work.
- **Past alarm date:** if `event.startDate - effectiveLeadTime <= now` at reconciliation, do not create or newly schedule that alarm. Any previously managed alarm for that obsolete candidate is stale and should be cleaned up. Boundary behavior must use a single injected `now`.

## Identity and reconciliation

- **Scheduling identity:** `AlarmCandidate.id` maps to one persisted AlarmKit UUID. Reprocessing an unchanged candidate is a no-op; replacement reuses the UUID.
- New mappings are persisted only after system scheduling succeeds. Cancellation removes mappings only after system cancellation succeeds. Replacement uses cancel then reschedule; a failed reschedule retains old metadata and reports recovery required for WU-05.

- **Duplicate identity:** the stable local identity for one managed alarm candidate. It must distinguish occurrences of recurring events and prevent more than one active app-managed alarm for the same logical event occurrence and effective rule. The exact persisted key is designed and tested in later WUs.
- **Deleted event:** when a formerly managed occurrence is absent/deleted after a trustworthy reconciliation, cancel its app-managed alarm and remove or tombstone local scheduling state as required for idempotency.
- **Changed event:** recompute eligibility and candidate data. If identity-relevant or schedule-relevant values changed, cancel/replace the prior managed alarm atomically as far as platform APIs allow; unchanged results are no-ops.
- **Reconciliation ownership:** the active default window is an isolated 14-day `[start, end)` policy. Absence can retire a mapping only when its alarm date is owned by that pass; out-of-window mappings are not evidence of deletion.
- **System divergence:** a desired future candidate with a persisted mapping but no matching system alarm is rescheduled with the stable UUID. If it is no longer desired, or its missing alarm is expired, remove the stale mapping instead.
- **AlarmKit orphan:** an app-visible AlarmKit alarm with no persisted mapping is cancelled deterministically. If AlarmKit capacity is reached, earlier candidates remain successful, later failures remain unpersisted, and the pass reports a typed partial result without assuming a numeric limit.
- Calendar read denial/failure blocks the entire pass and preserves alarms/mappings. It must never be interpreted as an empty trustworthy calendar snapshot.
- Overrides absent from a reconciliation window are preserved. Window absence is not proof that the underlying event was deleted.
- **Event identifier instability:** EventKit identifiers may not be assumed globally or permanently stable across store changes, account migrations, or recurring-event mutations. When EventKit supplies an identifier, the domain identity survives title/time edits. When it is nil, the deterministic fallback includes exact event facts and may change with an edit. The app deliberately does not fuzzy-match title plus approximate time; losing a stale override is safer than attaching it to an unrelated event or occurrence.

## Time semantics

- EventKit's `startDate` represents an absolute instant. Subtract lead time from that instant and schedule a fixed absolute alarm date.
- Display uses the user's current calendar/timezone conventions, while identity and comparison use absolute instants.
- Timezone or daylight-saving changes must not reinterpret an already fetched instant as a floating wall-clock value. Refetch/reconcile after relevant system or store changes where observable.
- Day boundaries are presentation/query concerns; query windows must include sufficient overlap so timezone transitions do not omit eligible occurrences, then deduplicate deterministically.
- Day, significant-clock/DST, and system-time-zone changes trigger fresh EventKit fetch and reconciliation. They never add/subtract timezone offsets from persisted absolute dates and never reconstruct scheduling truth from formatted strings.
- Every Production pass rebuilds the 14-day half-open horizon from a fresh `now`; no periodic minute timer is used.

## Authorization failures

- **Calendar permission denied/revoked:** block the pass before fetching or diffing. Preserve alarms, mappings, overrides, and calendar selections; inaccessible truth must never be interpreted as deletion. Show recovery guidance and never claim data is current.
- **Alarm authorization denied/revoked:** do not claim alarms are active. Calendar reading may continue only for clear local UX, but scheduling stops; reconcile local status with system truth, provide recovery guidance, and avoid repeated prompts.
- Authorization recovery must be explicit, idempotent, and testable. Neither permission grants authority to write calendar data.
- Lifecycle, calendar-change, significant-time, and background paths never request permissions. After the owner restores access in system settings, the next foreground/reconciliation pass refetches truth and retries convergence.

## Reliability and background semantics

- A missing selected calendar identifier is ignored without deleting its stored selection. The same identifier restores prior behavior if it reappears; a different identifier follows normal new-calendar defaults and inherits no historical settings.
- A missing/fired system alarm plus a desired future candidate is recovered with the stable app-owned UUID. A missing system alarm with an expired or undesired mapping removes only stale app-owned persistence. Recognized system orphans are cancelled through the normal scheduler boundary.
- Capacity and platform failures are typed partial results. Successful earlier work remains valid, failed schedules create no fake mapping, and later idempotent passes retry.
- Background app refresh is a best-effort freshness opportunity only. Its requested time and execution are not guaranteed, and it is never required for correctness after the next foreground/resume reconciliation.
