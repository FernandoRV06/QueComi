//
//  FoodDiaryViewModel.swift
//  QueComi
//
//  Created by Ferando Robles Vidrio on 10/11/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class FoodDiaryViewModel {
    private(set) var entries: [FoodEntry] = []

    // Estado del análisis de la foto
    private(set) var predictions: [FoodPrediction] = []
    private(set) var isAnalyzing = false
    var errorMessage: String?

    private let classifier = FoodClassifier()
    private let lowConfidenceLimit: Float = 0.5

    // Si la mejor sugerencia tiene menos de 50%, se le dice al usuario
    var isLowConfidence: Bool {
        guard let best = predictions.first else { return false }
        return best.confidence < lowConfidenceLimit
    }

    // Manda la foto a la IA y guarda las sugerencias
    func analyze(_ imageData: Data) async {
        isAnalyzing = true
        predictions = []
        errorMessage = nil
        defer { isAnalyzing = false }

        do {
            predictions = try await classifier.classify(imageData)
        } catch let error as ClassifierError {
            errorMessage = error.message
        } catch {
            errorMessage = "Ocurrió un error inesperado. Intenta de nuevo."
        }
    }

    // Guarda la comida, aiConfidence es nil si el usuario escribió el nombre.
    func addEntry(name: String, imageData: Data?, aiConfidence: Float?) {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty else { return }

        let entry = FoodEntry(name: cleanName, date: .now, imageData: imageData, aiConfidence: aiConfidence)
        entries.insert(entry, at: 0)   // la más reciente arriba
        resetAnalysis()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) {
            entries.remove(at: index)
        }
    }
    // Limpia el análisis para la siguiente foto
    func resetAnalysis() {
        predictions = []
        errorMessage = nil
    }
}
