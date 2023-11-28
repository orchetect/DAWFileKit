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
    ) -> [AnyRole] {
        guard let elementType = ElementType(from: xmlLeaf) else { return [] }
        
        var roles: [AnyRole] = []
        
        switch elementType {
        case let .story(storyElementType):
            switch storyElementType {
            case let .anyAnnotation(annotationType):
                switch annotationType {
                case .caption:
                    if let rawString = xmlLeaf.attributeStringValue(forName: Caption.Attributes.role.rawValue),
                       let role = CaptionRole(rawValue: rawString)
                    {
                        roles.append(.caption(role))
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
                        roles.append(.video(role))
                    }
                    
                    let audioChannelSources = parseAudioChannelSources(from: xmlLeaf, resources: resources)
                        .filter(\.active)
                    
                    if audioChannelSources.isEmpty {
                        if let rawString = xmlLeaf.attributeStringValue(
                            forName: AssetClip.Attributes.audioRole.rawValue
                        ),
                           let role = AudioRole(rawValue: rawString)
                        {
                            roles.append(.audio(role))
                        }
                    } else {
                        // TODO: if audio channel source has a time range and it starts later than the clip's start, then do we assume FCP falls back to using the asset clip's audio role? not sure.
                        // TODO: also, what happens when there are multiple audio channel sources that overlap? or all lack a time range. does FCP use the topmost?
                        roles.append(contentsOf: audioChannelSources.asAnyRoles())
                    }
                    
                case .audio:
                    if let rawString = xmlLeaf.attributeStringValue(forName: Audio.Attributes.role.rawValue),
                       let role = AudioRole(rawValue: rawString)
                    {
                        roles.append(.audio(role))
                    }
                    
                case .audition:
                    // contains clip(s) that may have their own roles but they are their own elements
                    // so we won't parse them here
                    break
                    
                case .clip:
                    let childRoles = rolesForNearestDescendant(of: xmlLeaf, resources: resources, auditions: auditions)
                    roles.append(contentsOf: childRoles)
                    
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
                            .filter(\.active)
                        let audioRoles = audioRoleSources.asAnyRoles()
                        roles.append(contentsOf: audioRoles)
                    }
                    
                case .syncClip:
                    // sync clip does not have video/audio roles itself.
                    
                    // instead, we derive the video role from the sync clip's first video media.
                    // we'll also add any audio roles found in case sync sources are missing and
                    // audio roles can't be derived from them.
                    let childRoles = rolesForNearestDescendant(of: xmlLeaf, resources: resources, auditions: auditions)
                    roles.append(contentsOf: childRoles)
                    
                    // the audio role may be present in a `sync-source` child of the sync clip.
                    let syncSources = FinalCutPro.FCPXML.parseSyncSources(from: xmlLeaf)
                    if !syncSources.isEmpty {
                        let audioRoleSources = syncSources.flatMap(\.audioRoleSources)
                            .filter(\.active)
                        let audioRoles = audioRoleSources.map(\.role).asAnyRoles()
                        roles.append(contentsOf: audioRoles)
                    }
                case .title:
                    if let rawString = xmlLeaf.attributeStringValue(forName: Title.Attributes.role.rawValue),
                       let role = VideoRole(rawValue: rawString)
                    {
                        roles.append(.video(role))
                    }
                    
                case .video:
                    if let rawString = xmlLeaf.attributeStringValue(forName: Video.Attributes.role.rawValue),
                       let role = VideoRole(rawValue: rawString)
                    {
                        roles.append(.video(role))
                    }
                }
                
            case .sequence:
                break
                
            case .spine:
                break
            }
            
        case .structure:
            // structure elements don't have roles
            break
        }
        
        return roles
    }
    
    /// Attempting to extract assigned roles for the first child clip found.
    static func rolesForNearestDescendant(
        of xmlLeaf: XMLElement,
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        auditions: Audition.Mask // = .activeAudition
    ) -> [AnyRole] {
        let contents = FinalCutPro.FCPXML.storyXMLElements(in: xmlLeaf)
        
        guard let firstChild = contents.first else { return [] }
        
        let childRoles = Self.roles(of: firstChild, resources: resources, auditions: auditions)
        
        return childRoles
    }
    
    static func addDefaultRoles(
        for elementType: ElementType,
        to roles: [AnyRole]
    ) -> [AnyInterpolatedRole] {
        var roles: [AnyInterpolatedRole] = roles.map { .assigned($0) }
        
        // add default roles if needed
        let defaultRoles = defaultRoles(for: elementType)
        if !roles.containsAudioRoles {
            roles.append(contentsOf: defaultRoles.audioRoles().map { .defaulted($0) })
        }
        if !roles.containsVideoRoles {
            roles.append(contentsOf: defaultRoles.videoRoles().map { .defaulted($0) })
        }
        if !roles.containsCaptionRoles {
            roles.append(contentsOf: defaultRoles.captionRoles().map { .defaulted($0) })
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
    static func defaultRoles(for elementType: ElementType) -> [AnyRole] {
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
                    // not exactly sure if a default is provided for `clip` itself.
                    return [defaultVideoRole]
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
                    return [defaultVideoRole]
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
    
    /// Attempting to extract default roles for the first child clip found.
    static func defaultRolesForNearestDescendant(
        of xmlLeaf: XMLElement
    ) -> [AnyRole] {
        let contents = FinalCutPro.FCPXML.storyXMLElements(in: xmlLeaf)
        
        guard let firstChild = contents.first else { return [] }
        
        guard let elementType = ElementType(from: firstChild) else { return [] }
        
        return defaultRoles(for: elementType)
    }
}

#endif
