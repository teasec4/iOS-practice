//
//  OnboardingFlowView.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/23/26.
//
import SwiftUI

struct OnboardingFlowView: View {
    let onComplete: (UserProfile) -> Void

    @State private var step: OnboardingStep = .welcome
    @State private var currentQuestionIndex = 0
    @State private var answers: [String: OnboardingAnswerOption] = [:]
    @State private var analysisProgress = 0.0
    @State private var analysisTask: Task<Void, Never>?

    private let questions = OnboardingQuestion.defaultQuestions

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            switch step {
            case .welcome:
                WelcomeOnboardingView {
                    withAnimation {
                        step = .questions
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            case .questions:
                QuestionnaireOnboardingView(
                    question: questions[currentQuestionIndex],
                    questionNumber: currentQuestionIndex + 1,
                    questionsCount: questions.count,
                    selectedOption: answers[questions[currentQuestionIndex].id],
                    canGoBack: currentQuestionIndex > 0,
                    isLastQuestion: currentQuestionIndex == questions.count - 1,
                    onSelect: selectAnswer,
                    onBack: goToPreviousQuestion,
                    onAnalyze: startAnalysis
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            case .analyzing:
                AnalyzingOnboardingView(progress: analysisProgress)
                    .transition(.opacity)
            case .paywall:
                PaywallView(
                    onStartTrial: {
                        completeOnboarding()
                    },
                    onContinueFree: {
                        completeOnboarding()
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .onDisappear {
            analysisTask?.cancel()
        }
    }

    private func goToPreviousQuestion() {
        guard currentQuestionIndex > 0 else {
            return
        }

        withAnimation {
            currentQuestionIndex -= 1
        }
    }

    private func selectAnswer(_ option: OnboardingAnswerOption) {
        answers[questions[currentQuestionIndex].id] = option

        guard currentQuestionIndex < questions.count - 1 else {
            return
        }

        withAnimation(.snappy) {
            currentQuestionIndex += 1
        }
    }

    private func startAnalysis() {
        analysisProgress = 0

        withAnimation {
            step = .analyzing
        }

        analysisTask?.cancel()
        analysisTask = Task { @MainActor in
            for progressStep in 1...100 {
                try? await Task.sleep(nanoseconds: 50_000_000)

                guard !Task.isCancelled else {
                    return
                }

                withAnimation(.linear(duration: 0.05)) {
                    analysisProgress = Double(progressStep) / 100
                }
            }

            withAnimation {
                step = .paywall
            }
        }
    }

    private func completeOnboarding() {
        onComplete(UserProfile.make(from: answers))
    }
}

private enum OnboardingStep {
    case welcome
    case questions
    case analyzing
    case paywall
}

private struct WelcomeOnboardingView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 18) {
                Image(systemName: "house.and.flag")
                    .font(.system(size: 58, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 112, height: 112)
                    .background(.blue, in: Circle())

                VStack(spacing: 10) {
                    Text("Welcome to your room planner")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("Start a short survey so we can understand your space and prepare a better first setup.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            Button {
                onStart()
            } label: {
                Label("Start survey", systemImage: "arrow.right")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(24)
    }
}

private struct QuestionnaireOnboardingView: View {
    let question: OnboardingQuestion
    let questionNumber: Int
    let questionsCount: Int
    let selectedOption: OnboardingAnswerOption?
    let canGoBack: Bool
    let isLastQuestion: Bool
    let onSelect: (OnboardingAnswerOption) -> Void
    let onBack: () -> Void
    let onAnalyze: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Question \(questionNumber) of \(questionsCount)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                ProgressView(value: Double(questionNumber), total: Double(questionsCount))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(question.title)
                    .font(.title)
                    .fontWeight(.bold)

                Text(question.subtitle)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                ForEach(question.options) { option in
                    OnboardingOptionButton(
                        option: option,
                        isSelected: selectedOption == option
                    ) {
                        onSelect(option)
                    }
                }
            }

            Spacer()

            HStack(spacing: 12) {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 42, height: 42)
                }
                .buttonStyle(.bordered)
                .disabled(!canGoBack)
                .accessibilityLabel("Previous question")

                if isLastQuestion {
                    Button {
                        onAnalyze()
                    } label: {
                        Label("Analyze", systemImage: "wand.and.sparkles")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedOption == nil)
                }
            }
        }
        .padding(24)
    }
}

private struct OnboardingOptionButton: View {
    let option: OnboardingAnswerOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: option.systemImage)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : .blue)
                    .frame(width: 34, height: 34)
                    .background(isSelected ? .blue : Color.blue.opacity(0.12), in: Circle())

                Text(option.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? .blue : .secondary)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct AnalyzingOnboardingView: View {
    let progress: Double

    private var percentage: Int {
        Int((progress * 100).rounded())
    }

    private var statusTitle: String {
        switch percentage {
        case 0..<20:
            "Reading your room priorities"
        case 20..<45:
            "Understanding your home style"
        case 45..<70:
            "Matching item categories"
        case 70..<95:
            "Preparing your first setup"
        default:
            "Almost ready"
        }
    }

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "wand.and.sparkles")
                .font(.system(size: 54, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 104, height: 104)
                .background(.blue, in: Circle())

            VStack(spacing: 10) {
                Text("Analyzing your profile")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(statusTitle)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Text("\(percentage)%")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())

                ProgressView(value: progress, total: 1)
                    .progressViewStyle(.linear)
                    .tint(.blue)
            }
            .padding(.top, 4)

            Spacer()
        }
        .padding(24)
    }
}

#Preview {
    OnboardingFlowView { _ in }
        .environment(SubscriptionManager.preview())
}
