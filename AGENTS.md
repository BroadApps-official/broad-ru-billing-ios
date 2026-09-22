# BroadRUBilling agent rules

- Owns optional RU billing logic and UI. Base BroadMonetization and BroadUIFlows must never depend on this repository.
- Preserve durable pending keys, account binding, bounded account-policy waiting and server-authoritative access. Browser close and timeout are not payment cancellation.
- Use the exact shared MonetizationOperationGate. Register pending blockers before exposing purchase/restore entry points.
- Keep checkout URLs, credentials, email and account IDs out of analytics and diagnostics.
- Preserve provider order and duplicate product rows. Token/special-offer placements never borrow ordinary subscription products.
- No Tests/, test targets, XCTest, Swift Testing, UI tests or real payments. Use executable contract probes with fixtures.
- Update documentation, public API reports, gallery and release metadata together.
- Run Scripts/module_gate.sh before claiming PASS.
