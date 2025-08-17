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
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("Background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .blur(radius: Constants.shadowRadius)
                    .opacity(Constants.backgroundOpacity)
                
                VStack(spacing: Constants.smallSpacing) {
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundColor(Constants.primaryColor)
                        .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius / 2)
                    
                    Text("Setup Your Game")
                        .font(Constants.titleFont)
                        .foregroundColor(Constants.textPrimary)
                        .padding(.top)
                    
                    Spacer()
                    
                    if !viewModel.playerNames.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100, maximum: 400), spacing: Constants.smallSpacing, alignment: .center), count: 2), alignment: .center, spacing: Constants.smallSpacing){
                            ForEach(viewModel.playerNames.indices, id: \.self) { index in
                                PlayerBubble(name: viewModel.playerNames[index]) {
                                    viewModel.playerNames.remove(at: index)
                                }
                                .transition(.scale.combined(with: .opacity))
                                .animation(.spring(response: Constants.animationDuration, dampingFraction: 0.8), value: viewModel.playerNames)
                            }
                        }
                        .padding(.horizontal, Constants.mediumSpacing * 2)
                        .padding(.bottom)
                    }
                    
                    ZStack(alignment: .trailing) {
                        TextField("Type to add members...", text: $newPlayerName)
                            .font(Constants.bodyFont)
                            .textFieldStyle(.plain)
                            .padding(Constants.mediumSpacing)
                            .background(Constants.cardBackground) 
                            .cornerRadius(Constants.cornerRadius)
                            .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, Constants.mediumSpacing * 2)
                            .onSubmit {
                                addPlayer()
                            }
                            .foregroundColor(Constants.textPrimary)
                        Button(action: {
                            addPlayer()
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Constants.primaryColor)
                                .padding(Constants.smallSpacing)
                        }
                        .padding(.trailing, Constants.mediumSpacing * 3)
                        .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    
                    Spacer()
                    
                    if !viewModel.isStartingGame {
                        Button("Customize Game", systemImage: "arrow.right") {
                            Task { await viewModel.startGame() }
                        }
                        .font(.system(.headline, design: .rounded))
                        .padding(Constants.mediumSpacing)
                        .background(Constants.accentColor.opacity(Constants.buttonOpacity))
                        .foregroundColor(Color.white)
                        .cornerRadius(Constants.cornerRadius)
                        .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius + 2)
                        .disabled(viewModel.isStartingGame || viewModel.playerNames.allSatisfy { $0.isEmpty })
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, Constants.mediumSpacing * 2)
                    } else {
                        ProgressView()
                            .tint(Constants.primaryColor)
                            .scaleEffect(1.2)
                    }
                }
                .padding(.vertical, Constants.mediumSpacing)
                .padding(.horizontal, Constants.horizontalLargeSpacing)
                .padding(.bottom, Constants.mediumSpacing)
                .ignoresSafeArea(.keyboard)
            }
            .navigationDestination(isPresented: Binding(get: { viewModel.gameSessionID != nil }, set: { _ in })) {
                if let id = viewModel.gameSessionID {
                    GameSetupView(gameID: id)
                }
            }
            .background(Constants.background)
            .toolbar {  // Add toolbar for top placement
                ToolbarItem(placement: .topBarTrailing) {
                    Button("", systemImage: "iphone.and.arrow.right.outward") {
                        showLogoutConfirmation = true
                    }
                    .foregroundColor(Constants.penaltyColor)  // Red tint for logout
                }
            }
            .confirmationDialog("Are you sure you want to log out?", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                Button("Yes", role: .destructive) {
                    FirebaseService.shared.signOut()
                }
                Button("No", role: .cancel) {}
            }
        }
    }
    
    private func addPlayer() {
        let trimmedName = newPlayerName.trimmingCharacters(in: .whitespaces)
        if !trimmedName.isEmpty && viewModel.playerNames.count < Constants.maxPlayers {
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
        HStack(spacing: Constants.smallSpacing) {
            Text(name)
                .font(Constants.subheadlineFont)
                .foregroundColor(Constants.textPrimary)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(Constants.textSecondary)
                    .padding(2)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Constants.mediumSpacing)
        .padding(.vertical, Constants.smallSpacing * 1.25)
        .background(Constants.primaryColor.opacity(0.8))
        .cornerRadius(Constants.cornerRadius * 1.5)
        .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius + 1)
    }
}

#Preview {
    HomeView()
}
