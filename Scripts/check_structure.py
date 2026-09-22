#!/usr/bin/env python3
from pathlib import Path
import re

root = Path(__file__).resolve().parent.parent
required = ["Package.swift", "ModuleContract.json", "README.md", "README.dev.md", "CHANGELOG.md", "CONTRIBUTING.md", "SECURITY.md", "AGENTS.md", "Scripts/module_gate.sh", "Scripts/run_contract_probes.py", "Documentation/PublicAPI.md", "Documentation/PublicAPI-UI.md", ".github/workflows/quality.yml", ".github/workflows/release.yml", "Examples/BroadRUBillingGallery/project.yml"]
errors = [f"Missing: {path}" for path in required if not (root / path).exists()]
for p in root.rglob('*'):
    if any(part in ('.git', '.build', 'DerivedData') for part in p.parts):
        continue
    if p.is_dir() and p.name.endswith('Tests'):
        errors.append(f"Forbidden tests directory: {p.relative_to(root)}")
    if p.suffix != '.swift':
        continue
    text = p.read_text()
    if re.search(r'import (XCTest|Testing)\b|@Test\b|\.testTarget\(', text):
        errors.append(f"Forbidden test target/framework: {p.relative_to(root)}")
    if 'Sources' not in p.parts:
        continue
    imports = re.findall(r'^import (\w+)', text, re.M)
    if 'BroadRUBilling' in p.parts and any(i in imports for i in ('BroadUIFlows', 'BroadRUBillingUI', 'BroadExtensions')):
        errors.append(f"Logic imports UI: {p.relative_to(root)}")
    if 'Domain' in p.parts and any(i in imports for i in ('SwiftUI', 'UIKit', 'StoreKit', 'Adapty')):
        errors.append(f"Domain imports framework: {p.relative_to(root)}")
    if 'BroadRUBillingUI' in p.parts and any(i in imports for i in ('StoreKit', 'Adapty')):
        errors.append(f"UI imports SDK: {p.relative_to(root)}")
    if re.search(r'/Users/|/Volumes/|sk_live_[A-Za-z0-9]{12,}|-----BEGIN .*PRIVATE KEY', text):
        errors.append(f"Machine-specific path or secret: {p.relative_to(root)}")
if errors:
    raise SystemExit('\n'.join(errors))
print('Optional provider structure and import boundaries passed.')
