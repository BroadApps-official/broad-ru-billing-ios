#!/usr/bin/env python3
"""Run production-source executable probes without SDK activation or payments.

The package build separately verifies real module boundaries. These small macOS
executables can also exercise internal persistence and HTTP fixture seams.
"""
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parent.parent
monetization = Path(os.environ.get('BROAD_MONETIZATION_ROOT', root / '.build/checkouts/broad-monetization-ios'))
core = Path(os.environ.get('BROAD_CORE_ROOT', root / '.build/checkouts/broad-core-ios'))
base = monetization / 'Sources/BroadMonetization'
provider = root / 'Sources/BroadRUBilling'

def run(args):
    subprocess.run(args, check=True)

with tempfile.TemporaryDirectory(prefix='broad-ru-contracts-') as temporary:
    scratch = Path(temporary)
    core_source = core / 'Sources/BroadCore'
    core_files = sorted((core_source / 'Domain').rglob('*.swift'))
    core_files += [core_source / name for name in (
        'Infrastructure/Networking/NetworkFailureClassifier.swift',
        'Application/Storage/KeyValueStoreProtocol.swift',
        'Data/Cache/VersionedJSONCacheRepository.swift',
        'Infrastructure/Logging/NoOpBroadLogger.swift',
    )]
    run(['xcrun', 'swiftc', '-emit-library', '-emit-module', '-module-name', 'BroadCore',
         *map(str, core_files), '-emit-module-path', str(scratch / 'BroadCore.swiftmodule'),
         '-o', str(scratch / 'libBroadCore.dylib')])
    files = sorted((base / 'Domain').rglob('*.swift'))
    for directory in ('Infrastructure/RemoteConfig', 'Application/Recovery'):
        files += sorted((base / directory).rglob('*.swift'))
    files += [base / name for name in (
        'Application/Purchase/MonetizationOperationGate.swift',
        'Application/PurchaseManagers/TokenPurchaseModels.swift',
        'Application/Paywalls/LoadPaywallUseCase.swift',
        'Application/DI/PaywallProviderComposition.swift',
        'Data/Paywalls/LastValidRemoteConfigurationStore.swift',
        'Data/Paywalls/PlacementPaywallConfigurationLoader.swift',
        'Infrastructure/Adapty/AdaptyPlacementRegistry.swift',
        'Infrastructure/Analytics/NoOpMonetizationAnalytics.swift',
        'Infrastructure/Analytics/NonBlockingMonetizationAnalytics.swift',
    )]
    files += [p for p in sorted(provider.rglob('*.swift')) if '/Application/DI/' not in str(p) and p.name not in ('PaymentURLOpener.swift', 'RUBillingManager.swift')]
    sources = []
    for index, path in enumerate(files):
        copy = scratch / f'{index}-{path.name}'
        copy.write_text(path.read_text().replace('import BroadMonetization\n', ''))
        sources.append(str(copy))
    groups = {
        'account-policy': ['RUAccountPolicyProbe', 'RUWaitingStoreProbe', 'ProviderExtractionProbe'],
        'experiments': ['RUExperimentProbe', 'RUExperimentHTTPProbe', 'PlacementPaywallConfigurationProbe'],
        'fallback': ['RUProviderFallbackProbe', 'RUDefaultProductsProbe'],
    }
    requested = os.environ.get('BROAD_CONTRACT_PROBE')
    for name, probes in groups.items():
        if requested and requested != name:
            continue
        executable = scratch / name
        run(['xcrun', 'swiftc', '-parse-as-library', '-strict-concurrency=complete', '-warnings-as-errors',
             '-I', temporary, '-L', temporary, '-lBroadCore', '-Xlinker', '-rpath', '-Xlinker', temporary,
             *sources, *[str(root / 'Scripts/ContractProbes' / f'{p}.swift') for p in probes],
             '-o', str(executable)])
        run([str(executable)])
