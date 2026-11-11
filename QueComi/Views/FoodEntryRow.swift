//
//  FoodEntryRow.swift
//  QueComi
//
//  Created by Ferando Robles Vidrio on 10/11/26.
//

import SwiftUI

// Una comida en la lista
struct FoodEntryRow: View {
    let entry: FoodEntry

    var body: some View {
        HStack(spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.headline)
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            sourceBadge
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let data = entry.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)
        } else {
            Image(systemName: "fork.knife")
                .frame(width: 56, height: 56)
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)
        }
    }

    // Transparencia: se ve si el nombre lo sugirió la IA o lo escribió el usuario
    private var sourceBadge: some View {
        Text(badgeText)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(entry.isFromAI ? Color.purple.opacity(0.15) : Color.gray.opacity(0.15))
            .clipShape(Capsule())
    }

    private var badgeText: String {
        if let confidence = entry.aiConfidence {
            return "IA \(Int(confidence * 100))%"
        }
        return "Manual"
    }
}

#Preview {
    List {
        FoodEntryRow(entry: FoodEntry(name: "Pizza", date: .now, imageData: nil, aiConfidence: 0.73))
        FoodEntryRow(entry: FoodEntry(name: "Tacos de trompo", date: .now, imageData: nil, aiConfidence: nil))
    }
}
