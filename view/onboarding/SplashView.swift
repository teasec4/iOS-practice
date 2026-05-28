//
//  SplashView.swift
//  backtogame
//
//  Created by Максим Ковалев on 5/28/26.
//
import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var progress = 0.0
    @State private var activeStepIndex = 0

    private let preparationSteps = [
        SplashPreparationStep(title: "Checking your setup", systemImage: "checklist", tint: .blue),
        SplashPreparationStep(title: "Preparing rooms", systemImage: "square.grid.2x2", tint: .green),
        SplashPreparationStep(title: "Tuning recommendations", systemImage: "wand.and.sparkles", tint: .orange)
    ]

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 22) {
                    logo

                    VStack(spacing: 8) {
                        Text("BackToGame")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Preparing your room planner")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                }

                VStack(spacing: 18) {
                    progressBar

                    VStack(spacing: 10) {
                        ForEach(preparationSteps.indices, id: \.self) { index in
                            preparationRow(
                                step: preparationSteps[index],
                                isActive: index == activeStepIndex,
                                isComplete: index < activeStepIndex
                            )
                        }
                    }
                }
                .frame(maxWidth: 320)

                Spacer()
            }
            .padding(24)
        }
        .task {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                isAnimating = true
            }

            withAnimation(.easeOut(duration: 1.5)) {
                progress = 1
            }

            for index in 1..<preparationSteps.count {
                try? await Task.sleep(nanoseconds: 430_000_000)

                guard !Task.isCancelled else {
                    return
                }

                withAnimation(.snappy) {
                    activeStepIndex = index
                }
            }
        }
    }

    private var logo: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.18), lineWidth: 2)
                .frame(width: 142, height: 142)
                .scaleEffect(isAnimating ? 1.08 : 0.96)

            Circle()
                .stroke(Color.green.opacity(0.16), lineWidth: 2)
                .frame(width: 126, height: 126)
                .scaleEffect(isAnimating ? 0.96 : 1.08)

            Image(systemName: "house")
                .font(.system(size: 58, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 112, height: 112)
                .background(.blue, in: Circle())
                .scaleEffect(isAnimating ? 1.04 : 0.96)
                .shadow(color: Color.blue.opacity(0.22), radius: 18, y: 10)
        }
        .frame(width: 148, height: 148)
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.tertiarySystemFill))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .green],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: 8)
    }

    private func preparationRow(
        step: SplashPreparationStep,
        isActive: Bool,
        isComplete: Bool
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: isComplete ? "checkmark" : step.systemImage)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(isActive || isComplete ? .white : step.tint)
                .frame(width: 28, height: 28)
                .background(isActive || isComplete ? step.tint : Color(.secondarySystemGroupedBackground), in: Circle())

            Text(step.title)
                .font(.subheadline)
                .foregroundStyle(isActive ? .primary : .secondary)

            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
        .opacity(isActive || isComplete ? 1 : 0.68)
    }
}

private struct SplashPreparationStep {
    let title: String
    let systemImage: String
    let tint: Color
}

#Preview {
    SplashView()
}
