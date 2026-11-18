//
//  LearningGoalModel.swift
//  Challenge2
//
//  Created by Aljoury on 05/06/1448 AH.
//

import Foundation


// خيارات المدة الزمنية

enum LearningDuration: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    
    var id: String { self.rawValue }
    
    // عدد الفريزات المسموح بها حسب المدة
    var maxFreezesAllowed: Int {
        switch self {
        case .week: return 2
        case .month: return 8
        case .year: return 96
        }
    }
}

// نموذج الهدف التعليمي الذي سنحفظه أو نمرره للشاشة التالية
struct LearningGoal {
    var topic: String
    var duration: LearningDuration
}
