//
//  FoodEntry.swift
//  QueComi
//
//  Created by Ferando Robles Vidrio on 10/11/26.
//

import Foundation

// Una comida guardada en el diario (Registro).
struct FoodEntry: Identifiable {
    let id = UUID()
    let name: String
    let date: Date
    let imageData: Data?
    let aiConfidence: Float?   // nil = el usuario la escribió a mano

    // Para mostrar si el nombre lo sugirió la IA o lo escribió el usuario
    var isFromAI: Bool {
        aiConfidence != nil
    }
}
