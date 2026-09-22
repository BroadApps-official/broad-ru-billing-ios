import BroadMonetization
import BroadRUBilling
import BroadUIFlows
import SwiftUI

/// RU UI is installed only by an app target that depends on BroadRUBillingUI.
@MainActor
public struct BroadRUPaywallView: View {
    private let viewModel: PaywallViewModel
    private let configuration: BroadRUBillingPresentationConfiguration
    private let theme: BroadPaywallTheme
    private let formatter: BroadPaywallProductFormatter
    private let receiptEmailStore: (any BroadReceiptEmailStoreProtocol)?
    private let onClose: @MainActor () -> Void
    private let onCompleted: @MainActor (BroadPaywallCompletion) -> Void
    public init(
        viewModel: PaywallViewModel,
        configuration: BroadRUBillingPresentationConfiguration,
        theme: BroadPaywallTheme? = nil,
        productFormatter: BroadPaywallProductFormatter = .init(),
        receiptEmailStore: (any BroadReceiptEmailStoreProtocol)? = nil,
        onClose: @escaping @MainActor () -> Void,
        onCompleted: @escaping @MainActor (BroadPaywallCompletion) -> Void
    ) {
        self.viewModel = viewModel
        self.configuration = configuration
        self.theme = theme ?? .standard
        formatter = productFormatter
        self.receiptEmailStore = receiptEmailStore
        self.onClose = onClose
        self.onCompleted = onCompleted
    }

    public var body: some View {
        BroadPaywallView(viewModel: viewModel, theme: theme, productFormatter: formatter, checkoutContent: { model in
            AnyView(Group {
                if let product = model.selectedProduct {
                    BroadPaymentMethodSheet(
                        methods: model.checkoutMethods,
                        product: product,
                        ruProduct: model.checkoutResolution?.ruProduct,
                        copy: model.configuration.copy,
                        ruConfiguration: configuration,
                        theme: theme,
                        receiptEmailStore: receiptEmailStore,
                        onSubmit: model.submitCheckoutMethod,
                        onCancel: model.cancelCheckoutMethodSelection
                    )
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                }
            })
        }, onClose: onClose, onCompleted: onCompleted)
    }
}

public extension BroadPaywallCopy.Checkout {
    init(title: String, appleTitle: String, sbpTitle: String, cardTitle: String) {
        self.init(title: title, appleTitle: appleTitle, methodTitles: [.sbp: sbpTitle, .card: cardTitle])
    }
}

public extension BroadSupportEmailGreeting {
    static let ruBilling = Self(providerMarker: "ukassa")
}
