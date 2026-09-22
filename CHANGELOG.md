# Changelog

## 1.0.0

### Added — что изменилось и почему

- Extracted RU billing and UI from BroadMonetization/BroadUIFlows into optional
  `BroadRUBilling` and `BroadRUBillingUI` products. Base dependencies contain no RU implementation.
- Explicit provider parsing, loader, checkout and view-reporting composition; shared
  operation gate, authorization binding and server-authoritative entitlement refresh.
- Existing pending storage, row fingerprints and wire values remain compatible.
  Account-policy bounded waiting and late-payment reconciliation are preserved.
- Dedicated fixture gallery, contract probes, API reports and migration instructions.
