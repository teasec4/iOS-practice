//
//  Onboarding.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/23/26.
//
import Foundation

struct OnboardingQuestion: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let options: [OnboardingAnswerOption]
}

struct OnboardingAnswerOption: Identifiable, Hashable {
    let id: String
    let title: String
    let systemImage: String
}

extension OnboardingQuestion {
    static let defaultQuestions: [OnboardingQuestion] = [
        OnboardingQuestion(
            id: "goal",
            title: "What do you want to improve first?",
            subtitle: "Pick the thing that matters most right now.",
            options: [
                OnboardingAnswerOption(id: "comfort", title: "Make rooms more comfortable", systemImage: "sofa"),
                OnboardingAnswerOption(id: "storage", title: "Organize storage", systemImage: "archivebox"),
                OnboardingAnswerOption(id: "style", title: "Refresh the style", systemImage: "paintpalette")
            ]
        ),
        OnboardingQuestion(
            id: "home_size",
            title: "How many rooms do you want to track?",
            subtitle: "This helps shape the first setup.",
            options: [
                OnboardingAnswerOption(id: "small", title: "1-3 rooms", systemImage: "house"),
                OnboardingAnswerOption(id: "medium", title: "4-6 rooms", systemImage: "square.grid.2x2"),
                OnboardingAnswerOption(id: "large", title: "7+ rooms", systemImage: "building.2")
            ]
        ),
        OnboardingQuestion(
            id: "style",
            title: "Which style feels closest to you?",
            subtitle: "You can change this later.",
            options: [
                OnboardingAnswerOption(id: "minimal", title: "Minimal and calm", systemImage: "circle"),
                OnboardingAnswerOption(id: "warm", title: "Warm and cozy", systemImage: "sun.max"),
                OnboardingAnswerOption(id: "bold", title: "Bold and expressive", systemImage: "sparkles")
            ]
        ),
        OnboardingQuestion(
            id: "priority_room",
            title: "Which room needs attention first?",
            subtitle: "Start with one clear win.",
            options: [
                OnboardingAnswerOption(id: "bedroom", title: "Bedroom", systemImage: "bed.double"),
                OnboardingAnswerOption(id: "kitchen", title: "Kitchen", systemImage: "fork.knife"),
                OnboardingAnswerOption(id: "office", title: "Office", systemImage: "desktopcomputer")
            ]
        ),
        OnboardingQuestion(
            id: "budget",
            title: "What kind of changes are you planning?",
            subtitle: "Small updates count too.",
            options: [
                OnboardingAnswerOption(id: "free", title: "Use what I already have", systemImage: "arrow.triangle.2.circlepath"),
                OnboardingAnswerOption(id: "small", title: "Small purchases", systemImage: "bag"),
                OnboardingAnswerOption(id: "bigger", title: "Bigger upgrades", systemImage: "cart")
            ]
        ),
        OnboardingQuestion(
            id: "pace",
            title: "How do you like to work on home projects?",
            subtitle: "The app can feel light or structured.",
            options: [
                OnboardingAnswerOption(id: "slow", title: "Slow and relaxed", systemImage: "leaf"),
                OnboardingAnswerOption(id: "weekly", title: "A little every week", systemImage: "calendar"),
                OnboardingAnswerOption(id: "focused", title: "Focused sessions", systemImage: "timer")
            ]
        ),
        OnboardingQuestion(
            id: "motivation",
            title: "What should the app help you with most?",
            subtitle: "Last one.",
            options: [
                OnboardingAnswerOption(id: "clarity", title: "Understand what to do next", systemImage: "list.bullet.clipboard"),
                OnboardingAnswerOption(id: "progress", title: "Track visible progress", systemImage: "chart.line.uptrend.xyaxis"),
                OnboardingAnswerOption(id: "ideas", title: "Keep ideas in one place", systemImage: "lightbulb")
            ]
        )
    ]
}
