import SwiftUI

struct FoundationRootView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.largeTitle)
            Text("Calendar Alarm")
                .font(.title)
            Text("Product foundation ready")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
