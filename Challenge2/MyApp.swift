import SwiftUI
@main

struct MyApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("currentTopic") private var savedTopic: String = ""
    @AppStorage("selectedDuration") private var savedDurationRaw: String = LearningDuration.week.rawValue

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                NavigationStack {
                    ActivityView(
                        viewModel: ActivityViewModel(
                            topic: savedTopic,
                            selectedDuration: LearningDuration(rawValue: savedDurationRaw) ?? .week
                        )
                    )
                }
            } else {
                OnboardingView()
            }
        }
    }
}
