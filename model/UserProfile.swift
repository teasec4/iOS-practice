//
//  UserProfile.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/24/26.
//
import Foundation

struct UserProfile: Codable, Equatable {
    let answers: [String: UserProfileAnswer]
    let createdAt: Date

    init(answers: [String: UserProfileAnswer], createdAt: Date = Date()) {
        self.answers = answers
        self.createdAt = createdAt
    }

    var headline: String {
        let goal = answerTitle(for: "goal") ?? "your rooms"
        let style = answerTitle(for: "style") ?? "your style"

        return "\(goal) with \(style.lowercased())"
    }

    var recommendation: String {
        let room = answerTitle(for: "priority_room") ?? "one room"
        let pace = answerTitle(for: "pace") ?? "your own pace"

        return "Start with \(room.lowercased()) and move at \(pace.lowercased())."
    }

    var summaryItems: [UserProfileSummaryItem] {
        [
            summaryItem(id: "goal", title: "Main goal"),
            summaryItem(id: "home_size", title: "Home size"),
            summaryItem(id: "style", title: "Style"),
            summaryItem(id: "priority_room", title: "First room"),
            summaryItem(id: "budget", title: "Budget"),
            summaryItem(id: "pace", title: "Pace"),
            summaryItem(id: "motivation", title: "Motivation")
        ].compactMap { $0 }
    }

    func encoded() -> String {
        guard let data = try? JSONEncoder().encode(self) else {
            return ""
        }

        return String(data: data, encoding: .utf8) ?? ""
    }

    static func decoded(from value: String) -> UserProfile? {
        guard let data = value.data(using: .utf8) else {
            return nil
        }

        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    private func answerTitle(for id: String) -> String? {
        answers[id]?.title
    }

    private func summaryItem(id: String, title: String) -> UserProfileSummaryItem? {
        guard let answer = answers[id] else {
            return nil
        }

        return UserProfileSummaryItem(
            id: id,
            title: title,
            value: answer.title,
            systemImage: answer.systemImage
        )
    }
}

struct UserProfileAnswer: Codable, Equatable, Hashable {
    let id: String
    let title: String
    let systemImage: String
}

struct UserProfileSummaryItem: Identifiable {
    let id: String
    let title: String
    let value: String
    let systemImage: String
}

extension UserProfile {
    static func make(from answers: [String: OnboardingAnswerOption]) -> UserProfile {
        let profileAnswers = answers.mapValues { option in
            UserProfileAnswer(
                id: option.id,
                title: option.title,
                systemImage: option.systemImage
            )
        }

        return UserProfile(answers: profileAnswers)
    }
}
