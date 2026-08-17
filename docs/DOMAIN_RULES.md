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
- WU-03 uses the app default lead time input only. Event-specific override resolution remains WU-06 scope.
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
- **Event identifier instability:** EventKit identifiers may not be assumed globally or permanently stable across store changes, account migrations, or recurring-event mutations. Persistence must combine available identifiers with occurrence/time context, tolerate remapping, and use reconciliation to retire stale records. WU-03/WU-05 must validate the precise strategy rather than promise impossible identity.

## Time semantics

- EventKit's `startDate` represents an absolute instant. Subtract lead time from that instant and schedule a fixed absolute alarm date.
- Display uses the user's current calendar/timezone conventions, while identity and comparison use absolute instants.
- Timezone or daylight-saving changes must not reinterpret an already fetched instant as a floating wall-clock value. Refetch/reconcile after relevant system or store changes where observable.
- Day boundaries are presentation/query concerns; query windows must include sufficient overlap so timezone transitions do not omit eligible occurrences, then deduplicate deterministically.

## Authorization failures

- **Calendar permission denied/revoked:** do not fetch, infer, or schedule new calendar-derived alarms. Preserve only the minimum local state needed for safe recovery, clean up app-managed alarms when ownership can be established safely, show recovery guidance, and never claim data is current.
- **Alarm authorization denied/revoked:** do not claim alarms are active. Calendar reading may continue only for clear local UX, but scheduling stops; reconcile local status with system truth, provide recovery guidance, and avoid repeated prompts.
- Authorization recovery must be explicit, idempotent, and testable. Neither permission grants authority to write calendar data.
