import BackgroundTasks
import Foundation
import UIKit

enum ReliabilityPolicy {
    static let backgroundTaskIdentifier = "com.example.CalendarAlarmFeasibility.refresh"
    static let backgroundRefreshInterval: TimeInterval = 6 * 60 * 60
    static let timeChangeNotifications: [Notification.Name] = [
        NSNotification.Name.NSCalendarDayChanged,
        NSNotification.Name.NSSystemTimeZoneDidChange,
        UIApplication.significantTimeChangeNotification
    ]
}

@MainActor
protocol BackgroundRefreshScheduling: Sendable {
    func register(identifier: String, handler: @escaping @Sendable () async -> Bool) -> Bool
    func replacePending(identifier: String, earliestBeginDate: Date) throws
}

@MainActor
final class BackgroundRefreshCoordinator {
    private let scheduler: any BackgroundRefreshScheduling
    private let reconciliation: any ReconciliationTriggering
    private let now: @Sendable () -> Date
    private var registered = false
    private(set) var lastSchedulingErrorDescription: String?

    init(scheduler: any BackgroundRefreshScheduling, reconciliation: any ReconciliationTriggering, now: @escaping @Sendable () -> Date = { Date() }) {
        self.scheduler = scheduler; self.reconciliation = reconciliation; self.now = now
    }

    @discardableResult func start() -> Bool {
        guard !registered else { return true }
        registered = scheduler.register(identifier: ReliabilityPolicy.backgroundTaskIdentifier) { [weak self] in
            guard let self else { return false }
            return await self.execute()
        }
        if !registered { lastSchedulingErrorDescription = "registration-failed" }
        if registered { scheduleNext() }
        return registered
    }

    func scheduleNext() {
        let instant = now()
        do {
            try scheduler.replacePending(identifier: ReliabilityPolicy.backgroundTaskIdentifier,
                                         earliestBeginDate: instant.addingTimeInterval(ReliabilityPolicy.backgroundRefreshInterval))
            lastSchedulingErrorDescription = nil
        } catch {
            lastSchedulingErrorDescription = String(describing: error)
#if DEBUG
            print("Background refresh request was not scheduled: \(error)")
#endif
        }
    }

    func execute() async -> Bool {
        scheduleNext()
        guard !Task.isCancelled else { return false }
        let instant = now()
        guard let report = await reconciliation.trigger(now: instant, window: .productionDefault(now: instant)), !Task.isCancelled else { return false }
        return report.blockedReason == nil && report.issues.isEmpty
    }
}

@MainActor
final class SystemBackgroundRefreshScheduler: BackgroundRefreshScheduling, @unchecked Sendable {
    func register(identifier: String, handler: @escaping @Sendable () async -> Bool) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { task.setTaskCompleted(success: false); return }
            let gate = BackgroundCompletionGate(task: refreshTask)
            let operation = Task { gate.complete(await handler()) }
            refreshTask.expirationHandler = { operation.cancel(); gate.complete(false) }
        }
    }

    func replacePending(identifier: String, earliestBeginDate: Date) throws {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = earliestBeginDate
        try BGTaskScheduler.shared.submit(request)
    }
}

private final class BackgroundCompletionGate: @unchecked Sendable {
    private let lock = NSLock(); private var completed = false; private let task: BGTask
    init(task: BGTask) { self.task = task }
    func complete(_ success: Bool) { lock.lock(); defer { lock.unlock() }; guard !completed else { return }; completed = true; task.setTaskCompleted(success: success) }
}
