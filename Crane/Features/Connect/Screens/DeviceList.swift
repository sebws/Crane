import SwiftUI

enum DeviceType: String, Identifiable, Hashable, CaseIterable {
    var id: Self {
        return self
    }

    case progressor = "Progressor"
    case whc06 = "WH-C06"
}

struct DeviceList: View {
    @State private var deviceManager = DeviceManager.model

    var body: some View {
        VStack {
            List(DeviceType.allCases) { device in
                NavigationLink(destination: ConnectScreen(deviceType: device)) {
                    Text(device.rawValue)
                }
            }
        }.navigationTitle("Select device type")
    }
}

#Preview {
    NavigationStack {
        DeviceList()
    }
}
