# Changelog

## 1.0.2

### Changed — что изменилось и почему

- `BroadRUBillingUI` принимает BroadUIFlows 5.x, 6.x и 7.x (`5.0.0..<8.0.0`).
  UIFlows 7.0.0 меняет только `BroadSettingsHost` (обязательный `showPaywall`), а
  используемые здесь тема, кнопки, тексты, форматирование цены и paywall не
  изменились. Без этого набор с UIFlows 7.0.0 не собирался вместе с RU Billing. Код
  модуля не менялся.
- Gate exports a UTF-8 locale before invoking Ruby so checks work in checkout
  paths containing Cyrillic characters, even when the caller uses the C locale.

## 1.0.1

### Changed — что изменилось и почему

- `BroadRUBillingUI` принимает BroadUIFlows 5.x и 6.x (`5.0.0..<7.0.0`). UIFlows 6.0.0
  меняет только порядок показа подписок; используемые здесь тема, кнопки, тексты,
  форматирование цены и paywall не изменились. Без этого набор с UIFlows 6.0.0 не
  собирался вместе с RU Billing. Код модуля не менялся.

## 1.0.0

### Added — что изменилось и почему

- Extracted RU billing and UI from BroadMonetization/BroadUIFlows into optional
  `BroadRUBilling` and `BroadRUBillingUI` products. Base dependencies contain no RU implementation.
- Explicit provider parsing, loader, checkout and view-reporting composition; shared
  operation gate, authorization binding and server-authoritative entitlement refresh.
- Existing pending storage, row fingerprints and wire values remain compatible.
  Account-policy bounded waiting and late-payment reconciliation are preserved.
- Dedicated fixture gallery, contract probes, API reports and migration instructions.
