import AlarmKit
import Foundation
import SwiftUI

private struct FeasibilityAlarmMetadata: AlarmMetadata {
    let source: String
}

@MainActor
final class AlarmKitScheduler: AlarmScheduling {
    private let manager: AlarmManager

    init(manager: AlarmManager = .shared) {
        self.manager = manager
    }

    var authorizationStatus: AlarmAuthorizationStatus {
        Self.map(manager.authorizationState)
    }

    func requestAuthorizationIfNeeded() async throws -> AlarmAuthorizationStatus {
        let state: AlarmManager.AuthorizationState
        if manager.authorizationState == .notDetermined {
            state = try await manager.requestAuthorization()
        } else {
            state = manager.authorizationState
        }
        return Self.map(state)
    }

    func scheduleOneShot(at date: Date, title: String) async throws -> ScheduledAlarmResult {
        let state = try await requestAuthorizationIfNeeded()
        guard state == .authorized else {
            throw AlarmSchedulingError.notAuthorized(state)
        }

        let id = UUID()
        let presentationTitle: LocalizedStringResource = "Calendar Alarm: \(title)"
        let presentation = AlarmPresentation(
            alert: .init(
                title: presentationTitle,
                stopButton: AlarmButton(
                    text: "Stop",
                    textColor: .white,
                    systemImageName: "stop.fill"
                )
            )
        )
        let attributes = AlarmAttributes(
            presentation: presentation,
            metadata: FeasibilityAlarmMetadata(source: "WU-00"),
            tintColor: .orange
        )
        let configuration = AlarmManager.AlarmConfiguration.alarm(
            schedule: .fixed(date),
            attributes: attributes
        )

        _ = try await manager.schedule(id: id, configuration: configuration)
        let result = ScheduledAlarmResult(id: id, date: date)
        debugPrint("WU-00 scheduled alarm", result.id, result.date, title)
        return result
    }

    private static func map(_ state: AlarmManager.AuthorizationState) -> AlarmAuthorizationStatus {
        switch state {
        case .notDetermined: .notDetermined
        case .denied: .denied
        case .authorized: .authorized
        @unknown default: .denied
        }
    }
}

enum AlarmSchedulingError: LocalizedError {
    case notAuthorized(AlarmAuthorizationStatus)

    var errorDescription: String? {
        switch self {
        case .notAuthorized(let status):
            "Alarm authorization is \(status.rawValue)."
        }
    }
}
