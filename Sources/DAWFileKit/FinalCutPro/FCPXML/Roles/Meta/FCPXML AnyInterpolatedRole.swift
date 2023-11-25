//
//  FCPXML AnyInterpolatedRole.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public enum AnyInterpolatedRole: Equatable, Hashable {
        /// Role is a custom role assigned by the user.
        case assigned(AnyRole)
        
        /// Role is a defaulted role.
        case defaulted(AnyRole)
    }
}

extension FinalCutPro.FCPXML.AnyInterpolatedRole {
    public var wrapped: FinalCutPro.FCPXML.AnyRole {
        switch self {
        case let .assigned(role): return role
        case let .defaulted(role): return role
        }
    }
}

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
