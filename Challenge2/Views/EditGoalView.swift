//
//  EditGoalView.swift
//  Challenge2
//
//  Created by Aljoury on 06/06/1448 AH.
//

import SwiftUI

struct EditGoalView: View {
    // نمرر الـ ViewModel أو نستخدمه مباشرة عشان التعديل ينعكس فوراً
    @ObservedObject var viewModel: ActivityViewModel
    
    @State private var topicText: String
    @State private var selectedDuration: LearningDuration
    @State private var showAlert = false
    
    @Environment(\.dismiss) var dismiss
    
    // نستقبل الـ ViewModel في الـ init
    init(viewModel: ActivityViewModel) {
        self.viewModel = viewModel
        _topicText = State(initialValue: viewModel.currentTopic)
        _selectedDuration = State(initialValue: viewModel.selectedDuration)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                
                // 1. الشريط العلوي
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
                    
                    Text("Learning Goal")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showAlert = true }) {
                        Image(systemName: "checkmark")
                            .font(.title3)
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.orange)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 10)
                
                // 2. خانة النص الحقيقية
                VStack(alignment: .leading, spacing: 8) {
                    Text("I want to learn")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("", text: $topicText)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                    
                    Divider()
                        .background(Color.gray.opacity(0.4))
                }
                .padding(.top, 10)
                
                // 3. أزرار المدة
                VStack(alignment: .leading, spacing: 12) {
                    Text("I want to learn it in a")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        ForEach(LearningDuration.allCases) { duration in
                            let isSelected = selectedDuration == duration
                            
                            Button(action: {
                                selectedDuration = duration
                            }) {
                                Text(duration.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(isSelected ? .white : .gray)
                                    .padding(.horizontal, 22)
                                    .padding(.vertical, 12)
                                    .background(isSelected ? Color.orange : Color.white.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            // 4. نافذة التنبيه (Alert Popup)
            if showAlert {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    VStack(spacing: 6) {
                        Text("Update goal?")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("If you update now, your streak will start over.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)
                    
                    HStack(spacing: 12) {
                        Button(action: { showAlert = false }) {
                            Text("Dismiss")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        
                        Button(action: {
                            // **هنا يتم حفظ التعديلات الحقيقية في الـ ViewModel الأساسي!**
                            viewModel.updateGoal(newTopic: topicText, newDuration: selectedDuration)
                            showAlert = false
                            dismiss()
                        }) {
                            Text("Update")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.orange)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(20)
                .background(Color(.systemGray6).opacity(0.25))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal, 30)
            }
        }
    }
}
#Preview {
    EditGoalView(viewModel: ActivityViewModel(topic: "SwiftUI", selectedDuration: .week))
}
