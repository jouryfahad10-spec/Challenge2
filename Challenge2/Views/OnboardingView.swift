import SwiftUI

struct OnboardingView: View {
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("currentTopic") private var savedTopic: String = ""
    @AppStorage("selectedDuration") private var savedDurationRaw: String = LearningDuration.week.rawValue
    
    // ربط الواجهة بالـ ViewModel
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            // الخلفية السوداء
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 28) {
                
                // 1. الأيقونة العلوية
                HStack {
                    Spacer()
                    Image(systemName: "flame.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundColor(.orange)
                    Spacer()
                }
                .padding(.top, 60)
                
                // 2. العنوان الترحيبي
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hello **Learner**")
                        .font(.system(size: 38))
                        .foregroundColor(.white)
                    
                    Text("This app will help you learn everyday!")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
                
                // 3. حقل الإدخال (I want to learn)
                VStack(alignment: .leading, spacing: 8) {
                    Text("I want to learn")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("", text: $viewModel.topicText, prompt: Text("Swift").foregroundColor(.gray.opacity(0.6)))
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                    
                    Divider()
                        .background(Color.gray.opacity(0.4))
                }
                .padding(.top, 10)
                
                // 4. أزرار المدة (Week, Month, Year)
                VStack(alignment: .leading, spacing: 12) {
                    Text("I want to learn it in a")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        ForEach(LearningDuration.allCases) { duration in
                            let isSelected = viewModel.selectedDuration == duration
                            
                            Button(action: {
                                viewModel.selectDuration(duration)
                            }) {
                                Text(duration.rawValue)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(isSelected ? .white : .gray)
                                    .padding(.horizontal, 26)
                                    .frame(height: 46)
                                    .liquidGlass(in: Capsule(),
                                                 tint: isSelected ? .orange : nil,
                                                 interactive: true)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Spacer()
                
                // 5. زر البدء السفلي والنص التوضيحي (في النص مثل التصميم)
                VStack(spacing: 12) {
                    Button(action: {
                        // نحفظ الموضوع والمدة أول، وبعدين نقفل الأونبوردنق
                        savedTopic = viewModel.topicText.trimmingCharacters(in: .whitespacesAndNewlines)
                        savedDurationRaw = viewModel.selectedDuration.rawValue
                        
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }) {
                        Text("Start Learning")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 151, height: 46)
                            .liquidGlass(in: Capsule(),
                                         tint: viewModel.isStartButtonEnabled ? .orange : Color.orange.opacity(0.4),
                                         interactive: true)
                    }
                    .buttonStyle(.plain)
                    .disabled(!viewModel.isStartButtonEnabled)
                    
                    Text("You can edit your desire later")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 4)
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    OnboardingView()
}
