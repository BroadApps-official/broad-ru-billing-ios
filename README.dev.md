# Development

## Что изменилось и почему

The RU provider is extracted from BroadMonetization and BroadUIFlows so an app can
exclude it from its complete package and build graph. Shared extension points stay
in base modules. BroadCore transports typed diagnostics without RU-specific cases.

`bash Scripts/module_gate.sh` validates the published dependency graph. For the
unreleased cross-repository candidate, build a local SwiftPM workspace with the four
packages and run `Scripts/run_contract_probes.py` with `BROAD_MONETIZATION_ROOT` and
`BROAD_CORE_ROOT` pointing at those checkouts. Module builds verify import boundaries;
the executable probes also exercise internal HTTP/persistence seams using fixtures.

Do not change durable keys, wire enums or account binding during a packaging change.
Update both API reports when the public surface changes. No real backend operations.
