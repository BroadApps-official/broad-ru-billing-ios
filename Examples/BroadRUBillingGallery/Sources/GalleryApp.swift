import BroadRUBilling
import SwiftUI

@main
struct RUBillingGalleryApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                List {
                    NavigationLink("Способы оплаты и согласия") { FixturePaymentSheet(initialMethod: .sbp) }
                    NavigationLink("Управление подпиской") { FixtureRUSubscriptionScreen() }
                }
                .navigationTitle("RU Billing fixtures")
            }
        }
    }
}
