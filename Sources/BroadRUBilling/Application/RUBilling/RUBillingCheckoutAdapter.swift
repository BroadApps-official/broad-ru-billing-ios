import BroadMonetization

/// Adapts external page opening to the shared, server-authoritative checkout result.
public struct RUBillingCheckoutAdapter: CheckoutSelectedProductUseCaseProtocol {
    private let checkout: any StartSelectedRUCheckoutUseCaseProtocol
    public init(checkout: any StartSelectedRUCheckoutUseCaseProtocol) {
        self.checkout = checkout
    }

    public func callAsFunction(
        _ selection: ProductSelection,
        using method: CheckoutMethod,
        remoteConfiguration: RemotePaywallConfiguration,
        options: CheckoutOptions
    ) async -> CheckoutSelectedProductOutcome {
        switch await checkout(selection, using: method, remoteConfiguration: remoteConfiguration, options: options) {
        case .opened: .pending
        case let .unavailable(error), let .failed(error): .failed(error)
        }
    }
}
