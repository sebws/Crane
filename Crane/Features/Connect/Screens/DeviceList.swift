import SwiftUI

struct DeviceList: View {
    @Environment(\.deviceManager) private var deviceManager

    var body: some View {
        List(DeviceType.allCases, id: \.self) { deviceType in
            NavigationLink(value: deviceType) {
                Label(deviceType.name, systemImage: deviceType.icon)
            }
        }
        .navigationTitle("Connect Device")
    }
}

#Preview {
    let services = ServiceContainer()

    NavigationStack {
        DeviceList()
            .environment(\.deviceManager, services.deviceManager)
    }
}
