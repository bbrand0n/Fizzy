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
                .blur(radius: 4)
                .opacity(0.2)
            
            if let session = viewModel.session {
                VStack(spacing: 24) {
                    if viewModel.isLoadingPrompt {
                        ProgressView("Generating Prompt...")
                            .progressViewStyle(.circular)
                            .tint(Constants.primaryColor)
                            .scaleEffect(1.5)
                    } else {
                        CardView(prompt: viewModel.prompt)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            .animation(.easeInOut(duration: 0.5), value: viewModel.prompt)
                            .onTapGesture {
                                Task { await viewModel.generateNewPrompt() }
                            }
                            .padding(.horizontal, 70)
                    }
                }
                .padding()
                
                // Error alert
                .alert("Error", isPresented: Binding(get: { viewModel.error != nil }, set: { _ in viewModel.error = nil })) {
                    Button("OK") {}
                } message: {
                    Text(viewModel.error?.localizedDescription ?? "Unknown error")
                }
                
                // Popup menu sheet
                .sheet(isPresented: $showEditMenu) {
                    EditPlayersMenu(viewModel: viewModel)
                        .presentationDetents([.height(0.80 * UIScreen.main.bounds.height)])
                        .presentationDragIndicator(.visible)
                }
            } else {
                ProgressView("Loading Game...")
                    .tint(Constants.primaryColor)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button(action: {
                showEditMenu = true
            }) {
                HStack {
                    Text("Game Settings")
                        .font(.system(.body, design: .rounded))
                    
                    Image(systemName: "gearshape")
                }
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 80)
        }
    }
}

struct EditPlayersMenu: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var newPlayerName: String = ""
    @State private var updatedPlayerDetails: String = ""
    @State private var updatedCustomInstructions: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Players & Details")
                .font(.headline)
            
            // Player list with remove
            if let session = viewModel.session {
                VStack {
                    List {
                        // Players list
                        Section {
                            ForEach(session.players.indices, id: \.self) { index in
                                HStack {
                                    Text(session.players[index])
                                        .font(.system(.body, design: .rounded))
                                        .padding(.horizontal, 25)
                                    Spacer()
                                    Button(action: {
                                        viewModel.removePlayer(at: index)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .padding(.horizontal, 25)
                                    .padding(.vertical, 8)
                                }
                                .listRowSeparator(.hidden)
                            }
                            .onDelete { indices in
                                indices.forEach { viewModel.removePlayer(at: $0) }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                            .listRowBackground(
                                Capsule()
                                    .fill(Constants.primaryColor.opacity(0.4))
                                    .padding(.vertical, 2).padding(.horizontal, 20)
                            )
                        } header: {
                            Text("  Players")
                                .font(.caption)
                                .foregroundStyle(Constants.textSecondary)
                        }
                        
                        // Add new player
                        Section {
                            HStack {
                                ZStack(alignment: .trailing) {
                                    TextField("Add Player", text: $newPlayerName)
                                        .font(.system(.body, design: .rounded))
                                        .textFieldStyle(.plain)
                                        .padding(.leading)
                                        .padding(.vertical, 8)
                                        .cornerRadius(Constants.cornerRadius)
                                        .shadow(color: Constants.shadowColor.opacity(0.7), radius: 2)
                                        .frame(maxWidth: .infinity)
                                        .onSubmit {
                                            addPlayer(newPlayerName)
                                        }
                                    
                                    Button(action: {
                                        addPlayer(newPlayerName)
                                    }) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Constants.primaryColor)
                                            .padding(.horizontal, 8)
                                    }
                                    .padding(.trailing)
                                    .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                                }
                            }
                            .listRowBackground(
                                Capsule()
                                    .fill(Color.white.opacity(0.9))
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 20)
                            )
                        }
                    }
                    .listSectionSpacing(.compact)
                    .listRowSpacing(5)
                    .scrollContentBackground(.hidden)
                    .listRowInsets(.init(top: 0, leading: 40, bottom: 0, trailing: 40))
                    .frame(maxHeight: calculateListHeight(playerCount: session.players.count))
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(" EDIT CUSTOM PLAYER/GROUP DETAILS")
                        .font(.caption)
                        .foregroundStyle(Constants.textSecondary)
                    
                    // Edit player details
                    TextField("Player Fun Facts (e.g., Bob just got dumped, Alice is afraid of birds", text: $updatedPlayerDetails, axis: .vertical)
                        .font(.system(.body, design: .rounded))
                        .lineLimit(2...)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(Constants.cornerRadius)
                        .shadow(color: Constants.shadowColor.opacity(0.4), radius: 2)
                        .frame(maxWidth: .infinity)
                    
                        .onAppear {
                            updatedPlayerDetails = viewModel.settings?.playerDetails ?? ""
                        }
                }
                .padding(.horizontal, 40)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(" EDIT CUSTOM GAME PROMPTS")
                        .font(.caption)
                        .foregroundStyle(Constants.textSecondary)
                    
                    // Edit player details
                    TextField("Custom prompt for game generation \n(e.g., Lots of trivia!)", text: $updatedCustomInstructions, axis: .vertical)
                        .font(.system(.body, design: .rounded))
                        .lineLimit(2...)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(Constants.cornerRadius)
                        .shadow(color: Constants.shadowColor.opacity(0.4), radius: 2)
                        .frame(maxWidth: .infinity)
                    
                        .onAppear {
                            updatedCustomInstructions = viewModel.settings?.customInstructions ?? ""
                        }
                }
                .padding(.top, 10)
                .padding(.horizontal, 40)
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Button("Cancel") { dismiss() }
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button("Save") {
                    viewModel.updatePlayerDetails(updatedPlayerDetails)
                    viewModel.updateCustomInstructions(updatedCustomInstructions)
                    dismiss()
                }
            }
            .padding()
        }
        .padding()
        .cornerRadius(16)
        .shadow(radius: 10)
        .ignoresSafeArea()
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
