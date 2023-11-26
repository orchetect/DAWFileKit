//
//  FCPXML AnyInterpolatedRole.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public enum AnyInterpolatedRole: Equatable, Hashable {
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
    /// Returns `true` if the interpolated case is ``assigned``.
    public var isAssigned: Bool {
        guard case .assigned = self else { return false }
        return true
    }
    
    /// Returns `true` if the interpolated case is ``defaulted``.
    public var isDefaulted: Bool {
        guard case .defaulted = self else { return false }
        return true
    }
    
    /// Returns `true` if the interpolated case is ``inherited``.
    public var isInherited: Bool {
        guard case .inherited = self else { return false }
        return true
    }
}

// MARK: - Collection Methods


extension Collection<FinalCutPro.FCPXML.AnyInterpolatedRole> {
    public var containsAudioRoles: Bool {
        contains(where: { $0.wrapped.isAudio })
    }
    
    public var containsVideoRoles: Bool {
        contains(where: { $0.wrapped.isVideo })
    }
    
    public var containsCaptionRoles: Bool {
        contains(where: { $0.wrapped.isCaption })
    }
    
    public var audioRoles: [Element] {
        filter { $0.wrapped.isAudio }
    }
    
    public var videoRoles: [Element] {
        filter { $0.wrapped.isVideo }
    }
    
    public var captionRoles: [Element] {
        filter { $0.wrapped.isCaption }
    }
}

#endif
