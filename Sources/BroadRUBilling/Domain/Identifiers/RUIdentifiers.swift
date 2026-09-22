import BroadMonetization
import Foundation

public struct RUCatalogProductID: RawRepresentable, Codable, Hashable, Sendable, ValidatedMonetizationIdentifier {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = validatedMonetizationIdentifier(rawValue, name: "RU catalog product ID")
    }
}

public struct RUSubscriptionID: RawRepresentable, Codable, Hashable, Sendable, ValidatedMonetizationIdentifier {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = validatedMonetizationIdentifier(rawValue, name: "RU subscription ID")
    }
}

private func validatedMonetizationIdentifier(
    _ rawValue: String,
    name: String
) -> String {
    precondition(
        MonetizationIdentifierPolicy.isValid(rawValue),
        "\(name) must be non-empty, trimmed and bounded"
    )
    return rawValue
}
