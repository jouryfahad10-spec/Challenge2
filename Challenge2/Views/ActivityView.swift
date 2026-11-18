import SwiftUI

// MARK: - Activity screen
struct ActivityView: View {
    @StateObject var viewModel: ActivityViewModel // استقبال الـ ViewModel الحقيقي المُمرر من MyApp
    
    @State private var showCalendarView = false
    @State private var showEditGoalView = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 14) {
                
                // 1. العنوان والأيقونات العلوية
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.currentTopic)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(currentFormattedDate())
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    GlassEffectContainer(spacing: 8) {
                        HStack(spacing: 12) {
                            Button(action: { showCalendarView = true }) {
                                Image(systemName: "calendar")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .glassEffect(.regular.interactive(), in: Circle())
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: { showEditGoalView = true }) {
                                Image(systemName: "pencil.and.outline")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .glassEffect(.regular.interactive(), in: Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.top, 8)
                
                // 2. شريط الأيام (موزّع بالتساوي على عرض الشاشة)
                HStack(spacing: 0) {
                    ForEach(viewModel.weekDays) { day in
                        VStack(spacing: 6) {
                            Text(day.dayName)
                                .font(.caption2)
                                .foregroundColor(.white)
                            
                            let bgColor: Color = {
                                switch day.status {
                                case .learned: return Color.orange.opacity(0.25)
                                case .freezed: return Color.cyan.opacity(0.25)
                                case .default: return day.isToday ? Color.orange : Color.clear
                                }
                            }()
                            
                            let textColor: Color = {
                                switch day.status {
                                case .learned: return .orange
                                case .freezed: return .cyan
                                case .default: return day.isToday ? .black : .white
                                }
                            }()
                            
                            Text(day.dayNumber)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(textColor)
                                .frame(width: 38, height: 38)
                                .background(bgColor)
                                .clipShape(Circle())
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 2)
                
                // 3. مربعات العدادات (Learned / Freezed)
                GlassEffectContainer(spacing: 10) {
                    HStack(spacing: 14) {
                        VStack(spacing: 4) {
                            Image(systemName: "flame.fill").foregroundColor(.orange)
                            Text("\(viewModel.learnedDaysCount) days").font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                            Text("Learned").font(.caption2).foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        
                        VStack(spacing: 4) {
                            Image(systemName: "snowflake").foregroundColor(.cyan)
                            Text("\(viewModel.freezedDaysCount) days").font(.subheadline).fontWeight(.bold).foregroundColor(.white)
                            Text("Freezed").font(.caption2).foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                }
                
                Spacer()
                
                // 4. عرض المحتوى (حالة انتهاء المدة أو حالة الأزرار اليومية)
                if viewModel.isGoalEnded {
                    VStack(spacing: 70) {
                        VStack(spacing: 16) {
                            Image(systemName: viewModel.isGoalSuccessful ? "hands.clap.fill" : "xmark.seal.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            VStack(spacing: 4) {
                                Text(viewModel.isGoalSuccessful ? "Well done!" : "You didn't reach your goal this time.")
                                    .font(.headline).fontWeight(.bold).foregroundColor(.white)
                                Text(viewModel.isGoalSuccessful ? "Ready for your next goal?" : "Want to set another goal?")
                                    .font(.subheadline).foregroundColor(.gray)
                            }
                        }
                        
                        GlassEffectContainer {
                            Button(action: { showEditGoalView = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "pencil.and.outline")
                                    Text("Set a goal")
                                }
                                .font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 14)
                                .glassEffect(.regular.tint(.orange).interactive(), in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    GlassEffectContainer(spacing: 20) {
                        VStack(spacing: 14) {
                            // الدائرة الكبيرة (كلها قابلة للضغط)
                            Button(action: { viewModel.logAsLearned() }) {
                                Text(viewModel.todayStatus == .learned ? "Logged as Learned" : "Log as Learned")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(viewModel.todayStatus == .learned ? .gray : .white)
                                    .frame(width: 272, height: 272)
                                    .glassEffect(
                                        .regular
                                            .tint(viewModel.todayStatus == .learned ? nil : .orange)
                                            .interactive(),
                                        in: Circle()
                                    )
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 48)
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 6) {
                                Button(action: { viewModel.freezeToday() }) {
                                    Text(viewModel.todayStatus == .freezed ? "Freezed for a day" : "Freeze for a day")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(viewModel.canFreezeToday ? .white : .gray)
                                        .frame(width: 272, height: 46)
                                        .glassEffect(
                                            .regular
                                                .tint(viewModel.canFreezeToday ? .cyan : nil)
                                                .interactive(),
                                            in: Capsule()
                                        )
                                }
                                .buttonStyle(.plain)
                                .disabled(!viewModel.canFreezeToday)
                                
                                Text("\(viewModel.freezedDaysCount) out of \(viewModel.maxFreezes) Freezes used")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showCalendarView) {
            CalendarView(viewModel: viewModel)
        }
        .sheet(isPresented: $showEditGoalView) {
            EditGoalView(viewModel: viewModel)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func currentFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
    }
}

#Preview {
    ActivityView(viewModel: ActivityViewModel(topic: "SwiftUI", selectedDuration: .week))
}
