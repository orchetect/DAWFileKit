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
        case let .audio(role): "audio(\(role))"
        case let .video(role): "video(\(role))"
        case let .caption(role): "caption(\(role))"
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

// MARK: - Roles Parsing

extension FinalCutPro.FCPXML {
    static func roles(
        of xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        auditionMask: Audition.Mask, // = .activeAudition
        includeDefaultRoles: Bool // = true
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
        
        // insert default roles if needed
        let defaultRoles = defaultRoles(for: elementType)
        if roles.filter(\.isAudio).isEmpty {
            roles.formUnion(defaultRoles.filter(\.isAudio))
        }
        if roles.filter(\.isVideo).isEmpty {
            roles.formUnion(defaultRoles.filter(\.isVideo))
        }
        if roles.filter(\.isCaption).isEmpty {
            roles.formUnion(defaultRoles.filter(\.isCaption))
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
        public var elementRoles: [ElementRoles]
        
        public init(elementRoles: [ElementRoles] = []) {
            self.elementRoles = elementRoles
        }
        
        public struct ElementRoles: Equatable, Hashable {
            public var elementType: ElementType
            public var roles: Set<Role>
            
            public init(elementType: ElementType, roles: Set<Role> = []) {
                self.elementType = elementType
                self.roles = roles
            }
        }
    }
}

extension FinalCutPro.FCPXML.AncestorRoles {
    /// Flattens all ancestor roles to produce a set of effective inherited roles for an element.
    public func flattened() -> Set<FinalCutPro.FCPXML.Role> {
        elementRoles.reduce(into: Set<FinalCutPro.FCPXML.Role>()) { finalRoles, elementRoles in
            let elementAudioRoles = elementRoles.roles.filter(\.isAudio)
            let elementVideoRoles = elementRoles.roles.filter(\.isVideo)
            let elementCaptionRoles = elementRoles.roles.filter(\.isCaption)
            
            // replace audio role(s) with new role(s)
            if !elementAudioRoles.isEmpty {
                finalRoles = finalRoles.filter { !$0.isAudio }
                finalRoles.formUnion(elementAudioRoles)
            }
            
            // replace vide role(s) with new role(s)
            if !elementVideoRoles.isEmpty {
                finalRoles = finalRoles.filter { !$0.isVideo }
                finalRoles.formUnion(elementVideoRoles)
            }
            // replace caption role(s) with new role(s)
            if !elementCaptionRoles.isEmpty {
                finalRoles = finalRoles.filter { !$0.isCaption }
                finalRoles.formUnion(elementCaptionRoles)
            }
        }
    }
}

extension FinalCutPro.FCPXML {
    static func rolesOfElementAndAncestors(
        of xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        auditionMask: Audition.Mask, // = .activeAudition
        includeDefaultRoles: Bool // = true
    ) -> AncestorRoles {
        var ancestorRoles = AncestorRoles()
        
        for breadcrumb in breadcrumbs {
            let bcRoles = roles(
                of: breadcrumb,
                resources: resources,
                auditionMask: auditionMask,
                includeDefaultRoles: includeDefaultRoles
            )
            if !bcRoles.isEmpty, let bcType = ElementType(from: breadcrumb) {
                let elementRoles = AncestorRoles.ElementRoles(elementType: bcType, roles: bcRoles)
                ancestorRoles.elementRoles.append(elementRoles)
            }
        }
        
        return ancestorRoles
    }
}

#endif
