import BroadMonetization
import Foundation

public enum RemoteRUBillingGateDecision: String, Codable, Equatable, Sendable {
    case absent
    case enabled
    case disabled
    case invalid

    var booleanValue: Bool? {
        switch self {
        case .enabled: true
        case .disabled: false
        case .absent, .invalid: nil
        }
    }
}

struct RURemoteConfiguration: Codable {
    let decision: RemoteRUBillingGateDecision
}

public extension RemotePaywallConfiguration {
    var ruBillingGateDecision: RemoteRUBillingGateDecision {
        ruConfiguration?.decision ?? .absent
    }

    var isRUBillingEnabled: Bool? {
        ruBillingGateDecision.booleanValue
    }

    var ruExperiment: RUExperimentMetadata? {
        guard let metadata = providerConfigurations["ru-billing"]?.liveMetadata else { return nil }
        return try? JSONDecoder().decode(RUExperimentMetadata.self, from: metadata)
    }

    var authorizesRUBillingPresentation: Bool {
        authorizesProviderFeatures
    }

    var authorizesRUProviderFallback: Bool {
        get { authorizesProviderFallback }
        set { authorizesProviderFallback = newValue }
    }

    init(
        isRUBillingEnabled: Bool?,
        isAutomaticRevenueViewEnabled: Bool? = nil,
        accessPolicy: PaywallAccessPolicy? = nil,
        closeDelay: TimeInterval? = nil,
        uiVariantID: PaywallUIVariantID? = nil,
        specialOffer: SpecialOfferRemoteConfiguration? = nil,
        ruExperiment: RUExperimentMetadata? = nil
    ) {
        let decision: RemoteRUBillingGateDecision = isRUBillingEnabled.map { $0 ? .enabled : .disabled } ?? .absent
        let data = try? RUProviderPayloadEncoding.encode(RURemoteConfiguration(decision: decision))
        self.init(
            isAutomaticRevenueViewEnabled: isAutomaticRevenueViewEnabled,
            accessPolicy: accessPolicy,
            closeDelay: closeDelay,
            uiVariantID: uiVariantID,
            specialOffer: specialOffer,
            providerConfigurations: data.map { ["ru-billing": ProviderRemoteConfiguration(
                decisionData: $0,
                liveMetadata: ruExperiment.flatMap { try? RUProviderPayloadEncoding.encode($0) }
            )] } ?? [:]
        )
    }

    private var ruConfiguration: RURemoteConfiguration? {
        guard let data = providerConfigurations["ru-billing"] else { return nil }
        return try? JSONDecoder().decode(RURemoteConfiguration.self, from: data.decisionData)
    }
}
