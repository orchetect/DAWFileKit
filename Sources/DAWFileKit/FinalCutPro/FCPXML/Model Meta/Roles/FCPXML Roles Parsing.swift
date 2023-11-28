//
//  FCPXML Roles Parsing.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

// MARK: - FCPXML Parsing

extension FinalCutPro.FCPXML {
    /// Returns roles explicitly attached to an element.
    /// No default roles are added and no interpolation is performed.
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
                    // asset clip can have `audioRole` and/or `videoRole` attributes.
                    
                    // it can also have roles in `audio-channel-source` children which may or may
                    // not contain a time range. if there is no time range it applies to the entire
                    // clip and overrides the asset clip's `audioRole`.
                    
                    if let rawString = xmlLeaf.attributeStringValue(
                        forName: AssetClip.Attributes.videoRole.rawValue
                    ),
                        let role = VideoRole(rawValue: rawString)
                    {
                        roles.insert(.video(role))
                    }
                    
                    let audioChannelSources = parseAudioChannelSources(from: xmlLeaf, resources: resources)
                    
                    if audioChannelSources.isEmpty {
                        if let rawString = xmlLeaf.attributeStringValue(
                            forName: AssetClip.Attributes.audioRole.rawValue
                        ),
                           let role = AudioRole(rawValue: rawString)
                        {
                            roles.insert(.audio(role))
                        }
                    } else {
                        // TODO: if audio channel source has a time range and it starts later than the clip's start, then do we assume FCP falls back to using the asset clip's audio role? not sure.
                        // TODO: also, what happens when there are multiple audio channel sources that overlap? or all lack a time range. does FCP use the topmost?
                        roles.formUnion(audioChannelSources.asAnyRoles())
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
                        let audioRoleSources = FinalCutPro.FCPXML.parseAudioRoleSources(from: xmlLeaf)
                        let audioRoles = audioRoleSources.asAnyRoles()
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
            roles.formUnion(defaultRoles.audioRoles().map { .defaulted($0) })
        }
        if !roles.containsVideoRoles {
            roles.formUnion(defaultRoles.videoRoles().map { .defaulted($0) })
        }
        if !roles.containsCaptionRoles {
            roles.formUnion(defaultRoles.captionRoles().map { .defaulted($0) })
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
    
    /// Returns known default role(s) that Final Cut Pro uses for a given element type.
    /// If an element does not have a user-assigned role, Final Cut Pro uses
    /// certain defaults that are not written to the FCPXML file so we have to provide them.
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
