//import SwiftUI
//import SwiftData
//
//struct RepeaterEditor: View {
//    @Environment(\.dismiss) private var dismiss
//    @Bindable var repeater: Repeater
//    @State private var showingActionEditor: Action?
//
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section("Meta") {
//                    TextField("Name", text: $repeater.name)
//                }
//
//                Section("Rest") {
//                    Stepper(
//                        "\(repeater.rest.minutes) minutes",
//                        value: .init(
//                            get: { repeater.rest.minutes },
//                            set: { repeater.rest.minutes = $0 }
//                        ),
//                        in: 0...10
//                    )
//
//                    Stepper(
//                        "\(repeater.rest.seconds) seconds",
//                        value: .init(
//                            get: { repeater.rest.seconds },
//                            set: { repeater.rest.seconds = $0 }
//                        ),
//                        in: 0...59
//                    )
//                }
//
//                Section("Actions") {
//                    List {
//                        ForEach(repeater.actions) { action in
//                            Button {
//                                showingActionEditor = action
//                            } label: {
//                                VStack(alignment: .leading) {
//                                    Text(action.name)
//                                    HStack {
//                                        Text("\(action.repetitions)x")
//                                        Text(String(format: "%.1f kg", action.weight))
//                                        Text("\(Int(action.duration))s")
//                                    }.foregroundColor(.gray)
//                                     .font(.subheadline)
//                                     .frame(
//                                        minWidth: 0,
//                                        maxWidth: .infinity,
//                                        alignment: .leading
//                                     )
//                                }.frame(
//                                    minWidth: 0,
//                                    maxWidth: .infinity,
//                                    alignment: .trailing
//                                )
//                                Image(systemName: "chevron.up")
//                                    .foregroundColor(.gray)
//                            }.buttonStyle(.plain)
//                        }
//                        .onMove { indexSet, offset in
//                            repeater.actions.move(
//                                fromOffsets: indexSet,
//                                toOffset: offset
//                            )
//                        }
//                        .onDelete { indexSet in
//                            repeater.actions.remove(
//                                atOffsets: indexSet
//                            )
//                        }
//
//                        Button("Add action") {
//                            let newAction = Action(
//                                repetitions: 1,
//                                name: "New Action",
//                                weight: 0,
//                                duration: AppConstants.Defaults.actionDuration
//                            )
//                            repeater.actions.append(newAction)
//                            showingActionEditor = newAction
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Edit Repeater")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Done") {
//                        dismiss()
//                    }
//                }
//                ToolbarItem(placement: .primaryAction) {
//                    EditButton()
//                }
//            }
//            .sheet(item: $showingActionEditor) { action in
//                ActionEditor(action: action)
//            }
//        }
//    }
//}
//
//#Preview {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(
//        for: Repeater.self,
//        configurations: config
//    )
//
//    let repeater = Repeater(name: "Test", listOrder: 0)
//    repeater.actions = [
//        Action(repetitions: 3, name: "Test Action", weight: 10, duration: 7),
//        Action(repetitions: 2, name: "Another Action", weight: 15, duration: 5)
//    ]
//    container.mainContext.insert(repeater)
//
//    return RepeaterEditor(repeater: repeater)
//        .modelContainer(container)
//}
