import Foundation

enum ProviderExtractionProbe {
    static func run() throws {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        let method = try decoder.decode(CheckoutMethod.self, from: Data(#""sbp""#.utf8))
        precondition(method == .sbp)
        let encodedMethod = try encoder.encode(method)
        let sourceID = try decoder.decode(EntitlementSource.self, from: Data(#""ru-billing""#.utf8))
        let catalogID = try decoder.decode(CatalogSource.self, from: Data(#""ru-backend""#.utf8))
        precondition(encodedMethod == Data(#""sbp""#.utf8))
        precondition(sourceID == .ruBilling && catalogID == .ruBackend)

        let parser = RemotePaywallConfigurationParser(providers: [RUBillingRemoteConfigurationParser()])
        let source: [String: Any] = ["ru_pay": true, "experiment_code": "fixture", "segment_code": "one"]
        let parsed = parser.parse(source)
        precondition(parsed == parser.parse(source))
        let unqualified = parsed.qualified(by: .legacyUnqualified)
        precondition(unqualified.ruBillingGateDecision == .enabled)
        precondition(!unqualified.authorizesRUBillingPresentation && unqualified.ruExperiment == nil)
        let live = parsed.qualified(by: .providerCacheFallbackPossible)
        precondition(live.ruExperiment != nil && live.authorizesRUBillingPresentation)
        let persisted = try decoder.decode(RemotePaywallConfiguration.self, from: encoder.encode(live))
        precondition(persisted.ruExperiment == nil && !persisted.authorizesRUBillingPresentation)
        precondition(persisted.providerConfigurations.isEmpty && !persisted.authorizesProviderFallback)

        let row = RUCatalogProduct(
            catalogProductID: .init(rawValue: "fixture"),
            kind: .subscription,
            appStoreProductID: nil,
            price: Money(amount: 10, currencyCode: "RUB"),
            displayPrice: "provider price",
            subscriptionPeriod: .month(),
            supportedMethods: [.sbp]
        )
        var object = try JSONSerialization.jsonObject(with: encoder.encode(row)) as! [String: Any]
        object["supportedMethods"] = ["unknown-provider-method"]
        let foreign = try JSONSerialization.data(withJSONObject: object)
        precondition((try? decoder.decode(RUCatalogProduct.self, from: foreign)) == nil)
        print(
            "Provider extraction passed: legacy identifiers, canonical payload equality, authority, cache stripping and foreign method rejection."
        )
    }
}
