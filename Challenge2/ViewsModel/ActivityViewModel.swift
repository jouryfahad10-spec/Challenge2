import Foundation
import Combine

enum DayStatus: String, Codable { // Codable عشان ينحفظ بالـ UserDefaults
    case `default`
    case learned
    case freezed
}

struct DayModel: Identifiable {
    let id = UUID()
    let date: Date
    let dayName: String
    let dayNumber: String
    let isToday: Bool
    var status: DayStatus = .default
}

class ActivityViewModel: ObservableObject {
    
    // المدة تنحفظ عشان لو عدّلها المستخدم تبقى بعد إغلاق التطبيق
    @Published var selectedDuration: LearningDuration {
        didSet { UserDefaults.standard.set(selectedDuration.rawValue, forKey: "selectedDuration") }
    }
    @Published var learnedDaysCount: Int {
        didSet { UserDefaults.standard.set(learnedDaysCount, forKey: "learnedDaysCount") }
    }
    @Published var freezedDaysCount: Int {
        didSet { UserDefaults.standard.set(freezedDaysCount, forKey: "freezedDaysCount") }
    }
    @Published var weekDays: [DayModel] = []
    
    @Published var isGoalEnded: Bool = false
    @Published var isGoalSuccessful: Bool = false
    
    // تاريخ بداية الهدف صار ينحفظ (
    private var startDate: Date
    private var endDate: Date
    
    @Published var currentTopic: String {
        didSet { UserDefaults.standard.set(currentTopic, forKey: "currentTopic") }
    }
    
    // التخزين الدائم للسجل السنوي
    @Published var activityRecords: [String: DayStatus] = [:] {
        didSet {
            if let encoded = try? JSONEncoder().encode(activityRecords) {
                UserDefaults.standard.set(encoded, forKey: "activityRecords")
            }
        }
    }
    
    var maxFreezes: Int {
        selectedDuration.maxFreezesAllowed
    }
    
    var todayStatus: DayStatus {
        get {
            weekDays.first(where: { $0.isToday })?.status ?? .default
        }
        set {
            if let index = weekDays.firstIndex(where: { $0.isToday }) {
                weekDays[index].status = newValue
            }
        }
    }
    
    var canLogToday: Bool {
        todayStatus == .default
    }
    
    var canFreezeToday: Bool {
        todayStatus == .default && freezedDaysCount < maxFreezes
    }
    
    init(topic: String, selectedDuration: LearningDuration) {
        let defaults = UserDefaults.standard
        
        self.currentTopic = defaults.string(forKey: "currentTopic") ?? topic
        self.selectedDuration = selectedDuration
        self.learnedDaysCount = defaults.integer(forKey: "learnedDaysCount")
        self.freezedDaysCount = defaults.integer(forKey: "freezedDaysCount")
        
        // استرجاع السجل السنوي المخزن
        if let savedData = defaults.data(forKey: "activityRecords"),
           let decodedRecords = try? JSONDecoder().decode([String: DayStatus].self, from: savedData) {
            self.activityRecords = decodedRecords
        }
        
        // تاريخ البداية: إذا محفوظ نستخدمه، وإذا أول مرة نحفظ اليوم
        let savedStart = defaults.double(forKey: "goalStartDate")
        let start: Date
        if savedStart > 0 {
            start = Date(timeIntervalSince1970: savedStart)
        } else {
            start = Date()
            defaults.set(start.timeIntervalSince1970, forKey: "goalStartDate")
        }
        self.startDate = start
        self.endDate = Self.calculateEndDate(from: start, duration: selectedDuration)
        
        generateCurrentWeekDays()
        checkIfGoalPeriodHasEnded()
    }
    
    private static func calculateEndDate(from start: Date, duration: LearningDuration) -> Date {
        let daysToAdd: Int
        switch duration {
        case .week: daysToAdd = 7
        case .month: daysToAdd = 30
        case .year: daysToAdd = 365
        }
        return Calendar.current.date(byAdding: .day, value: daysToAdd, to: start) ?? start
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func generateCurrentWeekDays() {
        let calendar = Calendar.current
        let today = Date()
        
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: today) else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        
        let dayNameFormatter = DateFormatter()
        dayNameFormatter.dateFormat = "EE"
        
        var days: [DayModel] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: interval.start) {
                let dayNum = dateFormatter.string(from: date)
                let fullDayName = dayNameFormatter.string(from: date).prefix(1).uppercased()
                let isToday = calendar.isDateInToday(date)
                
                let key = dateKey(for: date)
                let savedStatus = activityRecords[key] ?? .default
                
                days.append(DayModel(date: date, dayName: String(fullDayName), dayNumber: dayNum, isToday: isToday, status: savedStatus))
            }
        }
        self.weekDays = days
    }
    
    func checkIfGoalPeriodHasEnded() {
        if Date() >= endDate {
            isGoalEnded = true
            isGoalSuccessful = (learnedDaysCount >= 3)
        } else {
            isGoalEnded = false
        }
    }
    
    func logAsLearned() {
        guard canLogToday else { return }
        learnedDaysCount += 1
        todayStatus = .learned
        
        let key = dateKey(for: Date())
        activityRecords[key] = .learned
    }
    
    func freezeToday() {
        guard canFreezeToday else { return }
        freezedDaysCount += 1
        todayStatus = .freezed
        
        let key = dateKey(for: Date())
        activityRecords[key] = .freezed
    }
    
    // هدف جديد = بداية جديدة (تاريخ بداية جديد + تصفير العدادات)
    func updateGoal(newTopic: String, newDuration: LearningDuration) {
        currentTopic = newTopic
        selectedDuration = newDuration
        
        startDate = Date()
        UserDefaults.standard.set(startDate.timeIntervalSince1970, forKey: "goalStartDate")
        endDate = Self.calculateEndDate(from: startDate, duration: newDuration)
        
        learnedDaysCount = 0
        freezedDaysCount = 0
       
        generateCurrentWeekDays()
        checkIfGoalPeriodHasEnded()
    }
}
