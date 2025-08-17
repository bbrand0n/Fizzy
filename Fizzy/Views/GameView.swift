//
//  GameView.swift
//  Fizzy
//
//  Created by Brandon Gibbons on 8/14/25.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @State private var showEditMenu = false
    
    init(gameID: String) {
        _viewModel = StateObject(wrappedValue: GameViewModel(gameID: gameID))
    }
    
    init(viewModel: GameViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: Constants.shadowRadius)
                .opacity(Constants.backgroundOpacity)
            
            if let session = viewModel.session {
                VStack(spacing: Constants.largeSpacing) {
                    if viewModel.isLoadingPrompt {
                        ProgressView("Generating Prompt...")
                            .progressViewStyle(.circular)
                            .tint(Constants.primaryColor)
                            .scaleEffect(1.5)
                    } else {
                        CardView(prompt: viewModel.prompt)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            .animation(.easeInOut(duration: Constants.animationDuration), value: viewModel.prompt)
                            .onTapGesture {
                                Task { await viewModel.generateNewPrompt() }
                            }
                            .padding(.horizontal, Constants.mediumSpacing * 4)
                            .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius)
                    }
                }
                .padding(Constants.mediumSpacing)
                
                // Error alert
                .alert("Error", isPresented: Binding(get: { viewModel.error != nil }, set: { _ in viewModel.error = nil })) {
                    Button("OK") {}
                } message: {
                    Text(viewModel.error?.localizedDescription ?? "Unknown error")
                }
                
                // Popup menu sheet
                .sheet(isPresented: $showEditMenu) {
                    GameSettingsMenu(viewModel: viewModel)
                        .presentationDetents([.height(0.80 * UIScreen.main.bounds.height)])
                        .presentationDragIndicator(.visible)
                }
            } else {
                ProgressView("Loading Game...")
                    .tint(Constants.primaryColor)
            }
        }
        .background(Constants.background)
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                showEditMenu = true
            }) {
                HStack {
                    Text("Game Settings")
                        .font(Constants.bodyFont)
                    
                    Image(systemName: "gearshape")
                }
                .foregroundColor(Constants.textPrimary)
                .padding(Constants.mediumSpacing)
                .background(Constants.cardBackground)
                .cornerRadius(Constants.cornerRadius)
                .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius)
            }
            .padding(.bottom, Constants.mediumSpacing)
            .padding(.trailing, Constants.horizontalLargeSpacing + 20)
        }
        .onAppear {
            Task { await viewModel.generateNewPrompt() }
        }
    }
}

struct GameSettingsMenu: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var newPlayerName: String = ""
    @State private var updatedPlayerDetails: String = ""
    @State private var updatedCustomInstructions: String = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?  // Enum for multiple fields
    
    enum Field: Hashable {
        case playerDetails
        case customInstructions
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 45) {
                    Text("Edit Players & Details")
                        .font(Constants.titleFont)
                        .foregroundColor(Constants.textPrimary)
                    
                    // Player list with remove
                    if let session = viewModel.session {
                        VStack {
                            Text("Players")
                                .font(Constants.subheadlineFont)
                                .foregroundColor(Constants.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 5)
                            
                            VStack {
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100, maximum: 400), spacing: Constants.smallSpacing, alignment: .center), count: 2), alignment: .center, spacing: Constants.smallSpacing) {
                                    ForEach(session.players.indices, id: \.self) { index in
                                        PlayerBubble(name: session.players[index]) {
                                            viewModel.removePlayer(at: index)
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                        .animation(.spring(response: Constants.animationDuration, dampingFraction: 0.8), value: session.players)
                                    }
                                }
                                .padding(.bottom)
                                .padding(.top)
                                
                                // Add new player
                                HStack {
                                    ZStack(alignment: .trailing) {
                                        TextField("Add Player", text: $newPlayerName)
                                            .font(Constants.bodyFont)
                                            .textFieldStyle(.plain)
                                            .padding(.leading, Constants.mediumSpacing)
                                            .padding(.vertical, Constants.smallSpacing)
                                            .background(Constants.cardBackground)
                                            .cornerRadius(Constants.cornerRadius)
                                            .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius / 2)
                                            .frame(maxWidth: .infinity)
                                            .onSubmit {
                                                addPlayer(newPlayerName)
                                            }
                                            .foregroundColor(Constants.textPrimary)
                                        
                                        Button(action: {
                                            addPlayer(newPlayerName)
                                        }) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(Constants.primaryColor)
                                                .padding(.horizontal, Constants.smallSpacing)
                                        }
                                        .padding(.trailing, Constants.smallSpacing)
                                        .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                                    }
                                }
                                .background(
                                    Capsule()
                                        .fill(Color.clear)
                                        .padding(.vertical, Constants.smallSpacing / 2)
                                        .padding(.horizontal, Constants.mediumSpacing)
                                )
                            }
                            .background(Constants.secondaryBackground)
                            .cornerRadius(Constants.cornerRadius)
                            .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius)
                        }
                        .padding(.horizontal, Constants.mediumSpacing * 2)
                        
                        VStack(alignment: .leading, spacing: Constants.smallSpacing) {
                            Text("Edit Custom Player/Group Details")
                                .font(Constants.subheadlineFont)
                                .foregroundColor(Constants.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("Player Fun Facts (e.g., Bob just got dumped, Alice is afraid of birds", text: $updatedPlayerDetails, axis: .vertical)
                                .font(Constants.bodyFont)
                                .lineLimit(2...)
                                .textFieldStyle(.plain)
                                .padding(Constants.mediumSpacing)
                                .background(Constants.cardBackground)
                                .cornerRadius(Constants.cornerRadius)
                                .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius / 2)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Constants.textPrimary)
                                .focused($focusedField, equals: .playerDetails)
                                .id("playerDetails")
                                .onAppear {
                                    updatedPlayerDetails = viewModel.settings?.playerDetails ?? ""
                                }
                        }
                        .padding(.horizontal, Constants.mediumSpacing * 2)
                        
                        VStack(alignment: .leading, spacing: Constants.smallSpacing) {
                            Text("Edit Custom Game Prompts")
                                .font(Constants.subheadlineFont)
                                .foregroundColor(Constants.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("Custom prompt for game generation \n(e.g., Lots of trivia!)", text: $updatedCustomInstructions, axis: .vertical)
                                .font(Constants.bodyFont)
                                .lineLimit(2...)
                                .textFieldStyle(.plain)
                                .padding(Constants.mediumSpacing)
                                .background(Constants.cardBackground)
                                .cornerRadius(Constants.cornerRadius)
                                .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius / 2)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Constants.textPrimary)
                                .focused($focusedField, equals: .customInstructions)
                                .id("customInstructions")
                                .onAppear {
                                    updatedCustomInstructions = viewModel.settings?.customInstructions ?? ""
                                }
                        }
                        .padding(.horizontal, Constants.mediumSpacing * 2)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    

                }
                .onChange(of: focusedField) { oldValue, newValue in
                    if let newValue {
                        withAnimation {
                            proxy.scrollTo(newValue == .playerDetails ? "playerDetails" : "customInstructions", anchor: .top)
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            
            HStack(spacing: Constants.mediumSpacing) {
                Button("Cancel") { dismiss() }
                    .foregroundColor(Constants.textSecondary)
                    .font(Constants.bodyFont)
                
                Spacer()
                
                Button("Save") {
                    viewModel.updatePlayerDetails(updatedPlayerDetails)
                    viewModel.updateCustomInstructions(updatedCustomInstructions)
                    dismiss()
                }
                .foregroundColor(Constants.textPrimary)
                .font(Constants.bodyFont)
            }
            .padding(Constants.mediumSpacing)
        }
        .onTapGesture {
            focusedField = nil
        }
        .padding(Constants.mediumSpacing)
        .padding(.bottom, 0)
        .background(Constants.background)
        .cornerRadius(Constants.cornerRadius)
        .shadow(color: Constants.shadowColor, radius: Constants.shadowRadius * 2)
        .ignoresSafeArea(.keyboard)
    }
    
    func addPlayer(_ name: String) {
        viewModel.addPlayer(newPlayerName)
        newPlayerName = ""
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        print("player added")
    }
    
    private func calculateListHeight(playerCount: Int) -> CGFloat {
        let rowHeight: CGFloat = 50
        let minHeight: CGFloat = 100
        let maxHeight: CGFloat = 400
        
        let calculated = CGFloat(playerCount) * rowHeight + (rowHeight * 3)
        
        print("Calculated height: \(calculated)")
        print("Min height: \(minHeight)")
        print("Max height: \(maxHeight)")
        print("Result: \(min(max(calculated, minHeight), maxHeight))")
        return min(max(calculated, minHeight), maxHeight)
    }
}
#Preview {
    let viewModel = GameViewModel(forPreview: true)
    GameView(viewModel: viewModel)
}
