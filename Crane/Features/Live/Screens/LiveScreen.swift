import Charts
import SwiftUI

struct LiveScreen: View {
    let model = DataManager.model

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    model.clearData()
                }) {
                    VStack {
                        Text("Max").font(.headline)
                        Text("\(String(format: "%.1f", model.maxVal))").font(.largeTitle).monospaced()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }.buttonStyle(.bordered).foregroundStyle(.foreground)

                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/).fill(.regularMaterial).overlay {
                    VStack {
                        Text("Current").font(.headline)
                        Text("\(String(format: "%.1f", model.currentVal ?? 0))").font(.largeTitle).monospaced()
                    }
                }
            }

            LiveChart().frame(height: 500)

        }.navigationTitle("Live Data").navigationBarTitleDisplayMode(.inline).padding()
    }
}

#Preview {
    NavigationStack {
        LiveScreen()
    }
}
