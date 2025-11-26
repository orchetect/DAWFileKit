//
//  FCPXML AnyInterpolatedRole.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Type-erased box containing a specialized interpolated role instance.
    public enum AnyInterpolatedRole: Equatable, Hashable, Sendable {
        /// Element's role is a custom role assigned by the user.
        case assigned(AnyRole)
        
        /// Element's role is a defaulted role and no role is assigned either to the element or any
        /// of its ancestors.
        case defaulted(AnyRole)
        
        /// Role is not assigned to the element, but is inherited from an ancestor whose role was
        /// assigned by the user.
        case inherited(AnyRole)
    }
}

extension FinalCutPro.FCPXML.AnyInterpolatedRole: FCPXMLRole {
    public var roleType: FinalCutPro.FCPXML.RoleType {
        wrapped.roleType
    }
    
    public func asAnyRole() -> FinalCutPro.FCPXML.AnyRole {
        wrapped.asAnyRole()
    }
    
    public func lowercased(derivedOnly: Bool) -> Self {
        let anyRole = wrapped.lowercased(derivedOnly: derivedOnly)
        return rewrap(newRole: anyRole)
    }
    
    public func titleCased(derivedOnly: Bool) -> Self {
        let anyRole = wrapped.titleCased(derivedOnly: derivedOnly)
        return rewrap(newRole: anyRole)
    }
    
    public func titleCasedDefaultRole(derivedOnly: Bool) -> Self {
        let anyRole = wrapped.titleCasedDefaultRole(derivedOnly: derivedOnly)
        return rewrap(newRole: anyRole)
    }
    
    public var isMainRoleBuiltIn: Bool {
        wrapped.isMainRoleBuiltIn
    }
    
    public init?(rawValue: String) {
        guard let anyRole = FinalCutPro.FCPXML.AnyRole(rawValue: rawValue)
        else { return nil }
        
        // TODO: assigned case is best default case, but not ideal
        self = .assigned(anyRole)
    }
    
    public var rawValue: String {
        wrapped.rawValue
    }
}

extension FinalCutPro.FCPXML.AnyInterpolatedRole {
    public func collapsingSubRole() -> Self {
        let anyRole = wrapped.collapsingSubRole()
        return rewrap(newRole: anyRole)
    }
}

extension FinalCutPro.FCPXML.AnyInterpolatedRole {
    public var wrapped: FinalCutPro.FCPXML.AnyRole {
        switch self {
        case let .assigned(role): return role
        case let .defaulted(role): return role
        case let .inherited(role): return role
        }
    }
}

extension FinalCutPro.FCPXML.AnyInterpolatedRole {
    /// Returns `true` if the interpolated case is ``FinalCutPro/FCPXML/AnyInterpolatedRole/assigned(_:)``.
    public var isAssigned: Bool {
        guard case .assigned = self else { return false }
        return true
    }
    
    /// Returns `true` if the interpolated case is ``FinalCutPro/FCPXML/AnyInterpolatedRole/defaulted(_:)``.
    public var isDefaulted: Bool {
        guard case .defaulted = self else { return false }
        return true
    }
    
    /// Returns `true` if the interpolated case is ``FinalCutPro/FCPXML/AnyInterpolatedRole/inherited(_:)``.
    public var isInherited: Bool {
        guard case .inherited = self else { return false }
        return true
    }
}

extension FinalCutPro.FCPXML.AnyInterpolatedRole: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .assigned(role): return "assigned(\(role.debugDescription))"
        case let .defaulted(role): return "defaulted(\(role.debugDescription))"
        case let .inherited(role): return "inherited(\(role.debugDescription))"
        }
    }
}

// MARK: - Helpers

extension FinalCutPro.FCPXML.AnyInterpolatedRole {
    fileprivate func rewrap(newRole: FinalCutPro.FCPXML.AnyRole) -> Self {
        switch self {
        case .assigned: return .assigned(newRole)
        case .defaulted: return .defaulted(newRole)
        case .inherited: return .inherited(newRole)
        }
    }
}

#endif
