//
//  OpenEnumCompatibility.swift
//  TootSDK
//
//  Compatibility extensions to allow comparing OpenEnum values with plain enum cases.
//  Added for Orbit iOS app compatibility.
//

import Foundation

// MARK: - OpenEnum Equality with Wrapped

extension OpenEnum where Wrapped: Equatable {
    /// Allows comparing OpenEnum directly with a wrapped value
    public static func == (lhs: OpenEnum<Wrapped>, rhs: Wrapped) -> Bool {
        return lhs.value == rhs
    }

    public static func == (lhs: Wrapped, rhs: OpenEnum<Wrapped>) -> Bool {
        return lhs == rhs.value
    }

    public static func != (lhs: OpenEnum<Wrapped>, rhs: Wrapped) -> Bool {
        return lhs.value != rhs
    }

    public static func != (lhs: Wrapped, rhs: OpenEnum<Wrapped>) -> Bool {
        return lhs != rhs.value
    }
}

// MARK: - Optional OpenEnum Equality with Wrapped

extension Optional where Wrapped: Equatable {
    /// Allows comparing Optional<OpenEnum<T>> with T directly
    public static func == <T>(lhs: OpenEnum<T>?, rhs: T) -> Bool where Wrapped == OpenEnum<T>, T: Equatable {
        return lhs?.value == rhs
    }

    public static func == <T>(lhs: T, rhs: OpenEnum<T>?) -> Bool where Wrapped == OpenEnum<T>, T: Equatable {
        return lhs == rhs?.value
    }

    public static func != <T>(lhs: OpenEnum<T>?, rhs: T) -> Bool where Wrapped == OpenEnum<T>, T: Equatable {
        return lhs?.value != rhs
    }

    public static func != <T>(lhs: T, rhs: OpenEnum<T>?) -> Bool where Wrapped == OpenEnum<T>, T: Equatable {
        return lhs != rhs?.value
    }
}

// MARK: - ExpressibleByEnumLiteral for OpenEnum

extension OpenEnum: ExpressibleByUnicodeScalarLiteral where Wrapped: ExpressibleByUnicodeScalarLiteral, Wrapped.RawValue == String {
    public init(unicodeScalarLiteral value: Wrapped.UnicodeScalarLiteralType) {
        self = .some(Wrapped(unicodeScalarLiteral: value))
    }
}

extension OpenEnum: ExpressibleByExtendedGraphemeClusterLiteral where Wrapped: ExpressibleByExtendedGraphemeClusterLiteral, Wrapped.RawValue == String {
    public init(extendedGraphemeClusterLiteral value: Wrapped.ExtendedGraphemeClusterLiteralType) {
        self = .some(Wrapped(extendedGraphemeClusterLiteral: value))
    }
}

extension OpenEnum: ExpressibleByStringLiteral where Wrapped: ExpressibleByStringLiteral, Wrapped.RawValue == String {
    public init(stringLiteral value: Wrapped.StringLiteralType) {
        self = .some(Wrapped(stringLiteral: value))
    }
}
