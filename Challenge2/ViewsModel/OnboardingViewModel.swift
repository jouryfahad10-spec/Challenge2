//
//  OnboardingViewModel.swift
//  Challenge2
//
//  Created by Aljoury on 05/06/1448 AH.
//

import Foundation
import Combine

class OnboardingViewModel: ObservableObject {
    // المدخلات من الواجهة
    @Published var topicText: String = ""
    @Published var selectedDuration: LearningDuration = .week // الافتراضي Week
    
    
    @Published var navigateToActivity: Bool = false
    
    // خاصية ذكية للتحقق هل المستخدم كتب شيء أم لا (لتفعيل/تعطيل الزر)
    var isStartButtonEnabled: Bool {
        !topicText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // دالة اختيار المدة
    func selectDuration(_ duration: LearningDuration) {
        selectedDuration = duration
    }
    
    // دالة عند الضغط على Start Learning
    func startLearning() {
        guard isStartButtonEnabled else { return }
        
        let goal = LearningGoal(topic: topicText, duration: selectedDuration)
        print("تم حفظ الهدف: \(goal.topic) خلال \(goal.duration.rawValue)")
        
        navigateToActivity = true
        // هنا لاحقاً تكتب كود الحفظ (UserDefaults أو SwiftData) والانتقال للشاشة التالية
    }
}
