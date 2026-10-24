import SwiftUI

struct CampusInstitute: Identifiable, Hashable {
    let id: String
    let name: String
    let emailDomain: String

    static let all: [CampusInstitute] = [
        .init(id: "kiet", name: "KIET Group of Institutions", emailDomain: "kiet.edu"),
        .init(id: "akgec", name: "Ajay Kumar Garg Engineering College", emailDomain: "akgec.ac.in"),
        .init(id: "iitd", name: "IIT Delhi", emailDomain: "iitd.ac.in"),
        .init(id: "dtu", name: "Delhi Technological University", emailDomain: "dtu.ac.in"),
        .init(id: "du", name: "University of Delhi", emailDomain: "du.ac.in")
    ]
}

struct AuthenticationView: View {
    let onContinue: (String, CampusInstitute) -> Void
    @State private var email = ""
    @State private var selectedInstitute = CampusInstitute.all[0]
    @State private var enteredOTP = ""
    @State private var generatedOTP = ""
    @State private var otpStep = false
    @State private var message = ""
    @State private var showDemoOTP = false

    private var normalizedEmail: String { email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
    private var emailIsValid: Bool {
        let parts = normalizedEmail.split(separator: "@", omittingEmptySubsequences: false)
        return parts.count == 2 && !parts[0].isEmpty && String(parts[1]) == selectedInstitute.emailDomain
    }

    var body: some View {
        ZStack {
            AppColors.cream.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack { Spacer(); Image(systemName: "shippingbox.fill").font(.system(size: 30, weight: .medium)).foregroundStyle(AppColors.raspberry).frame(width: 74, height: 74).background(AppColors.pinkLight, in: RoundedRectangle(cornerRadius: 25)); Spacer() }.padding(.top, 30)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PASS THE PARCEL").font(.system(size: 11, weight: .bold)).tracking(2.5).foregroundStyle(AppColors.raspberry)
                        Text("Good things\nfind new homes.").font(.system(size: 43, weight: .bold, design: .serif)).foregroundStyle(AppColors.text)
                        Text("Your campus marketplace for the things you need — and the things someone else is ready to pass on.").font(.system(size: 16)).foregroundStyle(AppColors.muted).lineSpacing(5)
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        Text("YOUR INSTITUTE").font(.system(size: 10, weight: .bold)).tracking(1.4).foregroundStyle(AppColors.muted)
                        Picker("Select your institute", selection: $selectedInstitute) {
                            ForEach(CampusInstitute.all) { institute in Text(institute.name).tag(institute) }
                        }.pickerStyle(.menu).tint(AppColors.raspberry).frame(maxWidth: .infinity, alignment: .leading).padding(13).background(.white, in: RoundedRectangle(cornerRadius: 15))
                        Text("Use your \(selectedInstitute.emailDomain) student email").font(.system(size: 12)).foregroundStyle(AppColors.muted)
                        Text("STUDENT EMAIL").font(.system(size: 10, weight: .bold)).tracking(1.4).foregroundStyle(AppColors.muted)
                        TextField("you@\(selectedInstitute.emailDomain)", text: $email).font(.system(size: 16)).foregroundStyle(.black).keyboardType(.emailAddress).textInputAutocapitalization(.never).autocorrectionDisabled().padding(16).background(.white, in: RoundedRectangle(cornerRadius: 15)).overlay(RoundedRectangle(cornerRadius: 15).stroke(AppColors.border, lineWidth: 1))
                        if otpStep {
                            Text("ENTER THE 6-DIGIT OTP").font(.system(size: 10, weight: .bold)).tracking(1.4).foregroundStyle(AppColors.muted)
                            TextField("6-digit code", text: $enteredOTP).keyboardType(.numberPad).textContentType(.oneTimeCode).padding(16).background(.white, in: RoundedRectangle(cornerRadius: 15)).overlay(RoundedRectangle(cornerRadius: 15).stroke(AppColors.border, lineWidth: 1))
                            Button { verifyOTP() } label: { HStack { Text("Verify and enter"); Spacer(); Image(systemName: "arrow.right") } }.buttonStyle(PrimaryButtonStyle())
                            Button("Use a different email") { otpStep = false; enteredOTP = ""; message = "" }.font(.system(size: 13, weight: .medium)).foregroundStyle(AppColors.raspberry)
                        } else {
                            Button { requestOTP() } label: { HStack { Text("Send verification OTP"); Spacer(); Image(systemName: "envelope.badge") } }.buttonStyle(PrimaryButtonStyle())
                        }
                        if !message.isEmpty { Text(message).font(.system(size: 12, weight: .medium)).foregroundStyle(AppColors.raspberry) }
                    }
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "shield.lefthalf.filled").foregroundStyle(AppColors.green)
                        Text("Prototype note: this build simulates OTP verification on this device. Real email delivery and secure verification require a backend/authentication service before launch.").font(.system(size: 11)).foregroundStyle(AppColors.muted).lineSpacing(3)
                    }
                    Spacer(minLength: 15)
                }.padding(25).frame(maxWidth: 520).frame(maxWidth: .infinity)
            }
        }
        .alert("Demo verification code", isPresented: $showDemoOTP) { Button("OK", role: .cancel) {} } message: { Text("For prototype testing only, your simulated OTP is \(generatedOTP). No email has actually been sent.") }
    }

    private func requestOTP() {
        guard emailIsValid else { message = "Choose your institute and enter an email ending in @\(selectedInstitute.emailDomain)."; return }
        generatedOTP = String(format: "%06d", Int.random(in: 0...999999))
        enteredOTP = ""
        otpStep = true
        message = "A demo OTP has been generated for this prototype."
        showDemoOTP = true
    }

    private func verifyOTP() {
        guard enteredOTP == generatedOTP else { message = "That OTP is incorrect. Please try again."; return }
        onContinue(normalizedEmail, selectedInstitute)
    }
}
