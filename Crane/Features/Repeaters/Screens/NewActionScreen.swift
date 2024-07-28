import SwiftUI

struct NewActionScreen: View {
    var onSave: (_: Action) -> ()

    @Environment(\.dismiss) var dismiss
    @State var action: Action = .init(repetitions: 1, name: "Action", weight: 50)
    var body: some View {
        Form {
            TextField("Name", text: $action.name)

            TextField("Weight (kg)", value: $action.weight, formatter: NumberFormatter()).keyboardType(.decimalPad)

            Stepper("Repetitions: \($action.wrappedValue.repetitions)", value: $action.repetitions, in: 1 ... 99)
        }.toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { onSave(action); dismiss() }) {
                    Image(systemName: "checkmark")
                }
            }
        }.navigationTitle("Create new action")
    }
}

#Preview {
    NavigationStack {
        NewActionScreen(onSave: { _ in })
    }
}
