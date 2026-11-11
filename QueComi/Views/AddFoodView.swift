//
//  AddFoodView.swift
//  QueComi
//
//  Created by Ferando Robles Vidrio on 10/11/26.
//

import SwiftUI
import PhotosUI

struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: FoodDiaryViewModel

    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var selectedPrediction: FoodPrediction?
    @State private var customName = ""

    // Si el usuario escribió algo, eso manda; si no, la sugerencia que eligió
    private var finalName: String {
        let typed = customName.trimmingCharacters(in: .whitespacesAndNewlines)
        return typed.isEmpty ? (selectedPrediction?.label ?? "") : typed
    }

    var body: some View {
        NavigationStack {
            Form {
                photoSection
                if imageData != nil {
                    suggestionsSection
                }
                manualSection
            }
            .navigationTitle("Nueva comida")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar", action: save)
                        .disabled(finalName.isEmpty)
                }
            }
            .onAppear {
                viewModel.resetAnalysis()
            }
            .onChange(of: selectedItem) { _, newItem in
                Task { await loadAndAnalyze(newItem) }
            }
            .onChange(of: customName) { _, newValue in
                // Si el usuario escribe, ya no usamos la sugerencia de la IA
                if !newValue.isEmpty { selectedPrediction = nil }
            }
        }
    }

    // MARK: - Secciones

    private var photoSection: some View {
        Section {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .accessibilityLabel("Foto de tu comida")
            }
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label(imageData == nil ? "Elegir foto" : "Cambiar foto",
                      systemImage: "photo.on.rectangle")
            }
        }
    }

    private var suggestionsSection: some View {
        Section {
            if viewModel.isAnalyzing {
                HStack(spacing: 12) {
                    ProgressView()
                    Text("Analizando con IA…")
                }
            } else if let errorMessage = viewModel.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
            } else {
                if viewModel.isLowConfidence {
                    Label("No estoy muy seguro. Revisa las opciones o escríbelo tú.",
                          systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
                ForEach(viewModel.predictions) { prediction in
                    predictionRow(prediction)
                }
            }
        } header: {
            Label("Sugerencias de la IA", systemImage: "sparkles")
        } footer: {
            Text("Las genera un modelo de IA dentro de tu iPhone; tu foto no sale del dispositivo. Puede equivocarse, así que elige la correcta.")
        }
    }

    private func predictionRow(_ prediction: FoodPrediction) -> some View {
        let isSelected = selectedPrediction?.id == prediction.id
        return Button {
            selectedPrediction = prediction
            customName = ""
        } label: {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                Text(prediction.label)
                Spacer()
                Text(prediction.percentage)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .tint(.primary)
        .accessibilityLabel("\(prediction.label), confianza \(prediction.percentage)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var manualSection: some View {
        Section("¿No es correcto? Escríbelo tú") {
            TextField("Ej. Tacos de trompo", text: $customName)
        }
    }

    // MARK: - Acciones

    // Carga la foto elegida y se la manda a la IA
    private func loadAndAnalyze(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            viewModel.errorMessage = "No se pudo cargar la foto. Intenta con otra."
            return
        }
        imageData = data
        selectedPrediction = nil
        await viewModel.analyze(data)
    }

    private func save() {
        viewModel.addEntry(name: finalName,
                           imageData: imageData,
                           aiConfidence: selectedPrediction?.confidence)
        dismiss()
    }
}

#Preview {
    AddFoodView(viewModel: FoodDiaryViewModel())
}
