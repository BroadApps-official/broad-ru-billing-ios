# BroadRUBilling

![Release 1.0.0](https://img.shields.io/badge/release-1.0.0-10B981)

Optional Russian billing for BroadApps iPhone applications. Host app подключает этот repository только по надобности.

| Product | Responsibility |
|---|---|
| `BroadRUBilling` | Catalog, checkout, pending recovery, account-policy/payment-status polling, subscription management, experiments |
| `BroadRUBillingUI` | Payment method and consent sheet, receipt email, subscription screens, `BroadRUPaywallView` |

Requires iOS 17, BroadCore 3.0.0, BroadMonetization 5.0.0 and (for UI) BroadUIFlows 5.0.0.
Base packages do not depend on this repository. Apps without RU payments omit the
package entirely: no runtime flag, disabled adapter, callback registration or RU resources are needed.

```swift
.package(url: "https://github.com/BroadApps-official/broad-ru-billing-ios.git", from: "1.0.0")
```

Add only the products used by the target. `BroadRUBilling` does not depend on the
UI target, so custom UI does not compile `BroadRUBillingUI`.

## Composition

1. Build one authenticated subject/session binding, one persistent cache and one
   `MonetizationOperationGate`. Keep existing app identifier and storage keys during migration.
2. Create `RUBillingCompositionFactory` with the confirmed app-owned backend contract.
   Add its entitlement registration to the shared entitlement composition.
3. Pass `RemotePaywallConfigurationParser(providers: [RUBillingRemoteConfigurationParser()])`
   to `AdaptyMonetizationFactory`. For experiment reporting, pass the tracker as
   `viewReporting`; its reservation chooses a single destination even on failure.
4. Pass the RU factory as `paywallLoaderFactory` to `makeServices`. Compose RU
   services with the same entitlement refresher and exact shared operation gate.
5. Use `CheckoutSelectedProductUseCase(applePurchase: base.purchaseProduct,
   additionalCheckout: RUBillingCheckoutAdapter(checkout: ru.checkout.startSelectedProduct))`.
   Inject `ru.catalog.resolveCheckoutMethods` according to the service API.
6. For standard UI use `BroadRUPaywallView(viewModel:configuration:onClose:onCompleted:)`.
   RU presentation configuration belongs to this view; generic paywall configuration
   remains in BroadUIFlows. Custom UI may use `BroadPaymentMethodSheet` directly.
7. Register callback URL, foreground and browser-dismissal handling only in the
   RU-enabled target, forwarding them to `ru.checkout.applicationReturn`. A callback
   schedules reconciliation; it is never proof of payment.

See the compile-checked [wiring examples](Examples/BroadRUBillingGallery/Sources)
and [account-policy contract](Documentation/RUAccountPolicy.md).

## Pending operations and migration

Wire values (`sbp`, `card`, `ru-billing`, `ru-backend`), catalog row fingerprints,
pending record keys, schema and account partitions are preserved. Existing attempts
continue after migration. Do not clear pending storage or change the app identifier.
Before exposing purchase/restore, compose the RU services so their durable blocker
is registered synchronously in the shared gate.

Account-policy mode completes bounded local waiting as `waitingCompleted`, retaining
`awaitingReconciliation`. A new checkout first reads fresh backend policy and replaces
the previous attempt atomically. Payment-status mode keeps blocking until a terminal
server result. Browser close, timeout and callback are never financial cancellation.
Late old callbacks cannot clear a new attempt or grant access to a different account.

Premium and tokens use separate authoritative results. Use
`RecoverRUCustomerAccessUseCase` to combine base customer recovery and subscription
management status. Receipt email and payment URLs never enter analytics.

## Validation

```sh
bash Scripts/module_gate.sh
```

The gate builds both products and the iPhone fixture gallery, runs executable
production-source probes and checks public API/documentation. It never executes a
real purchase, restore, cancellation or backend payment. No test target is required.

[Public API](Documentation/PublicAPI.md) · [Changelog](CHANGELOG.md) ·
[Platform documentation](https://broadapps-ios-docs.nkhsnv.chatgpt.site)
