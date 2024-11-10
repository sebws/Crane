//import SwiftUI
//import SwiftData
//
//struct ActionEditor: View {
//    @Environment(\.dismiss) private var dismiss
//    @Bindable var action: Action
//
//    var body: some View {
//        NavigationStack {
//            Form {
//                TextField("Name", text: $action.name)
//
//                Stepper(
//                    "\(action.repetitions) repetitions",
//                    value: $action.repetitions,
//                    in: 1...10
//                )
//
//                HStack {
//                    Text("Weight")
//                    Spacer()
//                    TextField("Weight", value: $action.weight, format: .number)
//                        .keyboardType(.decimalPad)
//                        .multilineTextAlignment(.trailing)
//                    Text("kg")
//                }
//
//                Stepper(
//                    "\(Int(action.duration)) seconds",
//                    value: $action.duration,
//                    in: 1...30
//                )
//            }
//            .navigationTitle("Edit Action")
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
//            }
//        }
//    }
//}
//
////#Preview("Add") {
////    ModelContainerPreview(ModelContainer.sample) {
////        ActionEditor(action: ))
////    }
////}
//
//#Preview("Edit zero0") {
//    ModelContainerPreview(ModelContainer.sample) {
//        ActionEditor(action: Action(name: "Dead hang"))
//    }
//}
