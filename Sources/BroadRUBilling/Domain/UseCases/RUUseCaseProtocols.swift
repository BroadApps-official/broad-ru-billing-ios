import BroadMonetization

protocol CreateRUCheckoutUseCaseProtocol: Sendable {
    func callAsFunction(
        _ request: RUCheckoutRequest
    ) async -> RUCheckoutCreationOutcome
}

/// Raw session polling is internal to `RUPaymentReturnCoordinator`, which first
/// proves that the durable record belongs to the current subject.
protocol RefreshRUPaymentUseCaseProtocol: Sendable {
    func callAsFunction(
        checkoutSessionID: CheckoutSessionID,
        productID: RUCatalogProductID,
        accountExpectation: RUAccountCheckoutExpectation?
    ) async -> RUPaymentRefreshOutcome
    func callAsFunction(
        checkoutSessionID: CheckoutSessionID
    ) async -> RUPaymentRefreshOutcome
}

extension RefreshRUPaymentUseCaseProtocol {
    func callAsFunction(
        checkoutSessionID: CheckoutSessionID,
        productID _: RUCatalogProductID,
        accountExpectation _: RUAccountCheckoutExpectation?
    ) async -> RUPaymentRefreshOutcome {
        await callAsFunction(checkoutSessionID: checkoutSessionID)
    }
}

public protocol CancelRUSubscriptionUseCaseProtocol: Sendable {
    func callAsFunction(
        subscriptionID: RUSubscriptionID
    ) async -> RUSubscriptionCancellationOutcome
}

public protocol LoadRUSubscriptionStatusUseCaseProtocol: Sendable {
    func callAsFunction() async -> RUSubscriptionManagementLoadOutcome
}
