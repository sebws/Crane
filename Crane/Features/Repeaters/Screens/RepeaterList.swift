import SwiftData
import SwiftUI

struct RepeaterList: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \Repeater.listOrder) private var repeaters: [Repeater]
  @State private var showingNewRepeater = false

  var body: some View {
    List {
      ForEach(repeaters) { repeater in
        NavigationLink {
          RepeaterForm(repeater: repeater)
        } label: {
          Text(repeater.name.isEmpty ? "Unnamed Repeater" : repeater.name)
        }
      }
      .onMove { from, to in
        var updatedRepeaters = repeaters
        updatedRepeaters.move(fromOffsets: from, toOffset: to)
        for (index, repeater) in updatedRepeaters.enumerated() {
          repeater.listOrder = index
        }
      }
      .onDelete { indexSet in
        for index in indexSet {
          modelContext.delete(repeaters[index])
        }
      }
    }
    .navigationTitle("Repeaters")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          showingNewRepeater = true
        } label: {
          Image(systemName: "plus")
        }
      }

      ToolbarItem(placement: .topBarLeading) {
        EditButton()
      }
    }
    .navigationDestination(isPresented: $showingNewRepeater) {
      RepeaterForm(
        repeater: Repeater(), isNew: true
      )
      .modelContext(modelContext)
      .onDisappear {
        showingNewRepeater = false
      }
    }
  }
}
