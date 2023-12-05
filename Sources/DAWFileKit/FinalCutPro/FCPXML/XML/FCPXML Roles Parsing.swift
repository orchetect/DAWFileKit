//
//  FCPXML Roles Parsing.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore

// MARK: - FCPXML Parsing

extension XMLElement {
    /// FCPXML: Returns local roles for an element.
    /// These roles are either attached to the element itself or in some cases are acquired from the
    /// element's contents (in the case of `mc-clip`s, for example). These are never inherited from
    /// ancestors. No default roles are added and no interpolation is performed.
    func localRoles(
        resources: XMLElement?,
        auditions: FinalCutPro.FCPXML.Audition.Mask // = .activeAudition
    ) -> [FinalCutPro.FCPXML.AnyInterpolatedRole] {
        guard let elementType = fcpElementType else { return [] }
        
        var localRoles: [(role: FinalCutPro.FCPXML.AnyRole, isInherited: Bool)] = []
        
        func add(role: FinalCutPro.FCPXML.AnyRole, isInherited: Bool) {
            localRoles.append((role: role, isInherited: isInherited))
        }
        
        func add(roles: [FinalCutPro.FCPXML.AnyRole], isInherited: Bool) {
            for role in roles {
                add(role: role, isInherited: isInherited)
            }
        }
        
        switch elementType {
        case let .story(storyElementType):
            switch storyElementType {
            case let .annotation(annotationType):
                switch annotationType {
                case .caption:
                    if let role = fcpRole(as: FinalCutPro.FCPXML.CaptionRole.self) {
                        add(role: .caption(role), isInherited: false)
                    }
                    
                case .keyword:
                    // keywords do not contain roles, they inherit them from their parent
                    break
                    
                case .marker:
                    // markers do not contain roles, they inherit them from their parent
                    break
                }
                
            case let .clip(clipType):
                switch clipType {
                case .assetClip:
                    // asset clip can have `audioRole` and/or `videoRole` attributes.
                    
                    let assetClip = fcpAsAssetClip
                    
                    // it can also have roles in `audio-channel-source` children which may or may
                    // not contain a time range. if there is no time range it applies to the entire
                    // clip and overrides the asset clip's `audioRole`.
                    
                    if let role = assetClip.videoRole {
                        add(role: .video(role), isInherited: false)
                    }
                    
                    let audioChannelSources = assetClip.audioChannelSources
                        .map(\.fcpAsAudioChannelSource)
                        .filter(\.active)
                    
                    if audioChannelSources.isEmpty {
                        if let role = fcpAudioRole {
                            add(role: .audio(role), isInherited: false)
                        }
                    } else {
                        // TODO: if audio channel source has a time range and it starts later than the clip's start, then do we assume FCP falls back to using the asset clip's audio role? not sure.
                        // TODO: also, what happens when there are multiple audio channel sources that overlap? or all lack a time range. does FCP use the topmost?
                        add(roles: audioChannelSources.asAnyRoles(), isInherited: false)
                    }
                    
                case .audio:
                    let audio = fcpAsAudio
                    if let role = audio.role {
                        add(role: .audio(role), isInherited: false)
                    }
                    
                case .audition:
                    // contains clip(s) that may have their own roles but they are their own elements
                    // so we won't parse them here
                    break
                    
                case .clip:
                    // does not have roles itself.
                    // instead, it inherits from its contents.
                    
                    let childRoles = rolesForNearestDescendant(
                        resources: resources,
                        auditions: auditions,
                        firstGenerationOnly: true,
                        firstElementEachGenerationOnly: false
                    )
                    add(roles: childRoles, isInherited: true)
                    
                case .gap:
                    break
                    
                case .liveDrawing:
                    // TODO: has role(s)?
                    break
                    
                case .mcClip:
                    // does not have roles itself.
                    // instead, it inherits from the selected angles in `mc-source` child element(s).
                    // - references a `media` resource containing a `multicam` container.
                    //   - the `multicam` container contains one or more `angle`s.
                    //   - each `angle` is similar to a `sequence` of story elements.
                    // - uses either:
                    //   - a single `mc-source` for video and audio source (srcEnable="all"), or
                    //   - two `mc-source`: one for video (srcEnable="video"), one for audio (srcEnable="audio")
                    //   - srcEnable="none" may be present for some sources.
                    // - the `mc-clip` inherits video role from the video angle's contents
                    // - the `mc-clip` inherits audio role from the audio angle's contents
                    
                    // get multicam sources for `mc-clip`
                    
                    let mcClip = fcpAsMCClip
                    
                    let sources = mcClip.sources
                    guard !sources.isEmpty else { break }
                    
                    // parse media angles
                    
                    let ref = mcClip.ref
                    
                    guard let multicam = fcpResource(forID: ref, in: resources)?
                        .fcpAsMedia
                        .multicam?
                        .fcpAsMulticam
                    else { break }
                    
                    // fetch angles being used
                    
                    let (xmlAudioAngle, xmlVideoAngle) = multicam.audioVideoMCAngles(forMulticamSources: sources)
                    
                    // use role from first story element within each angle
                    
                    if let angle = xmlAudioAngle {
                        let roles = angle.rolesForNearestDescendant(
                            resources: resources,
                            auditions: auditions,
                            firstGenerationOnly: true,
                            firstElementEachGenerationOnly: false
                        )
                        .audioRoles()
                        .map { $0.asAnyRole() }
                        
                        add(roles: roles, isInherited: true)
                    }
                    
                    if let angle = xmlVideoAngle {
                        let roles = angle.rolesForNearestDescendant(
                            resources: resources,
                            auditions: auditions,
                            firstGenerationOnly: true,
                            firstElementEachGenerationOnly: false
                        )
                        .videoRoles()
                        .map { $0.asAnyRole() }
                        
                        add(roles: roles, isInherited: true)
                    }
                    
                case .refClip:
                    // does not have video role itself. it references a sequence that may contain
                    // clips with their own roles.
                    // has audio subroles that are enable-able.
                    
                    let refClip = fcpAsRefClip
                    
                    if refClip.useAudioSubroles {
                        let audioRoleSources = refClip.audioRoleSources
                            .map(\.fcpAsAudioRoleSource)
                            .filter(\.active)
                        let audioRoles = audioRoleSources.asAnyRoles()
                        add(roles: audioRoles, isInherited: false)
                    }
                    
                case .syncClip:
                    // sync clip does not have video/audio roles itself.
                    
                    let syncClip = fcpAsSyncClip
                    
                    // instead, we derive the video role from the sync clip's first video media.
                    // we'll also add any audio roles found in case sync sources are missing and
                    // audio roles can't be derived from them.
                    let childRoles = rolesForNearestDescendant(
                        resources: resources,
                        auditions: auditions,
                        firstGenerationOnly: true,
                        firstElementEachGenerationOnly: true
                    )
                    add(roles: childRoles, isInherited: true)
                    
                    // the audio role may be present in a `sync-source` child of the sync clip.
                    let syncSources = syncClip
                        .syncSources
                        .map(\.fcpAsSyncSource)
                    
                    if !syncSources.isEmpty {
                        let audioRoleSources = syncSources
                            .flatMap(\.audioRoleSources)
                            .map(\.fcpAsAudioRoleSource)
                            .filter(\.active)
                        let audioRoles = audioRoleSources
                            .compactMap(\.role)
                            .asAnyRoles()
                        add(roles: audioRoles, isInherited: true)
                    }
                case .title:
                    let title = fcpAsTitle
                    if let role = title.role {
                        add(role: .video(role), isInherited: false)
                    }
                    
                case .video:
                    let video = fcpAsVideo
                    if let role = video.role {
                        add(role: .video(role), isInherited: false)
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
            
        case .resources:
            // N/A
            return []
            
        case .resource(_):
            // N/A
            return []
        }
        
        let mappedRoles: [FinalCutPro.FCPXML.AnyInterpolatedRole] = localRoles.map {
            $0.isInherited
                ? .inherited($0.role)
                : .assigned($0.role)
        }
        
        return mappedRoles
    }
}

extension XMLElement {
    /// FCPXML: Attempts to extract assigned roles for the first child clip found.
    func rolesForNearestDescendant(
        resources: XMLElement?,
        auditions: FinalCutPro.FCPXML.Audition.Mask, // = .activeAudition
        firstGenerationOnly: Bool,
        firstElementEachGenerationOnly: Bool
    ) -> [FinalCutPro.FCPXML.AnyRole] {
        let storyElements = fcpStoryElements
        
        let elements: AnySequence = firstElementEachGenerationOnly
            ? storyElements.prefix(1).asAnySequence
            : storyElements.asAnySequence
        
        for storyElement in elements {
            let roles = storyElement.localRoles(resources: resources, auditions: auditions)
            // all roles returned are considered 'inherited', so strip interpolated role case to return [AnyRole]
            if !roles.isEmpty { return roles.map(\.wrapped) }
            
            if !firstGenerationOnly {
                let childElements: AnySequence = firstElementEachGenerationOnly
                    ? storyElement.childElements.prefix(1).asAnySequence
                    : storyElement.childElements.asAnySequence
                
                for child in childElements {
                    let childRoles = child.rolesForNearestDescendant(
                        resources: resources,
                        auditions: auditions,
                        firstGenerationOnly: firstGenerationOnly,
                        firstElementEachGenerationOnly: firstElementEachGenerationOnly
                    )
                    if !childRoles.isEmpty { return childRoles }
                }
            }
        }
        
        return []
    }
}

extension FinalCutPro.FCPXML {
    static func addDefaultRoles(
        for elementType: FinalCutPro.FCPXML.ElementType,
        to localRoles: [FinalCutPro.FCPXML.AnyRole]
    ) -> [FinalCutPro.FCPXML.AnyInterpolatedRole] {
        let localRoles: [FinalCutPro.FCPXML.AnyInterpolatedRole] = localRoles.map { .assigned($0) }
        return addDefaultRoles(for: elementType, to: localRoles)
    }
    
    static func addDefaultRoles(
        for elementType: FinalCutPro.FCPXML.ElementType,
        to localRoles: [FinalCutPro.FCPXML.AnyInterpolatedRole]
    ) -> [FinalCutPro.FCPXML.AnyInterpolatedRole] {
        var localRoles: [FinalCutPro.FCPXML.AnyInterpolatedRole] = localRoles
        
        // add default roles if needed
        let defaultRoles = defaultRoles(for: elementType)
        if !localRoles.containsAudioRoles {
            localRoles.append(contentsOf: defaultRoles.audioRoles().map { .defaulted($0) })
        }
        if !localRoles.containsVideoRoles {
            localRoles.append(contentsOf: defaultRoles.videoRoles().map { .defaulted($0) })
        }
        if !localRoles.containsCaptionRoles {
            localRoles.append(contentsOf: defaultRoles.captionRoles().map { .defaulted($0) })
        }
        
        return localRoles
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
            case let .annotation(annotationType):
                switch annotationType {
                case .caption:
                    // captions use their own sets of roles specific for captions/text
                    // and generally they are auto-assigned so there are no defaults to return
                    return []
                case .keyword:
                    // keywords do not contain roles, they inherit them from their parent
                    return []
                case .marker:
                    // markers do not contain roles, they inherit them from their parent
                    return []
                }
            case let .clip(clipType):
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
                    return [defaultVideoRole, defaultAudioRole]
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
        case .resources:
            // N/A
            return []
        case .resource(_):
            // N/A
            return []
        }
    }
}

extension XMLElement {
    /// FCPXML: Attempt to extract default roles for the first child clip found.
    func fcpDefaultRolesForNearestDescendant() -> [FinalCutPro.FCPXML.AnyRole] {
        let contents = fcpStoryElements
        guard let firstChild = contents.first else { return [] }
        guard let elementType = firstChild.fcpElementType else { return [] }
        return FinalCutPro.FCPXML.defaultRoles(for: elementType)
    }
}

#endif
