//
//  FCPXML Role.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
// @_implementationOnly import OTCore

extension FinalCutPro.FCPXML {
    public enum Role: Equatable, Hashable {
        case audio(_ role: String)
        case video(_ role: String)
        case caption(_ role: String)
    }
}

extension FinalCutPro.FCPXML.Role: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .audio(role): return "audio(\(role))"
        case let .video(role): return "video(\(role))"
        case let .caption(role): return "caption(\(role))"
        }
    }
}

extension FinalCutPro.FCPXML.Role {
    /// Unwraps the role and returns the name of the role.
    public var name: String {
        switch self {
        case let .audio(role): return role
        case let .video(role): return role
        case let .caption(role): return role
        }
    }
}

extension FinalCutPro.FCPXML.Role {
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

extension Collection<FinalCutPro.FCPXML.Role> {
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

extension FinalCutPro.FCPXML {
    public enum InterpolatedRole: Equatable, Hashable {
        /// Role is a custom role assigned by the user.
        case assigned(Role)
        
        /// Role is a defaulted role.
        case defaulted(Role)
    }
}

extension FinalCutPro.FCPXML.InterpolatedRole {
    public var wrapped: FinalCutPro.FCPXML.Role {
        switch self {
        case let .assigned(role): return role
        case let .defaulted(role): return role
        }
    }
}

extension Collection<FinalCutPro.FCPXML.InterpolatedRole> {
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

// MARK: - Roles Parsing

extension FinalCutPro.FCPXML {
    static func roles(
        of xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        auditionMask: Audition.Mask // = .activeAudition
    ) -> Set<Role> {
        guard let elementType = ElementType(from: xmlLeaf) else { return [] }
        
        var roles: Set<Role> = []
        
        switch elementType {
        case let .story(storyElementType):
            switch storyElementType {
            case let .anyAnnotation(annotationType):
                switch annotationType {
                case .caption:
                    if let role = xmlLeaf.attributeStringValue(forName: Caption.Attributes.role.rawValue) {
                        roles.insert(.caption(role))
                    }
                    
                case .keyword:
                    break
                    
                case .marker, .chapterMarker:
                    break
                }
                
            case let .anyClip(clipType):
                switch clipType {
                case .assetClip:
                    // TODO: can also contain sub-roles in `audio-channel-source` children
                    if let audioRole = xmlLeaf.attributeStringValue(forName: AssetClip.Attributes.audioRole.rawValue) {
                        roles.insert(.audio(audioRole))
                    }
                    if let videoRole = xmlLeaf.attributeStringValue(forName: AssetClip.Attributes.videoRole.rawValue) {
                        roles.insert(.video(videoRole))
                    }
                    
                case .audio:
                    if let audioRole = xmlLeaf.attributeStringValue(forName: Audio.Attributes.role.rawValue) {
                        roles.insert(.audio(audioRole))
                    }
                    
                case .audition:
                    // contains clip(s) that may have their own roles but they are their own elements
                    // so we won't parse them here
                    break
                    
                case .clip:
                    break
                    
                case .gap:
                    break
                    
                case .liveDrawing:
                    // TODO: has role(s)?
                    break
                    
                case .mcClip:
                    // does not have roles itself. references multicam clip(s).
                    break
                    
                case .refClip:
                    // does not have video role itself. it references a sequence that may contain clips with their own roles.
                    // has audio subroles that are enable-able.
                    
                    let useAudioSubroles = xmlLeaf.attributeStringValue(forName: RefClip.Attributes.useAudioSubroles.rawValue) == "1"
                    if useAudioSubroles {
                        let audioRoleSources = FinalCutPro.FCPXML.RefClip.parseAudioRoleSources(from: xmlLeaf)
                        let audioRoles = audioRoleSources.map { $0.role }.map { Role.audio($0) }
                        roles.formUnion(audioRoles)
                    }
                    
                case .syncClip:
                    // does not have roles itself. contains story elements that may contain their own roles.
                    break
                    
                case .title:
                    if let videoRole = xmlLeaf.attributeStringValue(forName: Title.Attributes.role.rawValue) {
                        roles.insert(.video(videoRole))
                    }
                    
                case .video:
                    if let videoRole = xmlLeaf.attributeStringValue(forName: Video.Attributes.role.rawValue) {
                        roles.insert(.video(videoRole))
                    }
                }
                
            case .sequence:
                break
                
            case .spine:
                break
            }
            
        case .structure(_):
            // structure elements don't have roles
            break
        }
        
        return roles
    }
    
    static func addDefaultRoles(
        for elementType: ElementType,
        to roles: Set<Role>
    ) -> Set<InterpolatedRole> {
        var roles: Set<InterpolatedRole> = Set(roles.map { .assigned($0) })
        
        // insert default roles if needed
        let defaultRoles = defaultRoles(for: elementType)
        if !roles.containsAudioRoles {
            roles.formUnion(defaultRoles.audioRoles.map { .defaulted($0) })
        }
        if !roles.containsVideoRoles {
            roles.formUnion(defaultRoles.videoRoles.map { .defaulted($0) })
        }
        if !roles.containsCaptionRoles {
            roles.formUnion(defaultRoles.captionRoles.map { .defaulted($0) })
        }
        
        return roles
    }
}

// MARK: - Default Roles

extension FinalCutPro.FCPXML {
    static let defaultAudioRole: Role = .audio("Dialogue")
    static let defaultVideoRole: Role = .video("Video")
    
    static func defaultRoles(for elementType: ElementType) -> Set<Role> {
        switch elementType {
        case let .story(storyElementType):
            switch storyElementType {
            case let .anyAnnotation(annotationType):
                switch annotationType {
                case .caption:
                    // captions use their own sets of roles specific for captions/text
                    // and generally they are auto-assigned so there are no defaults to return
                    return []
                case .keyword:
                    return []
                case .marker, .chapterMarker:
                    return []
                }
            case let .anyClip(clipType):
                switch clipType {
                case .assetClip:
                    return [defaultVideoRole]
                case .audio:
                    return [defaultAudioRole]
                case .audition:
                    // contains clip(s) that may have their own roles but they are their own elements
                    // so we won't parse them here
                    return []
                case .clip:
                    // not exactly sure if a default is provided for `clip`.
                    return []
                case .gap:
                    return []
                case .liveDrawing:
                    // TODO: has role(s)?
                    return []
                case .mcClip:
                    // does not have roles itself. references multicam clip(s).
                    return []
                case .refClip:
                    // does not have video role itself. it references a sequence that may contain clips with their own roles.
                    // has audio subroles that are enable-able.
                    return []
                case .syncClip:
                    // does not have roles itself. contains story elements that may contain their own roles.
                    return []
                case .title:
                    return [.video("Titles")]
                case .video:
                    return [defaultVideoRole]
                }
            case .sequence:
                return []
            case .spine:
                return []
            }
        case .structure:
            return []
            // structure elements don't have roles
        }
    }
}

// MARK: - Ancestor Roles

extension FinalCutPro.FCPXML {
    public struct AncestorRoles: Equatable, Hashable {
        public var elements: [ElementRoles]
        
        public init(elements: [ElementRoles] = []) {
            self.elements = elements
        }
        
        public struct ElementRoles: Equatable, Hashable {
            public var elementType: ElementType
            public var roles: Set<InterpolatedRole>
            
            public init(elementType: ElementType, roles: Set<InterpolatedRole> = []) {
                self.elementType = elementType
                self.roles = roles
            }
        }
    }
}

extension FinalCutPro.FCPXML.AncestorRoles {
    /// Flattens all ancestor roles to produce a set of effective inherited roles for an element.
    /// Includes the source of the role inheritance interpolation.
    public func flattenedInterpolatedRoles() -> Set<FinalCutPro.FCPXML.InterpolatedRole> {
        var outputRoles: Set<FinalCutPro.FCPXML.InterpolatedRole> = []
        
        let elementAudioRoles = elements.flatMap { $0.roles.audioRoles }
        if let audioRole = flatten(singleRoleType: elementAudioRoles) {
            outputRoles.insert(audioRole)
        }
        
        let elementVideoRoles = elements.flatMap { $0.roles.videoRoles }
        if let videoRole = flatten(singleRoleType: elementVideoRoles) {
            outputRoles.insert(videoRole)
        }
        
        let elementCaptionRoles = elements.flatMap { $0.roles.captionRoles }
        if let captionRole = flatten(singleRoleType: elementCaptionRoles) {
            outputRoles.insert(captionRole)
        }
        
        return outputRoles
    }
    
    /// Flattens all ancestor roles to produce a set of effective inherited roles for an element.
    public func flattenedRoles() -> Set<FinalCutPro.FCPXML.Role> {
        Set(flattenedInterpolatedRoles().map(\.wrapped))
    }
    
    /// Only supply a collection containing roles of the same type, ie: only `.audio()` roles.
    /// This favors assigned roles and prevents defaulted roles from overriding them.
    func flatten(singleRoleType roles: [FinalCutPro.FCPXML.InterpolatedRole]) -> FinalCutPro.FCPXML.InterpolatedRole? {
        var effectiveRole: FinalCutPro.FCPXML.InterpolatedRole?
        var foundAssigned: Bool = false
        
        for role in roles {
            switch role {
            case .assigned:
                effectiveRole = role
                foundAssigned = true
            case .defaulted:
                if !foundAssigned { effectiveRole = role }
            }
        }
        
        return effectiveRole
    }
}

extension FinalCutPro.FCPXML {
    static func inheritedRoles(
        of xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        auditionMask: Audition.Mask // = .activeAudition
    ) -> AncestorRoles {
        var ancestorRoles = AncestorRoles()
        
        for breadcrumb in breadcrumbs + [xmlLeaf] {
            let bcRoles = roles(
                of: breadcrumb,
                resources: resources,
                auditionMask: auditionMask
            )
            guard let bcType = ElementType(from: breadcrumb) else { continue }
            let defaultedRoles = addDefaultRoles(for: bcType, to: bcRoles)
            if !defaultedRoles.isEmpty {
                let elementRoles = AncestorRoles.ElementRoles(elementType: bcType, roles: defaultedRoles)
                ancestorRoles.elements.append(elementRoles)
            }
        }
        
        return ancestorRoles
    }
}

#endif
