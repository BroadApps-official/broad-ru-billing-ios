import BroadMonetization
import Foundation

public struct RUBillingRemoteConfigurationParser: ProviderRemoteConfigParserProtocol {
    public init() {}
    public var providerID: String {
        "ru-billing"
    }

    public var fallbackKeyGroups: [[String]] {
        [["ru_pay", "pay", "russian_payment", "ru_billing"], ["experiment_code", "segment_code"]]
    }

    public func parse(_ dictionary: [String: Any]) -> ProviderRemoteConfiguration? {
        guard let decision = try? RUProviderPayloadEncoding.encode(RURemoteConfiguration(decision: parseRUBillingGate(in: dictionary)))
        else { return nil }
        let metadata = parseRUExperiment(dictionary).flatMap { try? RUProviderPayloadEncoding.encode($0) }
        return ProviderRemoteConfiguration(decisionData: decision, liveMetadata: metadata)
    }

    func parseRUExperiment(_ dictionary: [String: Any]) -> RUExperimentMetadata? {
        // Codes are strict strings from the selected configuration. In particular,
        // NSNumber/Bool and variation IDs are not alternate segment codes.
        guard let experiment = dictionary["experiment_code"] as? String,
              let segment = dictionary["segment_code"] as? String
        else {
            return nil
        }
        return RUExperimentMetadata(experimentCode: experiment, segmentCode: segment)
    }

    func parseRUBillingGate(
        in dictionary: [String: Any]
    ) -> RemoteRUBillingGateDecision {
        var didFindKey = false
        var didFindInvalidValue = false
        var parsedValues: [Bool] = []

        for alias in ["ru_pay", "pay", "russian_payment", "ru_billing"] where dictionary.keys.contains(alias) {
            didFindKey = true
            guard let rawValue = dictionary[alias],
                  let parsed = parseBool(rawValue)
            else {
                didFindInvalidValue = true
                continue
            }
            parsedValues.append(parsed)
        }

        guard didFindKey else {
            return .absent
        }
        // An explicit kill switch always wins, including over a malformed or
        // conflicting alias with higher lookup priority.
        if parsedValues.contains(false) {
            return .disabled
        }
        guard !didFindInvalidValue,
              !parsedValues.isEmpty,
              parsedValues.allSatisfy({ $0 })
        else {
            return .invalid
        }
        return .enabled
    }

    func parseBool(_ value: Any) -> Bool? {
        if let boolean = value as? Bool {
            return boolean
        }
        if let number = value as? NSNumber {
            switch number.doubleValue {
            case 0: return false
            case 1: return true
            default: return nil
            }
        }
        guard let string = value as? String else {
            return nil
        }
        switch string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "1", "true", "yes", "y", "on": return true
        case "0", "false", "no", "n", "off", "": return false
        default: return nil
        }
    }
}
