import BroadCore
import BroadMonetization
import BroadRUBilling
import BroadRUBillingUI
import SwiftUI

@MainActor
struct FixtureRUSubscriptionScreen: View {
    @StateObject private var viewModel = BroadRUSubscriptionManagementViewModel(
        dependencies: BroadRUSubscriptionDependencies(
            loadStatus: FixtureRUSubscriptionLoader(),
            cancelSubscription: FixtureRUSubscriptionCancellation()
        )
    )

    var body: some View {
        BroadRUSubscriptionManagementView(viewModel: viewModel)
    }
}

struct FixtureRUSubscriptionLoader: LoadRUSubscriptionStatusUseCaseProtocol {
    func callAsFunction() async -> RUSubscriptionManagementLoadOutcome {
        .loaded(
            RUSubscriptionManagementStatus(
                subscriptionID: RUSubscriptionID(rawValue: "fixture-ru-subscription"),
                planName: "Fixture RU plan",
                isActive: true,
                expiresAt: Date().addingTimeInterval(30 * 24 * 60 * 60),
                isLifetime: false,
                isAutoRenewalCancelled: false
            )
        )
    }
}

struct FixtureRUSubscriptionCancellation: CancelRUSubscriptionUseCaseProtocol {
    func callAsFunction(
        subscriptionID _: RUSubscriptionID
    ) async -> RUSubscriptionCancellationOutcome {
        .alreadyInactive
    }
}
