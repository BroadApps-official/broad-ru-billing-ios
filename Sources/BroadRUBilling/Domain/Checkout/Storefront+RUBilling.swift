import BroadMonetization

public extension Storefront {
    /// A Russian App Store storefront is one of the two positive regional
    /// signals accepted by the RU billing gate.
    var isRussian: Bool {
        countryCode == "RU" || countryCode == "RUS"
    }
}
