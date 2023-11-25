//
//  FCPXML AnyRole.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    public enum AnyRole: Equatable, Hashable {
        /// An audio role.
        case audio(_ role: AudioRole)
        
        /// A video role.
        case video(_ role: VideoRole)
        
        /// A closed caption role.
        case caption(_ role: CaptionRole)
    }
}

// MARK: - Static Constructors

extension FinalCutPro.FCPXML.AnyRole {
    /// An audio role.
    public static func audio(raw: String) -> Self? {
        guard let role = FinalCutPro.FCPXML.AudioRole(rawValue: raw) else { return nil }
        return .audio(role)
    }
    
    /// A video role.
    public static func video(raw: String) -> Self? {
        guard let role = FinalCutPro.FCPXML.VideoRole(rawValue: raw) else { return nil }
        return .video(role)
    }
    
    /// A closed caption role.
    public static func caption(raw: String) -> Self? {
        guard let role = FinalCutPro.FCPXML.CaptionRole(rawValue: raw) else { return nil }
        return .caption(role)
    }
}

extension FinalCutPro.FCPXML.AnyRole: FCPXMLRole {
    public var roleType: FinalCutPro.FCPXML.RoleType { wrapped.roleType }
    
    /// Redundant, but required to fulfill `FCPXMLRole` protocol requirements.
    public func asAnyRole() -> FinalCutPro.FCPXML.AnyRole { self }
}

extension FinalCutPro.FCPXML.AnyRole: RawRepresentable {
    public var rawValue: String {
        switch self {
        case let .audio(role): return role.rawValue
        case let .video(role): return role.rawValue
        case let .caption(role): return role.rawValue
        }
    }
    
    public init?(rawValue: String) {
        // TODO: not ideal
        // to satisfy FCPXMLRole's RawRepresentable requirement we need this init
        // but we can't derive whether the role is audio or video from a raw string,
        // so we have to default to one of them.
        
        if let videoOrAudioRole = FinalCutPro.FCPXML.VideoRole(rawValue: rawValue) {
            self = .video(videoOrAudioRole)
            return
        }
        
        if let captionRole =  FinalCutPro.FCPXML.CaptionRole(rawValue: rawValue) {
            self = .caption(captionRole)
            return
        }
        
        return nil
    }
}

// MARK: - Proxy Properties

extension FinalCutPro.FCPXML.AnyRole {
    /// Returns the unwrapped role typed as ``FCPXMLRole``.
    public var wrapped: any FCPXMLRole {
        switch self {
        case let .audio(role): return role
        case let .video(role): return role
        case let .caption(role): return role
        }
    }
    
    public var role: String {
        switch self {
        case let .audio(role): return role.role
        case let .video(role): return role.role
        case let .caption(role): return role.role
        }
    }
    
    public var subRole: String? {
        switch self {
        case let .audio(role): return role.subRole
        case let .video(role): return role.subRole
        case .caption(_): return nil
        }
    }
}

extension FinalCutPro.FCPXML.AnyRole: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .audio(role): return role.debugDescription
        case let .video(role): return role.debugDescription
        case let .caption(role): return role.debugDescription
        }
    }
}

// MARK: - Metadata

extension FinalCutPro.FCPXML.AnyRole {
    public var isAudio: Bool {
        guard case .audio(_) = self else { return false }
        return true
    }
    
    public var isVideo: Bool {
        guard case .video(_) = self else { return false }
        return true
    }
    
    public var isCaption: Bool {
        guard case .caption(_) = self else { return false }
        return true
    }
}

// MARK: - Collection Methods

extension Collection<FinalCutPro.FCPXML.AnyRole> {
    public var containsAudioRoles: Bool {
        contains(where: { $0.isAudio })
    }
    
    public var containsVideoRoles: Bool {
        contains(where: { $0.isVideo })
    }
    
    public var containsCaptionRoles: Bool {
        contains(where: { $0.isCaption })
    }
    
    public var audioRoles: Set<Element> {
        Set(filter(\.isAudio))
    }
    
    public var videoRoles: Set<Element> {
        Set(filter(\.isVideo))
    }
    
    public var captionRoles: Set<Element> {
        Set(filter(\.isCaption))
    }
}

#endif
