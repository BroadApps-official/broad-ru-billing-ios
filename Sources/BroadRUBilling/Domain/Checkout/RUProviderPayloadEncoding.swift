import Foundation

/// Canonical bytes keep the base value's Equatable contract independent of
/// dictionary insertion order and JSONEncoder's randomized key traversal.
enum RUProviderPayloadEncoding {
    static func encode(_ value: some Encodable) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(value)
    }
}
