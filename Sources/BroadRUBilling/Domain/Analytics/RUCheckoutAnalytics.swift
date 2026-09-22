import BroadMonetization

public typealias RUCheckoutAnalyticsContext = ProviderCheckoutAnalyticsContext
public extension ProviderCheckoutAnalyticsContext {
    init(
        attemptID: MonetizationAttemptID,
        productID: RUCatalogProductID,
        checkoutMethod: CheckoutMethod,
        paywallPresentationID: PaywallPresentationID? = nil,
        paywallVariationID: PaywallVariationID? = nil,
        requestedPlacementID: PlacementID? = nil,
        resolvedPlacementID: PlacementID? = nil
    ) {
        precondition(checkoutMethod == .sbp || checkoutMethod == .card)
        self.init(
            attemptID: attemptID,
            productID: ProductID(rawValue: productID.rawValue),
            checkoutMethod: checkoutMethod,
            paywallPresentationID: paywallPresentationID,
            paywallVariationID: paywallVariationID,
            requestedPlacementID: requestedPlacementID,
            resolvedPlacementID: resolvedPlacementID
        )
    }

    init(
        attemptID: MonetizationAttemptID,
        selection: ProductSelection,
        productID: RUCatalogProductID,
        checkoutMethod: CheckoutMethod
    ) {
        self.init(
            attemptID: attemptID,
            productID: productID,
            checkoutMethod: checkoutMethod,
            paywallPresentationID: selection.paywallPresentationID,
            paywallVariationID: selection.paywallVariationID,
            requestedPlacementID: selection.requestedPlacementID,
            resolvedPlacementID: selection.resolvedPlacementID
        )
    }
}

public extension MonetizationAnalyticsEvent {
    static func ruCheckoutCreated(_ context: RUCheckoutAnalyticsContext) -> Self {
        .providerCheckoutCreated(context)
    }

    static func ruCheckoutOpenFailed(
        _ context: RUCheckoutAnalyticsContext,
        failure: MonetizationAnalyticsFailure
    ) -> Self {
        .providerCheckoutOpenFailed(
            context,
            failure: failure
        )
    }

    static func ruCheckoutSafariReturned(_ context: RUCheckoutAnalyticsContext) -> Self {
        .providerCheckoutSafariReturned(context)
    }

    static func ruCheckoutConfirmed(_ context: RUCheckoutAnalyticsContext) -> Self {
        .providerCheckoutConfirmed(context)
    }

    static func ruCheckoutTimedOut(_ context: RUCheckoutAnalyticsContext) -> Self {
        .providerCheckoutTimedOut(context)
    }
}
