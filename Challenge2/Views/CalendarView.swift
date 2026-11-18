import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: ActivityViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                
                // 1. الشريط العلوي (زر الرجوع والعنوان)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Activities")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // 2. قائمة الأشهر والتاريخ
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        ForEach(generateMonthsForCurrentYear(), id: \.self) { monthDate in
                            MonthSectionView(monthDate: monthDate, viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    func generateMonthsForCurrentYear() -> [Date] {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        var months: [Date] = []
        
        for month in 1...12 {
            var components = DateComponents()
            components.year = currentYear
            components.month = month
            components.day = 1
            if let date = calendar.date(from: components) {
                months.append(date)
            }
        }
        return months
    }
}

// --- مكون عرض شهر واحد مع أيامه ---
struct MonthSectionView: View {
    let monthDate: Date
    @ObservedObject var viewModel: ActivityViewModel
    
    private let daysOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(monthTitleString(from: monthDate))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(generateDaysInMonth(for: monthDate), id: \.self) { date in
                    if let date = date {
                        DayCellView(date: date, viewModel: viewModel)
                    } else {
                        Color.clear.frame(height: 32)
                    }
                }
            }
        }
    }
    
    func monthTitleString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    func generateDaysInMonth(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in range {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(dayDate)
            }
        }
        return days
    }
}

// --- تصميم خلية اليوم الواحد (بدون أي تكرار) ---
struct DayCellView: View {
    let date: Date
    @ObservedObject var viewModel: ActivityViewModel
    
    private var dateKeyStr: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    var body: some View {
        let calendar = Calendar.current
        let dayNumberStr = String(calendar.component(.day, from: date))
        
        let status = viewModel.activityRecords[dateKeyStr] ?? .default
        let isToday = calendar.isDateInToday(date)
        
        let bgColor: Color = {
            switch status {
            case .learned: return Color.orange
            case .freezed: return Color.cyan
            case .default: return isToday ? Color.orange : Color.white.opacity(0.05)
            }
        }()
        
        let textColor: Color = (status != .default || isToday) ? .black : .white.opacity(0.8)
        
        Text(dayNumberStr)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(textColor)
            .frame(width: 32, height: 32)
            .background(bgColor)
            .clipShape(Circle())
    }
}

#Preview {
    CalendarView(viewModel: ActivityViewModel(topic: "SwiftUI", selectedDuration: .week))
}
