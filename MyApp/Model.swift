import SwiftUI
import UIKit
import Combine

// MARK: - App theme

enum AppColors {
    static let pink = Color(red: 0.91, green: 0.53, blue: 0.64)       // strawberry
    static let pinkLight = Color(red: 0.99, green: 0.88, blue: 0.91)
    static let raspberry = Color(red: 0.62, green: 0.23, blue: 0.37)
    static let green = Color(red: 0.48, green: 0.59, blue: 0.40)      // pistachio/sage
    static let greenLight = Color(red: 0.88, green: 0.92, blue: 0.82)
    static let cream = Color(red: 1.00, green: 0.96, blue: 0.90)
    static let white = Color.white
    static let text = Color(red: 0.25, green: 0.20, blue: 0.23)
    static let muted = Color(red: 0.51, green: 0.45, blue: 0.47)
    static let border = Color(red: 0.92, green: 0.85, blue: 0.85)
    static let yellow = Color(red: 0.98, green: 0.87, blue: 0.59)
}

enum AppTab: Hashable {
    case explore, saved, list, messages, profile
}

struct Listing: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var title: String
    var category: String
    var price: String
    var condition: String
    var owner: String
    var symbol: String
    var description: String
    var method: String = "For sale"
    var imageData: Data? = nil
    var institute: String? = nil

    static let samples: [Listing] = [
        Listing(title: "Engineering Mathematics", category: "Books", price: "₹250", condition: "Like new", owner: "Aarav S.", symbol: "book.closed.fill", description: "A well-kept textbook that's great for first-year engineering."),
        Listing(title: "Scientific Calculator", category: "Electronics", price: "₹450", condition: "Good", owner: "Riya M.", symbol: "function", description: "Works well and is ready for its next semester."),
        Listing(title: "Hostel Desk Lamp", category: "Hostel", price: "Free", condition: "Good", owner: "Ananya K.", symbol: "lamp.desk.fill", description: "A handy desk lamp for late-night study sessions.", method: "Free"),
        Listing(title: "Badminton Racket", category: "Sports", price: "₹350", condition: "Good", owner: "Kabir R.", symbol: "figure.badminton", description: "Perfect for a casual game after class."),
        Listing(title: "Lab Coat", category: "Lab Equipment", price: "₹180", condition: "Like new", owner: "Meera P.", symbol: "tshirt.fill", description: "Clean lab coat in great condition."),
        Listing(title: "Programming Book", category: "Books", price: "Swap", condition: "Good", owner: "Dev S.", symbol: "books.vertical.fill", description: "Happy to swap this for another useful study resource.", method: "Swap")
    ]
}

struct ParcelOrder: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var listingID: UUID
    var title: String
    var category: String
    var price: String
    var seller: String
    var date: Date = Date()
    var status: String = "Pending"
    var imageData: Data? = nil
}

struct CampusMessage: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var listingID: UUID
    var listingTitle: String
    var otherPerson: String
    var sender: String
    var body: String
    var date: Date
}

final class AppStore: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var savedIDs: Set<UUID> = []
    @Published var orders: [ParcelOrder] = []
    @Published var studentEmail: String = ""
    @Published var instituteName: String = "KIET Group of Institutions"
    @Published var messages: [CampusMessage] = []

    private let listingsKey = "ptp.listings.v2"
    private let savedKey = "ptp.saved.v2"
    private let ordersKey = "ptp.orders.v2"
    private let emailKey = "ptp.studentEmail.v2"
    private let instituteKey = "ptp.instituteName.v1"
    private let messagesKey = "ptp.messages.v1"

    init() {
        let defaults = UserDefaults.standard
        studentEmail = defaults.string(forKey: emailKey) ?? ""
        instituteName = defaults.string(forKey: instituteKey) ?? "KIET Group of Institutions"
        if let data = defaults.data(forKey: messagesKey), let decoded = try? JSONDecoder().decode([CampusMessage].self, from: data) { messages = decoded }
        if let data = defaults.data(forKey: listingsKey),
           let decoded = try? JSONDecoder().decode([Listing].self, from: data) {
            listings = decoded
        } else {
            listings = Listing.samples
            persistListings()
        }
        if let strings = defaults.array(forKey: savedKey) as? [String] {
            savedIDs = Set(strings.compactMap(UUID.init(uuidString:)))
        }
        if let data = defaults.data(forKey: ordersKey),
           let decoded = try? JSONDecoder().decode([ParcelOrder].self, from: data) {
            orders = decoded
        }
    }

    func signOut() {
        studentEmail = ""
        instituteName = "KIET Group of Institutions"
        UserDefaults.standard.removeObject(forKey: emailKey)
        UserDefaults.standard.removeObject(forKey: instituteKey)
    }

    @discardableResult
    func signIn(email: String, institute: CampusInstitute) -> Bool {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let parts = normalized.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2, !parts[0].isEmpty, String(parts[1]) == institute.emailDomain else { return false }
        studentEmail = normalized
        instituteName = institute.name
        UserDefaults.standard.set(studentEmail, forKey: emailKey)
        UserDefaults.standard.set(instituteName, forKey: instituteKey)
        return true
    }

    func sendMessage(_ body: String, for listing: Listing) {
        let clean = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        let message = CampusMessage(listingID: listing.id, listingTitle: listing.title, otherPerson: listing.owner, sender: studentEmail, body: clean, date: Date())
        messages.append(message)
        persistMessages()
    }

    func reply(_ body: String, listingID: UUID, listingTitle: String, otherPerson: String) {
        let clean = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        messages.append(CampusMessage(listingID: listingID, listingTitle: listingTitle, otherPerson: otherPerson, sender: studentEmail, body: clean, date: Date()))
        persistMessages()
    }

    private func persistMessages() {
        if let data = try? JSONEncoder().encode(messages) { UserDefaults.standard.set(data, forKey: messagesKey) }
    }

    func toggleSaved(_ listing: Listing) {
        if savedIDs.contains(listing.id) { savedIDs.remove(listing.id) }
        else { savedIDs.insert(listing.id) }
        UserDefaults.standard.set(savedIDs.map(\.uuidString), forKey: savedKey)
    }

    func addListing(_ listing: Listing) {
        listings.insert(listing, at: 0)
        persistListings()
    }

    func placeOrder(for listing: Listing) {
        guard !orders.contains(where: { $0.listingID == listing.id && $0.status != "Cancelled" }) else { return }
        orders.insert(ParcelOrder(listingID: listing.id, title: listing.title, category: listing.category, price: listing.price, seller: listing.owner, imageData: listing.imageData), at: 0)
        if let data = try? JSONEncoder().encode(orders) { UserDefaults.standard.set(data, forKey: ordersKey) }
    }

    func cancelOrder(_ order: ParcelOrder) {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }
        orders[index].status = "Cancelled"
        if let data = try? JSONEncoder().encode(orders) { UserDefaults.standard.set(data, forKey: ordersKey) }
    }

    private func persistListings() {
        if let data = try? JSONEncoder().encode(listings) { UserDefaults.standard.set(data, forKey: listingsKey) }
    }
}

// MARK: - Shared UI components

struct ProductArtwork: View {
    let listing: Listing
    var height: CGFloat = 145

    private var tileColor: Color {
        switch listing.category {
        case "Books": return AppColors.pinkLight
        case "Electronics": return Color(red: 0.88, green: 0.91, blue: 0.98)
        case "Hostel": return AppColors.yellow.opacity(0.55)
        case "Sports": return AppColors.greenLight
        case "Lab Equipment": return Color(red: 0.91, green: 0.88, blue: 0.96)
        default: return AppColors.cream
        }
    }

    var body: some View {
        ZStack {
            tileColor
            if let data = listing.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .clipped()
            } else {
                Circle().fill(.white.opacity(0.45)).frame(width: height * 0.72, height: height * 0.72)
                    .offset(x: height * 0.28, y: -height * 0.25)
                Image(systemName: listing.symbol)
                    .font(.system(size: height * 0.34, weight: .regular))
                    .foregroundStyle(AppColors.raspberry.opacity(0.88))
                    .shadow(color: .white.opacity(0.6), radius: 1, y: 1)
            }
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipped()
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(AppColors.pink, in: RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

extension View {
    func parcelCard() -> some View {
        self.background(.white, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColors.border.opacity(0.7), lineWidth: 1))
    }
}
