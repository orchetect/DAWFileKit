//
//  FCPXML Roles Parsing.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

// MARK: - FCPXML Parsing

extension FinalCutPro.FCPXML {
    static func roles(
        of xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        auditions: Audition.Mask // = .activeAudition
    ) -> Set<AnyRole> {
        guard let elementType = ElementType(from: xmlLeaf) else { return [] }
        
        var roles: Set<AnyRole> = []
        
        switch elementType {
        case let .story(storyElementType):
            switch storyElementType {
            case let .anyAnnotation(annotationType):
                switch annotationType {
                case .caption:
                    if let rawString = xmlLeaf.attributeStringValue(forName: Caption.Attributes.role.rawValue),
                       let role = CaptionRole(rawValue: rawString)
                    {
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
                    
                    if let rawString = xmlLeaf.attributeStringValue(forName: AssetClip.Attributes.audioRole.rawValue),
                       let role = AudioRole(rawValue: rawString)
                    {
                        roles.insert(.audio(role))
                    }
                    if let rawString = xmlLeaf.attributeStringValue(forName: AssetClip.Attributes.videoRole.rawValue),
                       let role = VideoRole(rawValue: rawString)
                    {
                        roles.insert(.video(role))
                    }
                    
                case .audio:
                    if let rawString = xmlLeaf.attributeStringValue(forName: Audio.Attributes.role.rawValue),
                       let role = AudioRole(rawValue: rawString)
                    {
                        roles.insert(.audio(role))
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
                    
                    let useAudioSubroles = xmlLeaf
                        .attributeStringValue(forName: RefClip.Attributes.useAudioSubroles.rawValue) == "1"
                    if useAudioSubroles {
                        let audioRoleSources = FinalCutPro.FCPXML.RefClip.parseAudioRoleSources(from: xmlLeaf)
                        let audioRoles = audioRoleSources.map { $0.role }.compactMap { AnyRole.audio(raw: $0) }
                        roles.formUnion(audioRoles)
                    }
                    
                case .syncClip:
                    // does not have roles itself. contains story elements that may contain their own roles.
                    break
                    
                case .title:
                    if let rawString = xmlLeaf.attributeStringValue(forName: Title.Attributes.role.rawValue),
                       let role = VideoRole(rawValue: rawString)
                    {
                        roles.insert(.video(role))
                    }
                    
                case .video:
                    if let rawString = xmlLeaf.attributeStringValue(forName: Video.Attributes.role.rawValue),
                       let role = VideoRole(rawValue: rawString)
                    {
                        roles.insert(.video(role))
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
        to roles: Set<AnyRole>
    ) -> Set<AnyInterpolatedRole> {
        var roles: Set<AnyInterpolatedRole> = Set(roles.map { .assigned($0) })
        
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
    // Known default roles Final Cut Pro uses.
    // If an element does not have a user-assigned role, Final Cut Pro uses
    // certain defaults.
    // TODO: These are English-only defaults, would be nice to localize them
    static let defaultAudioRole: AnyRole = .audio(raw: "Dialogue")!
    static let defaultVideoRole: AnyRole = .video(raw: "Video")!
    static let titlesRole: AnyRole = .video(raw: "Titles")!
    
    static func defaultRoles(for elementType: ElementType) -> Set<AnyRole> {
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
                    return [titlesRole]
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

#endif
