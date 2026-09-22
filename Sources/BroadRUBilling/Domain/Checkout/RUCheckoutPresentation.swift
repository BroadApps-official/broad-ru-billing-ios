import BroadMonetization
import Foundation

public enum RUBillingAvailabilityReason: String, Codable, Equatable, Sendable {
    case available
    case productNotEligible = "product-not-eligible"
    case hostDisabled = "host-disabled"
    case debugForcedEnabled = "debug-forced-enabled"
    case debugForcedDisabled = "debug-forced-disabled"
    case remoteFlagAbsent = "remote-flag-absent"
    case remoteFlagDisabled = "remote-flag-disabled"
    case remoteFlagInvalid = "remote-flag-invalid"
    case unqualifiedRemoteConfiguration = "unqualified-remote-configuration"
    case deviceContextNotRussian = "device-context-not-russian"
    case catalogUnavailable = "catalog-unavailable"
    case productNotMatched = "product-not-matched"
    case methodsUnavailable = "methods-unavailable"
}

extension RUBillingAvailabilityReason {
    var allowsRUBilling: Bool {
        self == .available || self == .debugForcedEnabled
    }
}

public struct RUCheckoutDetails: Codable, Equatable, Sendable {
    public let acceptsOfferAndPersonalDataProcessing: Bool
    public let acceptsRecurringCharge: Bool
    public let receiptEmail: String?

    public init(
        acceptsOfferAndPersonalDataProcessing: Bool,
        acceptsRecurringCharge: Bool,
        receiptEmail: String? = nil
    ) {
        self.acceptsOfferAndPersonalDataProcessing =
            acceptsOfferAndPersonalDataProcessing
        self.acceptsRecurringCharge = acceptsRecurringCharge
        let normalizedEmail = receiptEmail?.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        self.receiptEmail = normalizedEmail?.isEmpty == false
            ? normalizedEmail
            : nil
    }
}

public extension CheckoutMethod {
    static let sbp = Self(rawValue: "sbp")
    static let card = Self(rawValue: "card")
}

private struct RUResolution: Codable {
    let reason: RUBillingAvailabilityReason
    let product: RUCatalogProduct?
}

public extension CheckoutMethodsResolution {
    init(
        methods: [CheckoutMethod],
        storefront: Storefront?,
        ruBillingAvailability: RUBillingAvailabilityReason,
        ruProduct: RUCatalogProduct? = nil
    ) {
        self.init(
            methods: methods,
            storefront: storefront,
            providerData: try? RUProviderPayloadEncoding.encode(RUResolution(reason: ruBillingAvailability, product: ruProduct)),
            providerID: "ru-billing"
        )
    }

    var ruBillingAvailability: RUBillingAvailabilityReason {
        guard providerID == "ru-billing", let providerData else { return .hostDisabled }
        return (try? JSONDecoder().decode(RUResolution.self, from: providerData))?.reason ?? .hostDisabled
    }

    var ruProduct: RUCatalogProduct? {
        guard providerID == "ru-billing", let providerData else { return nil }
        return (try? JSONDecoder().decode(RUResolution.self, from: providerData))?.product
    }
}

public extension CheckoutOptions {
    init(ruDetails: RUCheckoutDetails?) {
        self.init(providerID: "ru-billing", providerData: ruDetails.flatMap { try? RUProviderPayloadEncoding.encode($0) })
    }

    var ruDetails: RUCheckoutDetails? {
        guard providerID == "ru-billing", let providerData else { return nil }
        return try? JSONDecoder().decode(RUCheckoutDetails.self, from: providerData)
    }
}
