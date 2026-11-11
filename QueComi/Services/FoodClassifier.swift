//
//  FoodClassifier.swift
//  QueComi
//
//  Created by Ferando Robles Vidrio on 10/11/26.
//

import Foundation
import Vision

// la IA regresa sus resultados en su formato, y lo convertimos a algo más sencillo de mostrar.
struct FoodPrediction: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Float

    var percentage: String {
        "\(Int(confidence * 100))%"
    }
}

// Errores posibles cuando se analiza la foto.
enum ClassifierError: Error {
    case analysisFailed
    case noFoodFound

    var message: String {
        switch self {
        case .analysisFailed:
            "No se pudo analizar la foto. Intenta con otra imagen."
        case .noFoodFound:
            "No reconocí ninguna comida en la foto. Puedes escribirla tú."
        }
    }
}

// Usa el modelo de Vision para clasificar la foto.
struct FoodClassifier {
    private let genericLabels: Set<String> = ["food", "meal", "dish", "tableware"]

    func classify(_ imageData: Data) async throws -> [FoodPrediction] {
        let request = ClassifyImageRequest()

        let observations: [ClassificationObservation]
        do {
            observations = try await request.perform(on: imageData)
        } catch {
            throw ClassifierError.analysisFailed
        }

        // Ordeno de mayor a menor confianza y se queda con las 3 mejores
        let predictions = observations
            .filter { !genericLabels.contains($0.identifier) }
            .sorted { $0.confidence > $1.confidence }
            .prefix(3)
            .map { FoodPrediction(label: readable($0.identifier), confidence: $0.confidence) }

        guard let best = predictions.first, best.confidence > 0.1 else {
            throw ClassifierError.noFoodFound
        }
        return Array(predictions)
    }

    // cambia _ por espacio y pone mayúsculas
    private func readable(_ identifier: String) -> String {
        identifier.replacingOccurrences(of: "_", with: " ").capitalized
    }
}
