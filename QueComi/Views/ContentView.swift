//
//  ContentView.swift
//  QueComi
//
//  Created by Ferando Robles Vidrio on 10/11/26.
//

import SwiftUI

struct ContentView: View {
    @State private var result = "Toca el botón"

    var body: some View {
        VStack(spacing: 20) {
            Image("testFood")
                .resizable()
                .scaledToFit()
                .frame(height: 250)

            Button("Probar IA") {
                Task { await testClassifier() }
            }
            .buttonStyle(.borderedProminent)

            Text(result)
        }
        .padding()
    }

    // Prueba temporal: clasifica la foto de Assets
    private func testClassifier() async {
        guard let data = UIImage(named: "testFood")?.jpegData(compressionQuality: 0.9) else {
            result = "No encontré la foto"
            return
        }
        do {
            let predictions = try await FoodClassifier().classify(data)
            result = predictions.map { "\($0.label) \($0.percentage)" }.joined(separator: "\n")
        } catch let error as ClassifierError {
            result = error.message
        } catch {
            result = "Error inesperado"
        }
    }
}

#Preview {
    ContentView()
}
