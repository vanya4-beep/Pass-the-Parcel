import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore()
    @State private var selectedTab: AppTab = .explore

    var body: some View {
        Group {
            if store.studentEmail.isEmpty {
                AuthenticationView { email, institute in
                    _ = store.signIn(email: email, institute: institute)
                }
            } else {
                TabView(selection: $selectedTab) {
                    ExploreView().tabItem { Label("Explore", systemImage: "sparkle.magnifyingglass") }.tag(AppTab.explore)
                    SavedView().tabItem { Label("Saved", systemImage: "heart") }.tag(AppTab.saved)
                    CreateListingView { selectedTab = .explore }.tabItem { Label("List an Item", systemImage: "plus.circle.fill") }.tag(AppTab.list)
                    MessagesInboxView().tabItem { Label("Messages", systemImage: "bubble.left.and.bubble.right") }.tag(AppTab.messages)
                    ProfileView().tabItem { Label("Profile", systemImage: "person.crop.circle") }.tag(AppTab.profile)
                }
                .tint(AppColors.raspberry)
            }
        }
        .environmentObject(store)
        .preferredColorScheme(.light)
    }
}
