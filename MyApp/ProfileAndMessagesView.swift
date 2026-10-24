import SwiftUI
import UIKit

// MARK: - Profile
struct ProfileView: View {
    @EnvironmentObject private var store: AppStore
    private var myListings: [Listing] { store.listings.filter { $0.owner == "You" } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    profileHeader
                    HStack(spacing: 12) {
                        statCard(value: "\(myListings.count)", label: "My listings", tint: AppColors.pinkLight)
                        statCard(value: "\(store.savedIDs.count)", label: "Saved", tint: AppColors.greenLight)
                        statCard(value: "\(store.orders.count)", label: "Orders", tint: AppColors.yellow.opacity(0.65))
                    }
                    VStack(spacing: 0) {
                        profileLink(title: "My listings", subtitle: "Items you've put up for the community", symbol: "tag.fill", tint: AppColors.pinkLight) { MyListingsView() }
                        rowDivider
                        profileLink(title: "Saved items", subtitle: "Things you want to come back to", symbol: "heart.fill", tint: AppColors.greenLight) { SavedView() }
                        rowDivider
                        profileLink(title: "Order history", subtitle: "Check the orders you've recorded", symbol: "bag.fill", tint: AppColors.yellow.opacity(0.65)) { OrderHistoryView() }
                    }.padding(.horizontal, 14).parcelCard()

                    VStack(spacing: 0) {
                        profileLink(title: "Help & support", subtitle: "A few answers and ways to get help", symbol: "questionmark.circle.fill", tint: AppColors.greenLight) { HelpView() }
                        rowDivider
                        profileLink(title: "About Pass the Parcel", subtitle: "What this little campus marketplace is about", symbol: "shippingbox.fill", tint: AppColors.pinkLight) { AboutView() }
                    }.padding(.horizontal, 14).parcelCard()

                    Button {
                        store.signOut()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Log Out")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.raspberry)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(AppColors.pinkLight, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 14)

                    Text("A student marketplace prototype · Orders and listings are stored locally on this device.")
                        .font(.system(size: 11)).foregroundStyle(AppColors.muted).multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 16)
                }.padding(18)
            }
            .background(AppColors.cream.ignoresSafeArea())
            .navigationTitle("Your profile")
            .toolbarBackground(AppColors.cream, for: .navigationBar)
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle().fill(AppColors.pinkLight).frame(width: 86, height: 86)
                    .overlay(Image(systemName: "person.fill").font(.system(size: 36)).foregroundStyle(AppColors.raspberry))
                Circle().fill(AppColors.green).frame(width: 22, height: 22).overlay(Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(.white)).offset(x: 1, y: 1)
            }
            Text("Hello, campus friend!").font(.system(size: 23, weight: .bold, design: .serif)).foregroundStyle(AppColors.text)
            Text(store.studentEmail).font(.system(size: 13, weight: .medium)).foregroundStyle(AppColors.muted)
            Text(store.instituteName).font(.system(size: 11, weight: .semibold)).foregroundStyle(AppColors.raspberry)
                .padding(.horizontal, 13).padding(.vertical, 7).background(AppColors.pinkLight, in: Capsule())
        }
        .frame(maxWidth: .infinity).padding(.vertical, 22).parcelCard()
    }

    private func statCard(value: String, label: String, tint: Color) -> some View {
        VStack(spacing: 6) {
            Text(value).font(.system(size: 24, weight: .bold, design: .serif)).foregroundStyle(AppColors.raspberry)
            Text(label).font(.system(size: 11, weight: .medium)).foregroundStyle(AppColors.muted).lineLimit(1)
        }.frame(maxWidth: .infinity).padding(.vertical, 18).background(tint, in: RoundedRectangle(cornerRadius: 17))
    }

    private var rowDivider: some View { Divider().overlay(AppColors.border).padding(.leading, 60) }

    private func profileLink<Destination: View>(title: String, subtitle: String, symbol: String, tint: Color, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink { destination() } label: {
            HStack(spacing: 12) {
                Image(systemName: symbol).font(.system(size: 17, weight: .semibold)).foregroundStyle(AppColors.raspberry)
                    .frame(width: 42, height: 42).background(tint, in: RoundedRectangle(cornerRadius: 13))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.system(size: 14, weight: .semibold)).foregroundStyle(AppColors.text)
                    Text(subtitle).font(.system(size: 11)).foregroundStyle(AppColors.muted).multilineTextAlignment(.leading)
                }
                Spacer(minLength: 5)
                Image(systemName: "chevron.right").font(.system(size: 11, weight: .bold)).foregroundStyle(AppColors.muted)
            }.padding(.vertical, 14)
        }.buttonStyle(.plain)
    }
}

struct MyListingsView: View {
    @EnvironmentObject private var store: AppStore
    private var listings: [Listing] { store.listings.filter { $0.owner == "You" } }
    var body: some View {
        Group {
            if listings.isEmpty {
                EmptyStateView(symbol: "tag", title: "No listings yet", subtitle: "When you list an item, you'll find it here.")
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(listings) { listing in
                            NavigationLink(value: listing) {
                                HStack(spacing: 13) {
                                    ProductArtwork(listing: listing, height: 82).frame(width: 88).clipShape(RoundedRectangle(cornerRadius: 13))
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(listing.title).font(.system(size: 14, weight: .semibold)).foregroundStyle(AppColors.text)
                                        Text(listing.category).font(.system(size: 12)).foregroundStyle(AppColors.muted)
                                        Text(listing.price).font(.system(size: 14, weight: .bold)).foregroundStyle(AppColors.raspberry)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.system(size: 11)).foregroundStyle(AppColors.muted)
                                }.padding(12).parcelCard()
                            }.buttonStyle(.plain)
                        }
                    }.padding(18)
                }
            }
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle("My listings")
        .navigationDestination(for: Listing.self) { ListingDetailView(listing: $0) }
    }
}

struct OrderHistoryView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        Group {
            if store.orders.isEmpty {
                EmptyStateView(symbol: "bag", title: "No orders yet", subtitle: "When you record an order from an item page, it will appear here.")
            } else {
                ScrollView {
                    LazyVStack(spacing: 13) {
                        ForEach(store.orders) { order in orderCard(order) }
                    }.padding(18)
                }
            }
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle("Order history")
    }

    private func orderCard(_ order: ParcelOrder) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(AppColors.pinkLight)
                if let data = order.imageData, let image = UIImage(data: data) {
                    Image(uiImage: image).resizable().scaledToFill().frame(width: 82, height: 88).clipped()
                } else {
                    Image(systemName: "bag.fill").font(.system(size: 25)).foregroundStyle(AppColors.raspberry)
                }
            }.frame(width: 82, height: 88).clipShape(RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 6) {
                Text(order.title).font(.system(size: 14, weight: .semibold)).foregroundStyle(AppColors.text)
                Text("From \(order.seller)").font(.system(size: 11)).foregroundStyle(AppColors.muted)
                Text(order.price).font(.system(size: 14, weight: .bold)).foregroundStyle(AppColors.raspberry)
                Text(order.date.formatted(date: .abbreviated, time: .omitted)).font(.system(size: 10)).foregroundStyle(AppColors.muted)
                Text(order.status.uppercased()).font(.system(size: 9, weight: .bold)).tracking(0.8)
                    .foregroundStyle(order.status == "Cancelled" ? AppColors.raspberry : AppColors.green)
                    .padding(.horizontal, 9).padding(.vertical, 5).background(order.status == "Cancelled" ? AppColors.pinkLight : AppColors.greenLight, in: Capsule())
            }
            Spacer(minLength: 0)
            if order.status == "Pending" {
                Button("Cancel") { store.cancelOrder(order) }.font(.system(size: 11, weight: .semibold)).foregroundStyle(AppColors.raspberry)
            }
        }.padding(12).parcelCard()
    }
}

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Need a hand?").font(.system(size: 28, weight: .bold, design: .serif)).foregroundStyle(AppColors.text)
                Text("A few quick notes for using Pass the Parcel.").font(.system(size: 14)).foregroundStyle(AppColors.muted)
                helpCard("How do I save an item?", "Tap the heart on a listing. Your saved items are available from the Saved tab and your profile.")
                helpCard("How do I list something?", "Open List an Item, add the details, and optionally choose a photo from your library.")
                helpCard("Are orders real purchases?", "Not yet. This prototype records orders locally for demonstration. It doesn't process payments or contact sellers.")
                helpCard("How is my email verified?", "Choose your institute and use its matching email domain. OTP is simulated in this prototype; real email delivery needs an authentication backend.")
            }.padding(20)
        }.background(AppColors.cream.ignoresSafeArea()).navigationTitle("Help & support")
    }
    private func helpCard(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.text)
            Text(detail).font(.system(size: 13)).foregroundStyle(AppColors.muted).lineSpacing(3)
        }.padding(16).frame(maxWidth: .infinity, alignment: .leading).parcelCard()
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Image(systemName: "shippingbox.fill").font(.system(size: 35)).foregroundStyle(AppColors.raspberry)
                    .frame(width: 78, height: 78).background(AppColors.pinkLight, in: RoundedRectangle(cornerRadius: 24))
                Text("Pass the Parcel").font(.system(size: 30, weight: .bold, design: .serif)).foregroundStyle(AppColors.text)
                Text("Good things deserve a second life.").font(.system(size: 18, weight: .semibold)).foregroundStyle(AppColors.raspberry)
                Text("Pass the Parcel is a campus marketplace concept where students can find, sell, swap, or pass on useful things — from textbooks and calculators to hostel essentials.")
                    .font(.system(size: 15)).foregroundStyle(AppColors.muted).lineSpacing(5)
                Text("Built as a student project prototype. Listings, saved items, and demo orders are stored on this device; there is no connected marketplace backend yet.")
                    .font(.system(size: 12)).foregroundStyle(AppColors.muted).lineSpacing(4).padding(16).background(AppColors.greenLight.opacity(0.7), in: RoundedRectangle(cornerRadius: 16))
            }.padding(22)
        }.background(AppColors.cream.ignoresSafeArea()).navigationTitle("About")
    }
}

// MARK: - In-app messaging (local prototype)
struct MessagesInboxView: View {
    @EnvironmentObject private var store: AppStore

    private var conversations: [CampusMessage] {
        var latestByListing: [UUID: CampusMessage] = [:]
        for message in store.messages.sorted(by: { $0.date < $1.date }) { latestByListing[message.listingID] = message }
        return latestByListing.values.sorted(by: { $0.date > $1.date })
    }

    var body: some View {
        NavigationStack {
            Group {
                if conversations.isEmpty {
                    EmptyStateView(symbol: "bubble.left.and.bubble.right", title: "Your messages live here", subtitle: "Open any listing and tap Message the seller to start a conversation.")
                } else {
                    List(conversations) { conversation in
                        NavigationLink {
                            ChatThreadView(listingID: conversation.listingID, listingTitle: conversation.listingTitle, otherPerson: conversation.otherPerson)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "person.crop.circle.fill").font(.system(size: 38)).foregroundStyle(AppColors.green)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(conversation.otherPerson).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.text)
                                    Text(conversation.listingTitle).font(.system(size: 12, weight: .medium)).foregroundStyle(AppColors.raspberry)
                                    Text(conversation.body).font(.system(size: 12)).foregroundStyle(AppColors.muted).lineLimit(1)
                                }
                                Spacer()
                                Text(conversation.date.formatted(date: .omitted, time: .shortened)).font(.system(size: 10)).foregroundStyle(AppColors.muted)
                            }.padding(.vertical, 5)
                        }
                        .listRowBackground(AppColors.cream)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(AppColors.cream.ignoresSafeArea())
            .navigationTitle("Messages")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Text("LOCAL DEMO").font(.system(size: 9, weight: .bold)).tracking(1).foregroundStyle(AppColors.muted) } }
        }
    }
}

struct MessageComposeView: View {
    let listing: Listing
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var message = "Hi! Is this item still available?"
    @State private var didSend = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Say hello").font(.system(size: 28, weight: .bold, design: .serif)).foregroundStyle(AppColors.text)
                Text("About: \(listing.title)").font(.system(size: 14, weight: .medium)).foregroundStyle(AppColors.muted)
                Text("To: \(listing.owner)").font(.system(size: 12)).foregroundStyle(AppColors.muted)
                TextEditor(text: $message).frame(minHeight: 150).padding(8).scrollContentBackground(.hidden)
                    .background(.white, in: RoundedRectangle(cornerRadius: 15)).overlay(RoundedRectangle(cornerRadius: 15).stroke(AppColors.border, lineWidth: 1))
                if didSend {
                    Label("Message saved to your Messages tab", systemImage: "checkmark.circle.fill").font(.system(size: 13, weight: .medium)).foregroundStyle(AppColors.green)
                }
                Button {
                    store.sendMessage(message, for: listing)
                    didSend = true
                } label: { Label("Send message", systemImage: "paperplane.fill") }.buttonStyle(PrimaryButtonStyle())
                    .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Text("Prototype limitation: messages are saved on this device only. They will not reach another student's phone until a shared backend is connected.")
                    .font(.system(size: 11)).foregroundStyle(AppColors.muted).lineSpacing(3)
                Spacer()
            }.padding(20).background(AppColors.cream.ignoresSafeArea())
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Close") { dismiss() }.foregroundStyle(AppColors.raspberry) } }
        }.presentationDetents([.medium, .large])
    }
}

struct ChatThreadView: View {
    @EnvironmentObject private var store: AppStore
    let listingID: UUID
    let listingTitle: String
    let otherPerson: String
    @State private var draft = ""

    private var threadMessages: [CampusMessage] { store.messages.filter { $0.listingID == listingID }.sorted(by: { $0.date < $1.date }) }

    var body: some View {
        VStack(spacing: 0) {
            Text("Conversation about \(listingTitle)").font(.system(size: 12, weight: .medium)).foregroundStyle(AppColors.muted).padding(12)
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(threadMessages) { message in
                        HStack {
                            if message.sender == store.studentEmail { Spacer(minLength: 45) }
                            VStack(alignment: .leading, spacing: 5) {
                                Text(message.body).font(.system(size: 14)).foregroundStyle(AppColors.text)
                                Text(message.date.formatted(date: .omitted, time: .shortened)).font(.system(size: 9)).foregroundStyle(AppColors.muted)
                            }.padding(12).background(message.sender == store.studentEmail ? AppColors.pinkLight : .white, in: RoundedRectangle(cornerRadius: 15))
                            if message.sender != store.studentEmail { Spacer(minLength: 45) }
                        }
                    }
                }.padding(14)
            }
            HStack(spacing: 10) {
                TextField("Write a message…", text: $draft, axis: .vertical).lineLimit(1...4).padding(12).background(.white, in: RoundedRectangle(cornerRadius: 18))
                Button {
                    store.reply(draft, listingID: listingID, listingTitle: listingTitle, otherPerson: otherPerson)
                    draft = ""
                } label: { Image(systemName: "paperplane.fill").foregroundStyle(.white).frame(width: 44, height: 44).background(AppColors.raspberry, in: Circle()) }
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }.padding(12).background(AppColors.cream)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle(otherPerson).navigationBarTitleDisplayMode(.inline)
    }
}
