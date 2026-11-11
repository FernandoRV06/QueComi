//
//  DiaryListView.swift
//  QueComi
//
//  Created by Ferando Robles Vidrio on 10/11/26.
//

import SwiftUI

struct DiaryListView: View {
    @State private var viewModel = FoodDiaryViewModel()
    @State private var isShowingAddFood = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.entries) { entry in
                    FoodEntryRow(entry: entry)
                }
                .onDelete { offsets in
                    viewModel.delete(at: offsets)
                }
            }
            .overlay {
                if viewModel.entries.isEmpty {
                    ContentUnavailableView("Aún no registras comidas",
                                           systemImage: "fork.knife",
                                           description: Text("Toca + y elige una foto de tu comida."))
                }
            }
            .navigationTitle("¿Qué comí?")
            .toolbar {
                Button("Agregar comida", systemImage: "plus") {
                    isShowingAddFood = true
                }
            }
            .sheet(isPresented: $isShowingAddFood) {
                AddFoodView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    DiaryListView()
}
