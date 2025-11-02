//
//  ContactView.swift
//  Pockets
//
//  Created by Wen Cheng on 2/11/2025.
//

import SwiftUI
import MessageUI

struct ContactView: View {
    @State private var subject: String = ""
    @State private var message: String = ""
    @State private var showingMailComposer = false
    @State private var showingMailAlert = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case subject, message
    }
    
    private var isFormValid: Bool {
        !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Subject", text: $subject)
                            .foregroundColor(AppTheme.primaryText)
                            .focused($focusedField, equals: .subject)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .message
                            }
                    } header: {
                        Text("Subject")
                            .foregroundColor(AppTheme.secondaryText)
                    } footer: {
                        Text("What would you like to tell us?")
                            .foregroundColor(AppTheme.tertiaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    
                    Section {
                        TextField("Your message", text: $message, axis: .vertical)
                            .foregroundColor(AppTheme.primaryText)
                            .focused($focusedField, equals: .message)
                            .lineLimit(8...15)
                            .textInputAutocapitalization(.sentences)
                    } header: {
                        Text("Message")
                            .foregroundColor(AppTheme.secondaryText)
                    } footer: {
                        Text("We'd love to hear your feedback, feature requests, or any questions you have!")
                            .foregroundColor(AppTheme.tertiaryText)
                    }
                    .listRowBackground(AppTheme.cardBackground)
                    
                    Section {
                        Button {
                            Haptics.light()
                            if MFMailComposeViewController.canSendMail() {
                                showingMailComposer = true
                            } else {
                                showingMailAlert = true
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Send Email")
                                    .font(.system(size: 17, weight: .semibold))
                                Spacer()
                            }
                            .foregroundColor(isFormValid ? AppTheme.primaryText : AppTheme.tertiaryText)
                            .padding(.vertical, 12)
                            .background(isFormValid ? AppTheme.accent : AppTheme.tertiaryText.opacity(0.2))
                            .cornerRadius(12)
                        }
                        .disabled(!isFormValid)
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Contact")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingMailComposer) {
                MailComposeView(
                    subject: subject.trimmingCharacters(in: .whitespacesAndNewlines),
                    message: message.trimmingCharacters(in: .whitespacesAndNewlines),
                    isPresented: $showingMailComposer
                )
            }
            .alert("Email Not Available", isPresented: $showingMailAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please set up an email account in the Mail app to send emails.")
            }
        }
    }
}

struct MailComposeView: UIViewControllerRepresentable {
    let subject: String
    let message: String
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(["evankology@gmail.com"]) // Replace with actual email
        composer.setSubject(subject)
        composer.setMessageBody(message, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isPresented: Bool
        
        init(isPresented: Binding<Bool>) {
            _isPresented = isPresented
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if result == .sent {
                Haptics.success()
            }
            isPresented = false
        }
    }
}

#Preview {
    ContactView()
        .preferredColorScheme(.dark)
}

