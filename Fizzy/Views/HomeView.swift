//
//  HomeView.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var newPlayerName: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .blur(radius: 4)
                    .opacity(0.2)
                
                VStack(spacing: 32) {
                    Text("Setup Your Game")
                        .font(.system(.title, design: .rounded, weight: .semibold))
                        .foregroundColor(Constants.textPrimary)
                        .padding(.top, 60)
                    
                    Spacer()
                    
                    if !viewModel.playerNames.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100, maximum: 250), spacing: 8, alignment: .center), count: 3), alignment: .center, spacing: 8) {  // Grid with up to 3 columns, wraps vertically
                            ForEach(viewModel.playerNames.indices, id: \.self) { index in
                                PlayerBubble(name: viewModel.playerNames[index]) {
                                    viewModel.playerNames.remove(at: index)
                                }
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.playerNames)
                            }
                        }
                        .padding(.horizontal, 35)
                    }
                    
                    ZStack(alignment: .trailing) {
                        TextField("Type to add members...", text: $newPlayerName)
                            .font(.system(.body, design: .rounded))
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(Constants.cornerRadius)
                            .shadow(color: Constants.shadowColor, radius: 4)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 40)
                            .onSubmit {
                                addPlayer()
                            }
                        
                        Button(action: {
                            addPlayer()
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Constants.primaryColor)
                                .padding(8)
                        }
                        .padding(.trailing, 60)
                        .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    
                    Spacer()
                    
                    Button("Customize Game", systemImage: "arrow.right") {
                        Task { await viewModel.startGame() }
                    }
                    .font(.system(.headline, design: .rounded))
                    .padding()
                    .background(Constants.accentColor.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(Constants.cornerRadius)
                    .shadow(color: Constants.shadowColor, radius: 6)
                    .disabled(viewModel.isStartingGame || viewModel.playerNames.allSatisfy { $0.isEmpty })
                    .frame(maxWidth: .infinity) // Full width
                    .padding(.horizontal, 40)   // Match text field
                    
                    if viewModel.isStartingGame {
                        ProgressView()
                            .tint(Constants.primaryColor)
                            .scaleEffect(1.2)
                    }
                }
                .padding(.vertical, 20)     // Vertical padding for overall balance
                .padding(.horizontal, 40)   // Safe area insets
                .padding(.bottom, 20)       // Extra bottom for keyboard/button
                .ignoresSafeArea(.keyboard)
            }
            .navigationDestination(isPresented: Binding(get: { viewModel.gameSessionID != nil }, set: { _ in })) {
                if let id = viewModel.gameSessionID {
                    GameSetupView(gameID: id)
                }
            }
        }
    }
    
    private func addPlayer() {
        let trimmedName = newPlayerName.trimmingCharacters(in: .whitespaces)
        if !trimmedName.isEmpty && viewModel.playerNames.count < 10 {
            viewModel.playerNames.append(trimmedName)
            newPlayerName = ""
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}

struct PlayerBubble: View {
    let name: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {  // Increased spacing for readability
            Text(name)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.white)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(2)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Constants.primaryColor.opacity(0.9))
        .cornerRadius(24)  // Softer corners
        .shadow(color: Constants.shadowColor, radius: 5)
    }
}

#Preview {
    HomeView()
}
