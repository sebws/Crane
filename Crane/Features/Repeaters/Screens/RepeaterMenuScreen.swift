//import SwiftUI
//import SwiftData
//
//struct RepeaterMenuScreen: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query(sort: \Repeater.listOrder) private var repeaters: [Repeater]
//    @State private var showingRepeaterEditor: Repeater?
//
//    private let deviceManager: DeviceManaging
//    private let dataManager: DataManaging
//
//    init(deviceManager: DeviceManaging, dataManager: DataManaging) {
//        self.deviceManager = deviceManager
//        self.dataManager = dataManager
//    }
//
//    var body: some View {
//        List {
//            ForEach(repeaters) { repeater in
//                Button {
//                    showingRepeaterEditor = repeater
//                } label: {
//                    HStack {
//                        Text(repeater.name)
//                        Spacer()
//                        NavigationLink(destination: RepeaterPlayer(
//                            repeater: repeater,
//                            deviceManager: deviceManager,
//                            dataManager: dataManager
//                        )) {
//                            Image(systemName: "play.circle")
//                        }
//                    }
//                }
//                .buttonStyle(.plain)
//            }
//            .onMove { offsets, offset in
//                move(at: offsets, offset: offset)
//            }
//            .onDelete { offsets in
//                delete(at: offsets)
//            }
//
//            Button("Add repeater") {
//                let newRepeater = Repeater(
//                    name: "New Repeater",
//                    listOrder: repeaters.count
//                )
//                modelContext.insert(newRepeater)
//                showingRepeaterEditor = newRepeater
//            }
//        }
//        .navigationTitle("Repeaters")
//        .toolbar {
//            EditButton()
//        }
//        .sheet(item: $showingRepeaterEditor) { repeater in
//            RepeaterEditor(repeater: repeater)
//        }
//    }
//
//    func move(at offsets: IndexSet, offset: Int) {
//        var orderedRepeaters = repeaters
//        orderedRepeaters.move(fromOffsets: offsets, toOffset: offset)
//        for (index, item) in orderedRepeaters.enumerated() {
//            item.listOrder = index
//        }
//        try? modelContext.save()
//    }
//
//    func delete(at offsets: IndexSet) {
//        for offset in offsets {
//            let repeater = repeaters[offset]
//            modelContext.delete(repeater)
//        }
//        try? modelContext.save()
//    }
//}
//
//#Preview {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(
//        for: Repeater.self, configurations: config)
//
//    let sampleRepeaters = [
//        Repeater(name: "A", listOrder: 0),
//        Repeater(name: "B", listOrder: 1),
//        Repeater(name: "C", listOrder: 2),
//    ]
//
//    sampleRepeaters.forEach { container.mainContext.insert($0) }
//
//    let services = ServiceContainer()
//
//    return NavigationStack {
//        RepeaterMenuScreen(
//            deviceManager: services.deviceManager,
//            dataManager: services.dataManager
//        )
//        .modelContainer(container)
//    }
//}
