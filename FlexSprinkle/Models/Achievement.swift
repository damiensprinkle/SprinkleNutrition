//
//  Achievement.swift
//  FlexSprinkle
//
//  Created by Claude Code
//

import Foundation

struct Achievement: Codable, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let trophy: TrophyType

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case trophy
    }
}

enum TrophyType: String, Codable {
    case wood = "Wood"
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case platinum = "Platinum"

    var color: String {
        switch self {
        case .wood: return "MyBrown"
        case .bronze: return "MyBrown"
        case .silver: return "MyGrey"
        case .gold: return "MyTan"
        case .platinum: return "MyLightBlue"
        }
    }

    var icon: String {
        return "trophy.fill"
    }
}

struct AchievementsList: Codable {
    let achievements: [Achievement]
}

struct AchievementProgress {
    let achievement: Achievement
    let isUnlocked: Bool
    let currentProgress: Double
    let targetValue: Double

    var progressPercentage: Double {
        guard targetValue > 0 else { return 0 }
        return min((currentProgress / targetValue) * 100, 100)
    }
}
