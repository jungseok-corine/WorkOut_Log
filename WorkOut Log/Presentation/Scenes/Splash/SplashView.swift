//
//  SplashView.swift
//  WorkOut Log
//
//  Created by Claude on 16/10/2025.
//

import SwiftUI

struct WorkoutQuote {
    let text: String
    let author: String
}

struct SplashView: View {
    @Binding var isPresented: Bool
    @AccessibilityFocusState private var quoteFocused: Bool
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    private let quotes: [WorkoutQuote] = [
        WorkoutQuote(
            text: "The last three or four reps is what makes the muscle grow. This area of pain divides a champion from someone who is not a champion.",
            author: "Arnold Schwarzenegger"
        ),
        WorkoutQuote(
            text: "Strength does not come from physical capacity. It comes from an indomitable will.",
            author: "Mahatma Gandhi"
        ),
        WorkoutQuote(
            text: "The only bad workout is the one that didn't happen.",
            author: "Unknown"
        ),
        WorkoutQuote(
            text: "Take care of your body. It's the only place you have to live.",
            author: "Jim Rohn"
        ),
        WorkoutQuote(
            text: "The pain you feel today will be the strength you feel tomorrow.",
            author: "Unknown"
        ),
        WorkoutQuote(
            text: "Success isn't always about greatness. It's about consistency. Consistent hard work leads to success.",
            author: "Dwayne 'The Rock' Johnson"
        ),
        WorkoutQuote(
            text: "The body achieves what the mind believes.",
            author: "Napoleon Hill"
        ),
        WorkoutQuote(
            text: "Don't count the days, make the days count.",
            author: "Muhammad Ali"
        ),
        WorkoutQuote(
            text: "The only way to define your limits is by going beyond them.",
            author: "Arthur C. Clarke"
        ),
        WorkoutQuote(
            text: "Champions aren't made in gyms. Champions are made from something they have deep inside them.",
            author: "Muhammad Ali"
        ),
        WorkoutQuote(
            text: "If something stands between you and your success, move it. Never be denied.",
            author: "Dwayne 'The Rock' Johnson"
        ),
        WorkoutQuote(
            text: "You don't have to be great to start, but you have to start to be great.",
            author: "Zig Ziglar"
        ),
        WorkoutQuote(
            text: "The difference between the impossible and the possible lies in a person's determination.",
            author: "Tommy Lasorda"
        ),
        WorkoutQuote(
            text: "Fall seven times, stand up eight.",
            author: "Japanese Proverb"
        ),
        WorkoutQuote(
            text: "A one hour workout is 4% of your day. No excuses.",
            author: "Unknown"
        )
    ]

    private var randomQuote: WorkoutQuote {
        quotes.randomElement() ?? quotes[0]
    }

    @State private var selectedQuote: WorkoutQuote
    @State private var opacity: Double = 0.0

    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        // Select quote on init to keep it stable during view lifecycle
        let selected = [
            WorkoutQuote(
                text: "The last three or four reps is what makes the muscle grow. This area of pain divides a champion from someone who is not a champion.",
                author: "Arnold Schwarzenegger"
            ),
            WorkoutQuote(
                text: "Strength does not come from physical capacity. It comes from an indomitable will.",
                author: "Mahatma Gandhi"
            ),
            WorkoutQuote(
                text: "The only bad workout is the one that didn't happen.",
                author: "Unknown"
            ),
            WorkoutQuote(
                text: "Take care of your body. It's the only place you have to live.",
                author: "Jim Rohn"
            ),
            WorkoutQuote(
                text: "The pain you feel today will be the strength you feel tomorrow.",
                author: "Unknown"
            ),
            WorkoutQuote(
                text: "Success isn't always about greatness. It's about consistency. Consistent hard work leads to success.",
                author: "Dwayne 'The Rock' Johnson"
            ),
            WorkoutQuote(
                text: "The body achieves what the mind believes.",
                author: "Napoleon Hill"
            ),
            WorkoutQuote(
                text: "Don't count the days, make the days count.",
                author: "Muhammad Ali"
            ),
            WorkoutQuote(
                text: "The only way to define your limits is by going beyond them.",
                author: "Arthur C. Clarke"
            ),
            WorkoutQuote(
                text: "Champions aren't made in gyms. Champions are made from something they have deep inside them.",
                author: "Muhammad Ali"
            ),
            WorkoutQuote(
                text: "If something stands between you and your success, move it. Never be denied.",
                author: "Dwayne 'The Rock' Johnson"
            ),
            WorkoutQuote(
                text: "You don't have to be great to start, but you have to start to be great.",
                author: "Zig Ziglar"
            ),
            WorkoutQuote(
                text: "The difference between the impossible and the possible lies in a person's determination.",
                author: "Tommy Lasorda"
            ),
            WorkoutQuote(
                text: "Fall seven times, stand up eight.",
                author: "Japanese Proverb"
            ),
            WorkoutQuote(
                text: "A one hour workout is 4% of your day. No excuses.",
                author: "Unknown"
            )
        ].randomElement() ?? WorkoutQuote(text: "Start today.", author: "Unknown")
        self._selectedQuote = State(initialValue: selected)
    }

    var body: some View {
        ZStack {
            // Background (matching LaunchScreen)
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Logo placeholder (should match LaunchScreen logo)
                Image(systemName: "figure.strengthtraining.traditional")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)

                // Quote section
                VStack(spacing: 16) {
                    Text(selectedQuote.text)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .accessibilityIdentifier("splashQuoteText")
                        .accessibilityFocused($quoteFocused)

                    Text("— \(selectedQuote.author)")
                        .font(.caption)
                        .italic()
                        .foregroundColor(.white.opacity(0.8))
                        .accessibilityIdentifier("splashQuoteAuthor")
                }

                Spacer()

                // Tap to dismiss hint
                Text("Tap to continue")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 32)
            }
            .opacity(opacity)
        }
        .accessibilityIdentifier("splashDismissTapOverlay")
        .onTapGesture {
            dismiss()
        }
        .onAppear {
            // Fade in
            withAnimation(.easeIn(duration: 0.3)) {
                opacity = 1.0
            }

            // Set focus for VoiceOver
            quoteFocused = true

            // Auto-dismiss after delay (longer for VoiceOver)
            let delay = voiceOverEnabled ? 5.0 : 2.5
            Task {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                if isPresented {
                    dismiss()
                }
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.35)) {
            opacity = 0.0
        }

        Task {
            try? await Task.sleep(nanoseconds: 350_000_000) // 0.35s
            isPresented = false
        }
    }
}
