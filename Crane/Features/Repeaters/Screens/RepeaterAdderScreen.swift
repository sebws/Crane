import SwiftUI

struct RepeaterAdderScreen: View {
    @State var name: String = ""
    @State var actions: [Action] = []

    var body: some View {
        Form {
            Section(header: Text("Meta")) {
                TextField("Name", text: $name)
            }

            Section(header: Text("Actions")) {
                ForEach($actions, id: \.self) { $action in
                    HStack {
                        Text($action.wrappedValue.name)
                        Spacer()
                        Divider()
                        Text(String($action.wrappedValue.repetitions))
                        Image(systemName: "repeat")
                        Divider()
                        Text(String(format: "%.2f kg", $action.wrappedValue.weight))
                    }
                }
                NavigationLink(destination: NewActionScreen(onSave: { (action: Action) in self.actions.append(action) })) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add action")
                    }
                }
            }
        }.toolbar {
            ToolbarItem(placement: .primaryAction) { Button(action: {}) { Image(systemName: "checkmark") }}
        }.navigationTitle("Create new repeater")
    }
}

#Preview {
    NavigationStack {
        RepeaterAdderScreen()
    }
}
