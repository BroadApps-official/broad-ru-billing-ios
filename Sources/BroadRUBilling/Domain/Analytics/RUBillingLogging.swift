import BroadCore

public enum BroadLogRUBillingAvailabilityReason: String, Equatable, Sendable {
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

extension BroadLogRUBillingAvailabilityReason {
    var logLevel: BroadLogLevel {
        switch self {
        case .available, .debugForcedEnabled:
            .info
        case .remoteFlagInvalid, .catalogUnavailable, .productNotMatched:
            .warning
        case .productNotEligible,
             .hostDisabled,
             .debugForcedDisabled,
             .remoteFlagAbsent,
             .remoteFlagDisabled,
             .unqualifiedRemoteConfiguration,
             .deviceContextNotRussian,
             .methodsUnavailable:
            .debug
        }
    }
}

public extension BroadLogEvent {
    static func ruBillingAvailabilityEvaluated(reason: BroadLogRUBillingAvailabilityReason, methodCount: Int) -> Self {
        .host(BroadLogHostEvent(
            code: "ru-billing.availability.evaluated",
            category: .monetization,
            level: reason.logLevel,
            fields: [BroadLogHostField("reason", reason.symbol), BroadLogHostField("method_count", max(0, methodCount))]
        ))
    }
}

private extension BroadLogRUBillingAvailabilityReason {
    var symbol: StaticString {
        switch self {
        case .available: "available"
        case .productNotEligible: "product-not-eligible"
        case .hostDisabled: "host-disabled"
        case .debugForcedEnabled: "debug-forced-enabled"
        case .debugForcedDisabled: "debug-forced-disabled"
        case .remoteFlagAbsent: "remote-flag-absent"
        case .remoteFlagDisabled: "remote-flag-disabled"
        case .remoteFlagInvalid: "remote-flag-invalid"
        case .unqualifiedRemoteConfiguration: "unqualified-remote-configuration"
        case .deviceContextNotRussian: "device-context-not-russian"
        case .catalogUnavailable: "catalog-unavailable"
        case .productNotMatched: "product-not-matched"
        case .methodsUnavailable: "methods-unavailable"
        }
    }
}
