import SwiftUI

struct ActionForm: View {
    @Binding var action: Action

    var body: some View {
        Form {
            TextField("Name", text: $action.name)

            Stepper("Repetitions: \(action.repetitions)", value: $action.repetitions, in: 1...20)

            HStack {
                Text("Weight")
                TextField("Weight", value: $action.weight, format: .number)
                    .keyboardType(.decimalPad)
                Text("kg")
            }

            Stepper("Hold Duration: \(Int(action.duration))s", value: $action.duration, in: 1...60)
        }
        .navigationTitle(action.name.isEmpty ? "New Action" : action.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
