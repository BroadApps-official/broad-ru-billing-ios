import BroadMonetization

public struct RUCustomerAccessRecoverySnapshot: Equatable, Sendable {
    public let customer: CustomerAccessRecoverySnapshot
    public let ruSubscription: CustomerAccessRecoveryComponent<RUSubscriptionManagementStatus>
}

public struct RecoverRUCustomerAccessUseCase: Sendable {
    private let subject: EntitlementSubject
    private let recoverCustomer: any RecoverCustomerAccessUseCaseProtocol
    private let loadRUSubscription: (any LoadRUSubscriptionStatusUseCaseProtocol)?
    public init(
        subject: EntitlementSubject,
        recoverCustomer: any RecoverCustomerAccessUseCaseProtocol,
        loadRUSubscription: any LoadRUSubscriptionStatusUseCaseProtocol
    ) {
        self.subject = subject
        self.recoverCustomer = recoverCustomer
        self.loadRUSubscription = loadRUSubscription
    }

    public func callAsFunction() async -> RUCustomerAccessRecoverySnapshot {
        async let customer = recoverCustomer()
        async let subscription = recoverRUSubscription()
        return await RUCustomerAccessRecoverySnapshot(customer: customer, ruSubscription: subscription)
    }

    private var hasStableAccount: Bool {
        subject != .anonymous
    }

    func recoverRUSubscription()
        async -> CustomerAccessRecoveryComponent<RUSubscriptionManagementStatus> {
        guard let loadRUSubscription else {
            return .notConfigured
        }
        guard hasStableAccount else {
            return .authenticationRequired
        }

        switch await loadRUSubscription() {
        case let .loaded(status):
            return .restored(status)
        case let .unavailable(error):
            return .unavailable(error)
        }
    }
}
