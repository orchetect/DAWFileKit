//
//  FCPXML AnyInterpolatedRole.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
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

// MARK: - Sequence Methods

extension Sequence<FinalCutPro.FCPXML.AnyInterpolatedRole> {
    public var containsAudioRoles: Bool {
        contains(where: { $0.wrapped.isAudio })
    }
    
    public var containsVideoRoles: Bool {
        contains(where: { $0.wrapped.isVideo })
    }
    
    public var containsCaptionRoles: Bool {
        contains(where: { $0.wrapped.isCaption })
    }
}

extension Sequence<FinalCutPro.FCPXML.AnyInterpolatedRole> {
    /// Returns the sequence sorted by role type: video, then audio, then caption.
    /// Role order is otherwise maintained and roles are not sorted alphabetically.
    public func sortedByType() -> [Element] {
        filter(\.wrapped.isVideo)
            + filter(\.wrapped.isAudio)
            + filter(\.wrapped.isCaption)
    }
}

// MARK: - Filtering

extension Sequence<FinalCutPro.FCPXML.AnyInterpolatedRole> {
    public func audioRoles() -> [Element] {
        filter { $0.wrapped.isAudio }
    }
    
    public func videoRoles() -> [Element] {
        filter { $0.wrapped.isVideo }
    }
    
    public func captionRoles() -> [Element] {
        filter { $0.wrapped.isCaption }
    }
}

#endif
