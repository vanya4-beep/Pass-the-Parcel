import SwiftUI
import UIKit
import PhotosUI

// MARK: - Explore
struct ExploreView: View {
    @EnvironmentObject private var store: AppStore
    @State private var searchText = ""
    @State private var selectedCategory = "All"

    private let categories = ["All", "Books", "Electronics", "Hostel", "Sports", "Lab Equipment", "Other", "Notes"]
    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    private var filteredListings: [Listing] {
        store.listings.filter { listing in
            (listing.institute == nil || listing.institute == store.instituteName) &&
            (selectedCategory == "All" || listing.category == selectedCategory) &&
            (searchText.isEmpty || listing.title.localizedCaseInsensitiveContains(searchText) || listing.category.localizedCaseInsensitiveContains(searchText) || listing.description.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    searchBar
                    welcomeCard
                    categoryPicker
                    if selectedCategory == "Notes" { FreeNotesView() } else { listingsSection }
                }
                .padding(20).padding(.bottom, 20)
            }
            .background(AppColors.cream.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Listing.self) { ListingDetailView(listing: $0) }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 7) {
                Text(store.instituteName.uppercased()).font(.system(size: 9, weight: .bold)).tracking(1.2).foregroundStyle(AppColors.raspberry).lineLimit(1)
                Text("Find it. Love it.\nPass it on.").font(.system(size: 31, weight: .bold, design: .serif)).foregroundStyle(AppColors.text)
            }
            Spacer()
            Image(systemName: "shippingbox.fill").font(.system(size: 25)).foregroundStyle(AppColors.raspberry)
                .frame(width: 62, height: 62).background(AppColors.pinkLight, in: RoundedRectangle(cornerRadius: 21))
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(AppColors.raspberry)
            TextField("What are you looking for?", text: $searchText).font(.system(size: 14)).autocorrectionDisabled()
            if !searchText.isEmpty {
                Button { searchText = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(AppColors.muted) }
            }
        }
        .padding(15).background(.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.border, lineWidth: 1))
    }

    private var welcomeCard: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 24).fill(AppColors.raspberry)
            Circle().fill(AppColors.pink.opacity(0.45)).frame(width: 150, height: 150).offset(x: 30, y: -45)
            Circle().fill(AppColors.greenLight.opacity(0.55)).frame(width: 90, height: 90).offset(x: -90, y: 105)
            VStack(alignment: .leading, spacing: 13) {
                Text("A LITTLE CAMPUS MAGIC").font(.system(size: 10, weight: .bold)).tracking(1.5).foregroundStyle(AppColors.yellow)
                Text("Good things deserve\na second life.").font(.system(size: 25, weight: .semibold, design: .serif)).foregroundStyle(.white)
                Label("Buy, swap, or pass it on.", systemImage: "heart.fill").font(.system(size: 12, weight: .medium)).foregroundStyle(AppColors.pinkLight)
            }
            .padding(23).frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 180).clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explore categories").font(.system(size: 21, weight: .bold, design: .serif)).foregroundStyle(AppColors.text)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(categories, id: \.self) { category in
                        Button { selectedCategory = category } label: {
                            Text(category).font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(selectedCategory == category ? .white : AppColors.text)
                                .padding(.horizontal, 15).padding(.vertical, 10)
                                .background(categoryColor(category, selected: selectedCategory == category), in: Capsule())
                                .overlay(Capsule().stroke(selectedCategory == category ? .clear : AppColors.border, lineWidth: 1))
                        }.buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func categoryColor(_ category: String, selected: Bool) -> Color {
        if selected { return AppColors.raspberry }
        switch category {
        case "Books": return AppColors.pinkLight
        case "Electronics": return Color(red: 0.88, green: 0.91, blue: 0.98)
        case "Hostel": return AppColors.yellow.opacity(0.65)
        case "Sports": return AppColors.greenLight
        case "Lab Equipment": return Color(red: 0.92, green: 0.88, blue: 0.96)
        default: return .white
        }
    }

    private var listingsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(searchText.isEmpty ? "Fresh on campus" : "Search results")
                    .font(.system(size: 21, weight: .bold, design: .serif)).foregroundStyle(AppColors.text)
                Spacer()
                Text("\(filteredListings.count) items").font(.system(size: 11, weight: .medium)).foregroundStyle(AppColors.muted)
            }
            if filteredListings.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "sparkles.magnifyingglass").font(.system(size: 35)).foregroundStyle(AppColors.pink)
                    Text("Nothing here just yet").font(.system(size: 16, weight: .semibold)).foregroundStyle(AppColors.text)
                    Text("Try another search or category.").font(.system(size: 13)).foregroundStyle(AppColors.muted)
                }.frame(maxWidth: .infinity).padding(30).parcelCard()
            } else {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(filteredListings) { listing in
                        NavigationLink(value: listing) { ListingCard(listing: listing) }.buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct ListingCard: View {
    @EnvironmentObject private var store: AppStore
    let listing: Listing
    private var isSaved: Bool { store.savedIDs.contains(listing.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                ProductArtwork(listing: listing, height: 132)
                Button { store.toggleSaved(listing) } label: {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .font(.system(size: 14, weight: .semibold)).foregroundStyle(AppColors.raspberry)
                        .frame(width: 34, height: 34).background(.white.opacity(0.96), in: Circle())
                }.buttonStyle(.plain).padding(9).accessibilityLabel(isSaved ? "Remove from saved" : "Save item")
            }
            VStack(alignment: .leading, spacing: 7) {
                Text(listing.category.uppercased()).font(.system(size: 9, weight: .bold)).tracking(0.8).foregroundStyle(AppColors.muted).lineLimit(1)
                Text(listing.title).font(.system(size: 14, weight: .semibold)).foregroundStyle(AppColors.text).multilineTextAlignment(.leading).lineLimit(2).frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 5) {
                    Text(listing.price).font(.system(size: 15, weight: .bold)).foregroundStyle(AppColors.raspberry)
                    Spacer(minLength: 0)
                    if listing.method == "Swap" { Image(systemName: "arrow.left.arrow.right").foregroundStyle(AppColors.green) }
                }.padding(.top, 2)
            }.padding(12)
        }
        .background(.white, in: RoundedRectangle(cornerRadius: 19)).clipShape(RoundedRectangle(cornerRadius: 19))
        .overlay(RoundedRectangle(cornerRadius: 19).stroke(AppColors.border.opacity(0.7), lineWidth: 1))
    }
}

// MARK: - Listing details
struct ListingDetailView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showingMessage = false
    @State private var showingOrderConfirmation = false
    let listing: Listing

    private var isSaved: Bool { store.savedIDs.contains(listing.id) }
    private var hasOrder: Bool { store.orders.contains(where: { $0.listingID == listing.id && $0.status != "Cancelled" }) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                ProductArtwork(listing: listing, height: 280).clipShape(RoundedRectangle(cornerRadius: 24))
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(listing.category.uppercased()).font(.system(size: 10, weight: .bold)).tracking(1.2).foregroundStyle(AppColors.raspberry)
                        Text(listing.title).font(.system(size: 28, weight: .bold, design: .serif)).foregroundStyle(AppColors.text)
                    }
                    Spacer()
                    Button { store.toggleSaved(listing) } label: {
                        Image(systemName: isSaved ? "heart.fill" : "heart").font(.system(size: 18)).foregroundStyle(AppColors.raspberry)
                            .frame(width: 46, height: 46).background(AppColors.pinkLight, in: Circle())
                    }.buttonStyle(.plain)
                }
                Text(listing.price).font(.system(size: 27, weight: .bold)).foregroundStyle(AppColors.raspberry)
                HStack(spacing: 9) {
                    Label(listing.condition, systemImage: "checkmark.seal")
                    Text("·")
                    Text(listing.method)
                }.font(.system(size: 12, weight: .medium)).foregroundStyle(AppColors.muted)
                Divider().overlay(AppColors.border)
                VStack(alignment: .leading, spacing: 9) {
                    Text("About this item").font(.system(size: 21, weight: .bold, design: .serif)).foregroundStyle(AppColors.text)
                    Text(listing.description).font(.system(size: 15)).foregroundStyle(AppColors.muted).lineSpacing(4)
                }
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill").font(.system(size: 40)).foregroundStyle(AppColors.green)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(listing.owner).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.text)
                        Text("A fellow campus member").font(.system(size: 12)).foregroundStyle(AppColors.muted)
                    }
                    Spacer()
                }.padding(15).parcelCard()
                Button { showingMessage = true } label: { Label("Message the seller", systemImage: "bubble.left") }.buttonStyle(PrimaryButtonStyle())
                Button {
                    store.placeOrder(for: listing)
                    showingOrderConfirmation = true
                } label: {
                    Label(hasOrder ? "Order already recorded" : "Record an order", systemImage: "bag.fill")
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.raspberry)
                        .frame(maxWidth: .infinity).padding(15).background(AppColors.pinkLight, in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain).disabled(hasOrder).opacity(hasOrder ? 0.65 : 1)
                Text("Demo note: this records an order on this device. It doesn't process payments or notify the seller.")
                    .font(.system(size: 11)).foregroundStyle(AppColors.muted).lineSpacing(3)
            }.padding(20)
        }
        .background(AppColors.cream.ignoresSafeArea())
        .navigationTitle("Item details").navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.cream, for: .navigationBar)
        .sheet(isPresented: $showingMessage) { MessageComposeView(listing: listing) }
        .alert("Order added", isPresented: $showingOrderConfirmation) {
            Button("Lovely", role: .cancel) { }
        } message: { Text("You can find this order in your profile. This demo doesn't contact the seller.") }
    }
}

// MARK: - Saved items
struct SavedView: View {
    @EnvironmentObject private var store: AppStore
    private var savedListings: [Listing] { store.listings.filter { store.savedIDs.contains($0.id) } }

    var body: some View {
        NavigationStack {
            Group {
                if savedListings.isEmpty {
                    EmptyStateView(symbol: "heart", title: "Save something for later", subtitle: "Tap the heart on a listing and it will show up here.")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 13) {
                            ForEach(savedListings) { listing in
                                NavigationLink(value: listing) {
                                    HStack(spacing: 13) {
                                        ProductArtwork(listing: listing, height: 82).frame(width: 88).clipShape(RoundedRectangle(cornerRadius: 13))
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(listing.title).font(.system(size: 14, weight: .semibold)).foregroundStyle(AppColors.text)
                                            Text(listing.category).font(.system(size: 12)).foregroundStyle(AppColors.muted)
                                            Text(listing.price).font(.system(size: 14, weight: .bold)).foregroundStyle(AppColors.raspberry)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right").font(.system(size: 11, weight: .semibold)).foregroundStyle(AppColors.muted)
                                    }.padding(12).parcelCard()
                                }.buttonStyle(.plain)
                            }
                        }.padding(18)
                    }
                }
            }
            .background(AppColors.cream.ignoresSafeArea())
            .navigationTitle("Saved items")
            .navigationDestination(for: Listing.self) { ListingDetailView(listing: $0) }
        }
    }
}

// MARK: - Create listing
struct CreateListingView: View {
    let onCreated: () -> Void
    @EnvironmentObject private var store: AppStore
    @State private var title = ""
    @State private var category = "Books"
    @State private var price = ""
    @State private var condition = "Good"
    @State private var description = ""
    @State private var method = "For sale"
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showCameraUnavailable = false
    @State private var imageData: Data?
    @State private var showError = false
    @State private var showSuccess = false

    private let categories = ["Books", "Electronics", "Hostel", "Sports", "Lab Equipment", "Other"]
    private let conditions = ["Like new", "Good", "Fair"]
    private let methods = ["For sale", "Free", "Swap"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ready to pass it on?").font(.system(size: 29, weight: .bold, design: .serif)).foregroundStyle(AppColors.text)
                        Text("Add a few details and help someone on campus find their next favourite thing.").font(.system(size: 14)).foregroundStyle(AppColors.muted).lineSpacing(3)
                    }
                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22).fill(AppColors.pinkLight)
                            if let imageData, let image = UIImage(data: imageData) {
                                Image(uiImage: image).resizable().scaledToFill().frame(height: 190).frame(maxWidth: .infinity).clipped()
                            } else {
                                VStack(spacing: 10) {
                                    Image(systemName: "camera.fill").font(.system(size: 30)).foregroundStyle(AppColors.raspberry)
                                    Text("Add a product photo").font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.raspberry)
                                    Text("Choose an existing photo or take one live.").font(.system(size: 11)).foregroundStyle(AppColors.muted)
                                }.padding(20)
                            }
                        }.frame(height: 190).clipShape(RoundedRectangle(cornerRadius: 22))
                        HStack(spacing: 10) {
                            PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                                Label("Photo Library", systemImage: "photo.on.rectangle").frame(maxWidth: .infinity).padding(13).background(.white, in: RoundedRectangle(cornerRadius: 13))
                            }.buttonStyle(.plain).foregroundStyle(AppColors.raspberry)
                            Button {
                                if UIImagePickerController.isSourceTypeAvailable(.camera) { showCamera = true } else { showCameraUnavailable = true }
                            } label: { Label("Live Camera", systemImage: "camera.fill").frame(maxWidth: .infinity).padding(13).background(.white, in: RoundedRectangle(cornerRadius: 13)) }
                            .buttonStyle(.plain).foregroundStyle(AppColors.raspberry)
                        }
                    }
                    .onChange(of: selectedPhoto) { item in
                        guard let item else { return }
                        Task { if let data = try? await item.loadTransferable(type: Data.self) { imageData = data } }
                    }
                    .sheet(isPresented: $showCamera) { CameraPicker(imageData: $imageData) }
                    .alert("Camera unavailable", isPresented: $showCameraUnavailable) { Button("OK", role: .cancel) {} } message: { Text("Live camera capture requires a physical iPhone or iPad. You can still choose a photo from your library.") }

                    formField("ITEM NAME") { TextField("e.g. First-year maths textbook", text: $title) }
                    VStack(alignment: .leading, spacing: 8) {
                        fieldLabel("CATEGORY")
                        Picker("Category", selection: $category) { ForEach(categories, id: \.self) { Text($0).tag($0) } }
                            .pickerStyle(.menu).tint(AppColors.raspberry).frame(maxWidth: .infinity, alignment: .leading).padding(12).background(.white, in: RoundedRectangle(cornerRadius: 13))
                    }
                    formField("PRICE / VALUE") { TextField("e.g. ₹250, Free, or Swap", text: $price) }
                    VStack(alignment: .leading, spacing: 8) {
                        fieldLabel("CONDITION")
                        Picker("Condition", selection: $condition) { ForEach(conditions, id: \.self) { Text($0).tag($0) } }
                            .pickerStyle(.segmented).tint(AppColors.pink)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        fieldLabel("HOW WOULD YOU LIKE TO PASS IT ON?")
                        Picker("Method", selection: $method) { ForEach(methods, id: \.self) { Text($0).tag($0) } }
                            .pickerStyle(.segmented).tint(AppColors.pink)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        fieldLabel("A LITTLE MORE ABOUT IT")
                        TextEditor(text: $description).frame(minHeight: 105).padding(8).scrollContentBackground(.hidden)
                            .background(.white, in: RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.border, lineWidth: 1))
                    }
                    if showError { Text("Add an item name, a price or exchange option, and a short description.").font(.system(size: 12)).foregroundStyle(AppColors.raspberry) }
                    Button { createListing() } label: { Label("Publish listing", systemImage: "sparkles") }.buttonStyle(PrimaryButtonStyle())
                    Text("Listings are saved on this device in this prototype.").font(.system(size: 11)).foregroundStyle(AppColors.muted)
                }.padding(20)
            }
            .background(AppColors.cream.ignoresSafeArea())
            .navigationTitle("List an item").navigationBarTitleDisplayMode(.inline)
            .alert("Your listing is live", isPresented: $showSuccess) { Button("Nice!") { onCreated() } } message: { Text("Your item has been added to the campus marketplace on this device.") }
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text).font(.system(size: 10, weight: .bold)).tracking(1).foregroundStyle(AppColors.muted)
    }

    private func formField<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel(label)
            content().font(.system(size: 14)).padding(14).background(.white, in: RoundedRectangle(cornerRadius: 13))
                .overlay(RoundedRectangle(cornerRadius: 13).stroke(AppColors.border, lineWidth: 1))
        }
    }

    private func createListing() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPrice = price.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty, !cleanPrice.isEmpty, !cleanDescription.isEmpty else { showError = true; return }
        let symbol = category == "Books" ? "book.closed.fill" : category == "Electronics" ? "function" : category == "Hostel" ? "lamp.desk.fill" : category == "Sports" ? "figure.badminton" : category == "Lab Equipment" ? "tshirt.fill" : "shippingbox.fill"
        let listing = Listing(title: cleanTitle, category: category, price: method == "Free" ? "Free" : method == "Swap" ? "Swap" : cleanPrice, condition: condition, owner: "You", symbol: symbol, description: cleanDescription, method: method, imageData: imageData, institute: store.instituteName)
        store.addListing(listing)
        title = ""; price = ""; description = ""; imageData = nil; selectedPhoto = nil; showError = false; showSuccess = true
    }
}

struct EmptyStateView: View {
    let symbol: String
    let title: String
    let subtitle: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: symbol).font(.system(size: 35)).foregroundStyle(AppColors.pink)
                .frame(width: 76, height: 76).background(AppColors.pinkLight, in: Circle())
            Text(title).font(.system(size: 18, weight: .bold, design: .serif)).foregroundStyle(AppColors.text)
            Text(subtitle).font(.system(size: 13)).foregroundStyle(AppColors.muted).multilineTextAlignment(.center).lineSpacing(3)
        }.padding(30).frame(maxWidth: .infinity, maxHeight: .infinity).background(AppColors.cream)
    }
}


// MARK: - Free study notes
struct FreeNotesView: View {
    private let resources: [(String, String, String, String)] = [
        ("Calculus, Volume 1", "OpenStax · Mathematics", "Free textbook PDF covering functions, limits, derivatives and integration.", "https://assets.openstax.org/oscms-prodcms/media/documents/CalculusVolume1-WEB.pdf"),
        ("College Physics", "OpenStax · Physics", "Free introductory physics textbook PDF for engineering students.", "https://assets.openstax.org/oscms-prodcms/media/documents/CollegePhysics-WEB.pdf"),
        ("University Physics, Volume 1", "OpenStax · Physics", "Mechanics, waves and related first-year physics topics.", "https://assets.openstax.org/oscms-prodcms/media/documents/UniversityPhysicsVolume1-WEB.pdf"),
        ("Introduction to Computer Science", "Open educational resource", "Browse free computer science learning material and notes.", "https://www.open.edu/openlearn/science-maths-technology/computing-ict")
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Free study notes").font(.system(size: 22, weight: .bold, design: .serif)).foregroundStyle(AppColors.text)
            Text("Open free educational resources and PDFs. These links are external resources, not files hosted by Pass the Parcel.").font(.system(size: 12)).foregroundStyle(AppColors.muted).lineSpacing(3)
            ForEach(resources, id: \.0) { item in
                Link(destination: URL(string: item.3)!) {
                    HStack(alignment: .top, spacing: 13) {
                        Image(systemName: "doc.text.fill").font(.system(size: 22)).foregroundStyle(AppColors.raspberry).frame(width: 48, height: 52).background(AppColors.pinkLight, in: RoundedRectangle(cornerRadius: 13))
                        VStack(alignment: .leading, spacing: 5) {
                            Text(item.0).font(.system(size: 15, weight: .semibold)).foregroundStyle(AppColors.text)
                            Text(item.1).font(.system(size: 11, weight: .semibold)).foregroundStyle(AppColors.raspberry)
                            Text(item.2).font(.system(size: 12)).foregroundStyle(AppColors.muted).multilineTextAlignment(.leading)
                            Label("Open resource", systemImage: "arrow.up.right.square").font(.system(size: 11, weight: .semibold)).foregroundStyle(AppColors.green).padding(.top, 3)
                        }
                        Spacer(minLength: 0)
                    }.padding(14).parcelCard()
                }.buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Live camera wrapper
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.cameraCaptureMode = .photo
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 0.8) { parent.imageData = data }
            parent.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.dismiss() }
    }
}
