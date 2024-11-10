import SwiftUI

struct LiveScreen: View {
    @Environment(\.deviceManager) private var deviceManager
    @Environment(\.dataManager) private var dataManager

    var body: some View {
        VStack {
            Text(String(format: "%.2f kg", dataManager.currentVal?.value ?? 0))
                .font(.system(size: 48))
                .bold()
                .padding()

            LiveChart()
                .frame(maxHeight: 200)
                .padding()

            Button("Clear") {
                dataManager.clearData()
            }
            .padding()
        }
        .navigationTitle("Live Data")
    }
}

#Preview {
    let services = ServiceContainer()

    NavigationStack {
        LiveScreen()
            .environment(\.deviceManager, services.deviceManager)
            .environment(\.dataManager, services.dataManager)
    }
}
