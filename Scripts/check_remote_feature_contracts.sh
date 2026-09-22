#!/usr/bin/env bash

set -euo pipefail

platform_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failure_count=0

require_pattern() {
    local description="$1"
    local file="$2"
    local pattern="$3"
    local status=0

    rg -q --pcre2 --multiline "$pattern" "$file" || status=$?
    case "$status" in
        0)
            echo "PASS: $description"
            ;;
        1)
            echo "FAIL: $description"
            echo "      $file"
            failure_count=$((failure_count + 1))
            ;;
        *)
            echo "Remote feature contract check could not run: $description"
            exit "$status"
            ;;
    esac
}

forbid_pattern() {
    local description="$1"
    local pattern="$2"
    shift 2
    local output=""
    local status=0

    output="$(rg -n --pcre2 --multiline "$pattern" "$@")" || status=$?
    case "$status" in
        0)
            echo "FAIL: $description"
            echo "$output"
            failure_count=$((failure_count + 1))
            ;;
        1)
            echo "PASS: $description"
            ;;
        *)
            echo "Remote feature contract check could not run: $description"
            exit "$status"
            ;;
    esac
}

ru_gate_file="$platform_root/Sources/BroadRUBilling/Application/RUBilling/RUBillingGate.swift"
ru_device_context_file="$platform_root/Sources/BroadRUBilling/Domain/Checkout/RUBillingDeviceContext.swift"
ru_debug_override_file="$platform_root/Sources/BroadRUBilling/Application/RUBilling/RUBillingDebugOverride.swift"
ru_resolution_file="$platform_root/Sources/BroadRUBilling/Application/RUBilling/ResolveCheckoutMethodsUseCase.swift"
ru_checkout_flow_file="$platform_root/Sources/BroadRUBilling/Application/RUBilling/RUCheckoutFlowCoordinator.swift"
ru_flat_catalog_file="$platform_root/Sources/BroadRUBilling/Infrastructure/RUBilling/FlatRUCatalogResponseDecoder.swift"
ru_catalog_product_file="$platform_root/Sources/BroadRUBilling/Domain/Checkout/RUCatalogProduct.swift"
ru_catalog_matcher_file="$platform_root/Sources/BroadRUBilling/Application/RUBilling/RUCatalogProductMatcher.swift"
ru_composition_models_file="$platform_root/Sources/BroadRUBilling/Application/DI/RUBillingCompositionModels.swift"
ru_composition_factory_file="$platform_root/Sources/BroadRUBilling/Application/DI/RUBillingCompositionFactory.swift"
require_pattern \
    "RU Billing requires provider authorization or a live opt-in outage capability" \
    "$ru_gate_file" \
    'case[[:space:]]+\.enabled:(?s:.*?)guard[[:space:]]+remoteConfiguration\.authorizesRUBillingPresentation[[:space:]]*\|\|[[:space:]]*remoteConfiguration\.authorizesRUProviderFallback[[:space:]]+else'

require_pattern \
    "Explicit false remains a RU Billing kill switch" \
    "$ru_gate_file" \
    'case[[:space:]]+\.disabled:[[:space:]]*return[[:space:]]+\.remoteFlagDisabled'

require_pattern \
    "Malformed ru_pay remains fail-closed" \
    "$ru_gate_file" \
    'case[[:space:]]+\.invalid:[[:space:]]*return[[:space:]]+\.remoteFlagInvalid'

require_pattern \
    "Missing ru_pay without a live outage capability remains fail-closed" \
    "$ru_gate_file" \
    'case[[:space:]]+\.absent:(?s:.*?)return[[:space:]]+\.remoteFlagAbsent'

require_pattern \
    "RU Billing accepts a Russian Storefront or Russian iPhone region" \
    "$ru_gate_file" \
    'storefront\?\.isRussian[[:space:]]*==[[:space:]]*true(?s:.*?)\|\|[[:space:]]*deviceContextProvider\.currentContext\(\)\.isRussian'

forbid_pattern \
    "Language never enables RU Billing" \
    '(primaryLanguageIdentifier[[:space:]]*==|primaryLanguageIdentifier\?\.hasPrefix|preferredLanguages)' \
    "$ru_device_context_file" \
    "$platform_root/Sources/BroadRUBilling/Infrastructure/RUBilling/SystemRUBillingDeviceContextProvider.swift"

require_pattern \
    "Checkout method resolution loads Storefront before evaluating the RU gate" \
    "$ru_resolution_file" \
    'storefrontRepository\.currentStorefront\(\)(?s:.*?)gate\.availabilityReason\((?s:.*?)storefront:[[:space:]]*storefront'

require_pattern \
    "Final checkout rechecks the current Storefront" \
    "$ru_checkout_flow_file" \
    'storefrontRepository\.currentStorefront\(\)(?s:.*?)gate\.allows\((?s:.*?)storefront:[[:space:]]*storefront'

require_pattern \
    "Flat backend catalog preserves the response array one-to-one" \
    "$ru_flat_catalog_file" \
    'products:[[:space:]]*response\.products\.map\(makeDomainProduct\)'

forbid_pattern \
    "Flat backend catalog does not sort, deduplicate or truncate products" \
    '\.(sorted|filter|compactMap|prefix)\(|Dictionary\(' \
    "$ru_flat_catalog_file"

require_pattern \
    "RU catalog preserves the backend Special Offer marker" \
    "$ru_catalog_product_file" \
    'public[[:space:]]+let[[:space:]]+isSpecialOffer:[[:space:]]*Bool'

require_pattern \
    "Ordinary RU product matching excludes marked Special Offer rows" \
    "$ru_catalog_matcher_file" \
    '\$0\.kind[[:space:]]*==[[:space:]]*kind[[:space:]]*&&[[:space:]]*!\$0\.isSpecialOffer'

require_pattern \
    "RU Special Offer matching requires the explicit backend marker" \
    "$ru_catalog_matcher_file" \
    '\$0\.isSpecialOffer(?s:.*?)catalogProductID\.rawValue[[:space:]]*==[[:space:]]*requestedID'

require_pattern \
    "RU Billing exposes typed modes for custom-named Debug configurations" \
    "$ru_debug_override_file" \
    'case[[:space:]]+followAdapty(?s:.*?)case[[:space:]]+forceEnabled(?s:.*?)case[[:space:]]+forceDisabled'

require_pattern \
    "RU Billing production store rejects manual overrides by default" \
    "$ru_debug_override_file" \
    'allowsManualOverrides:[[:space:]]*Bool[[:space:]]*=[[:space:]]*false(?s:.*?)mode[[:space:]]*=[[:space:]]*allowsManualOverrides[[:space:]]*\?[[:space:]]*initialMode[[:space:]]*:[[:space:]]*\.followAdapty(?s:.*?)self\.mode[[:space:]]*=[[:space:]]*allowsManualOverrides[[:space:]]*\?[[:space:]]*mode[[:space:]]*:[[:space:]]*\.followAdapty'

require_pattern \
    "RU Billing gate consumes the locked store before the Adapty decision" \
    "$ru_gate_file" \
    'switch[[:space:]]+debugOverrideStore\.currentMode(?s:.*?)case[[:space:]]+\.forceEnabled:(?s:.*?)case[[:space:]]+\.forceDisabled:(?s:.*?)switch[[:space:]]+remoteConfiguration\.ruBillingGateDecision'

require_pattern \
    "RU Billing logs the resolved availability reason without payload data" \
    "$ru_resolution_file" \
    '\.ruBillingAvailabilityEvaluated\([[:space:]]*reason:[[:space:]]*reason\.logValue,[[:space:]]*methodCount:[[:space:]]*methods\.count'

require_pattern \
    "RU Billing composition owns one shared Debug override store" \
    "$ru_composition_models_file" \
    'public[[:space:]]+let[[:space:]]+debugOverrideStore:[[:space:]]*RUBillingDebugOverrideStore'

require_pattern \
    "Method resolution and final checkout recheck share the Debug override" \
    "$ru_composition_factory_file" \
    'let[[:space:]]+gate[[:space:]]*=[[:space:]]*RUBillingGate\((?s:.*?)debugOverrideStore:[[:space:]]*dependencies\.debugOverrideStore(?s:.*?)ResolveCheckoutMethodsUseCase\((?s:.*?)debugOverrideStore:[[:space:]]*dependencies\.debugOverrideStore'
if ((failure_count > 0)); then exit 1; fi
echo "RU configuration contracts passed."
