# ``BroadRUBilling``

Optional RU catalog, checkout, durable reconciliation and subscription services.
Install this product only in app targets that use Russian payments. Base monetization
does not depend on it. Use the same operation gate and authenticated session as Apple purchases.

## Topics

### Composition
- ``RUBillingCompositionFactory``
- ``RUBillingServices``
- ``RUBillingAssembly``
- ``RUBillingCheckoutAdapter``
- ``RUBillingRemoteConfigurationParser``

### Recovery
- ``RUPaymentReturnCoordinator``
- ``RUPaymentReturnOutcome``
- ``PendingRUCheckoutState``
- ``RUPendingCheckoutTerminationCoordinator``
- ``RecoverRUCustomerAccessUseCase``

### Catalog and experiments
- ``RUCatalogProduct``
- ``RUBillingGate``
- ``RUBillingExperimentTracker``
- ``LoadPaywallWithRUFallbackUseCase``
