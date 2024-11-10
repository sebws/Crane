import SwiftData
import SwiftUI

struct RepeaterForm: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Bindable var repeater: Repeater
  var isNew: Bool = false
  @State private var showingPlayer = false

  private var navigationTitle: String {
    if isNew {
      return repeater.name.isEmpty ? "New Repeater" : repeater.name
    } else {
      return repeater.name.isEmpty ? "Unnamed Repeater" : repeater.name
    }
  }

  var body: some View {
    Form {
      Section {
        TextField("Name", text: $repeater.name)
      }

      Section("Rest Time") {
        RestPicker(rest: $repeater.rest)
      }

      Section("Actions") {
        ForEach($repeater.actions) { $action in
          NavigationLink {
            ActionForm(action: $action)
          } label: {
            ActionRow(action: action)
          }
        }
        .onMove { from, to in
          repeater.actions.move(fromOffsets: from, toOffset: to)
          for (index, action) in repeater.actions.enumerated() {
            action.listOrder = index
          }
        }
        .onDelete { indexSet in
          repeater.actions.remove(atOffsets: indexSet)
        }

        Button {
          repeater.addAction()
        } label: {
          Label("Add Action", systemImage: "plus")
        }
      }
    }
    .navigationTitle(navigationTitle)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if isNew {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            repeater.clear()
            dismiss()
          }
        }

        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            modelContext.insert(repeater)
            dismiss()
          }
          .disabled(repeater.name.isEmpty)
        }
      } else {
        ToolbarItem(placement: .primaryAction) {
          Button {
            showingPlayer = true
          } label: {
            Image(systemName: "play.circle.fill")
          }
        }
      }
    }
    .navigationDestination(isPresented: $showingPlayer) {
        RepeaterPlayer(repeater: repeater)
    }
  }
}

struct ActionRow: View {
  let action: Action

  var body: some View {
    VStack(alignment: .leading) {
      Text(action.name.isEmpty ? "Unnamed Action" : action.name)

      Text("\(action.repetitions)× • \(action.weight, format: .number)kg • \(action.duration)s")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }
}

struct RestPicker: View {
  @Binding var rest: Rest

  var body: some View {
    HStack {
      Picker("Minutes", selection: $rest.minutes) {
        ForEach(0...3, id: \.self) { minute in
          Text("\(minute)").tag(minute)
        }
      }
      .pickerStyle(.wheel)

      Text("min")
        .foregroundStyle(.secondary)

      Picker("Seconds", selection: $rest.seconds) {
        ForEach(0...59, id: \.self) { second in
          Text("\(second)").tag(second)
        }
      }
      .pickerStyle(.wheel)

      Text("sec")
        .foregroundStyle(.secondary)
    }
    .frame(height: 100)
  }
}

#Preview("New") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Repeater.self, configurations: config)

    return NavigationStack {
        RepeaterForm(
            repeater: Repeater(), isNew: true)
            .modelContainer(container)
    }
}
