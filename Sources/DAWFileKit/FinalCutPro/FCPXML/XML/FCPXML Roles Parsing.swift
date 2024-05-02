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
    func _fcpLocalRoles(
        resources: XMLElement? = nil,
        auditions: FinalCutPro.FCPXML.Audition.AuditionMask, // = .active
        mcClipAngles: FinalCutPro.FCPXML.MCClip.AngleMask // = .active
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
        // MARK: annotations
            
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
            
        // MARK: clips
            
        case .assetClip:
            // asset clip can have `audioRole` and/or `videoRole` attributes.
            
            guard let assetClip = fcpAsAssetClip else { break }
            
            // it can also have roles in `audio-channel-source` children which may or may
            // not contain a time range. if there is no time range it applies to the entire
            // clip and overrides the asset clip's `audioRole`.
            
            if let role = assetClip.videoRole {
                add(role: .video(role), isInherited: false)
            }
            
            let audioChannelSources = assetClip.audioChannelSources
                .filter(\.active)
            
            if audioChannelSources.isEmpty {
                if let role = assetClip.audioRole {
                    add(role: .audio(role), isInherited: false)
                }
            } else {
                // TODO: if audio channel source has a time range and it starts later than the clip's start, then do we assume FCP falls back to using the asset clip's audio role? not sure.
                // TODO: also, what happens when there are multiple audio channel sources that overlap? or all lack a time range. does FCP use the topmost?
                add(roles: audioChannelSources.asAnyRoles(), isInherited: false)
            }
            
            // print(localRoles.map(\.role).map(\.rawValue),
            //       Array(ancestorElements(includingSelf: false)).count)
            
        case .audio:
            guard let audio = fcpAsAudio else { break }
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
            
            let childRoles = _fcpRolesForNearestDescendant(
                resources: resources,
                auditions: auditions,
                mcClipAngles: mcClipAngles,
                firstGenerationOnly: true,
                firstElementEachGenerationOnly: false, 
                ignoring: []
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
            
            guard let mcClip = fcpAsMCClip else { break }
            
            let sources = mcClip.sources
            guard !sources.isEmpty else { break }
            
            // parse media angles
            
            let ref = mcClip.ref
            
            guard let multicam = fcpResource(forID: ref, in: resources)?
                .fcpAsMedia?
                .multicam
            else { break }
            
            // fetch angles being used
            let (audioAngle, videoAngle) = multicam.audioVideoMCAngles(forMulticamSources: sources)
            
            if let videoAngle = videoAngle {
                let videoRoles = videoAngle.element._fcpRolesForNearestDescendant(
                    resources: resources,
                    auditions: auditions,
                    mcClipAngles: mcClipAngles,
                    firstGenerationOnly: false,
                    firstElementEachGenerationOnly: false,
                    types: [.video],
                    ignoring: []
                )
                .map { $0.asAnyRole() }
                
                add(roles: videoRoles, isInherited: true)
            }
            
            // use role from first story element within each angle
            if let audioAngle = audioAngle {
                let audioRoles = audioAngle.element._fcpRolesForNearestDescendant(
                    resources: resources,
                    auditions: auditions,
                    mcClipAngles: mcClipAngles,
                    firstGenerationOnly: false,
                    firstElementEachGenerationOnly: false,
                    types: [.audio],
                    ignoring: []
                )
                .map { $0.asAnyRole() }
                
                add(roles: audioRoles, isInherited: true)
            }
            
        case .refClip:
            // does not have video role itself. it references a sequence that may contain
            // clips with their own roles.
            // has audio subroles that are enable-able.
            guard let refClip = fcpAsRefClip else { break }
            
            if refClip.useAudioSubroles {
                let audioRoleSources = refClip.audioRoleSources
                    .filter(\.active)
                let audioRoles = audioRoleSources.asAnyRoles()
                add(roles: audioRoles, isInherited: false)
            }
            
        case .syncClip:
            // sync clip does not have video/audio roles itself.
            guard let syncClip = fcpAsSyncClip else { break }
            
            // the audio role may be present in a `sync-source` child of the sync clip.
            let syncSources = syncClip.syncSources
            let audioRoleSources = syncSources
                .flatMap(\.audioRoleSources)
            let activeAudioRoleSources = audioRoleSources.filter { $0.active }
            let inactiveAudioRoleSources = audioRoleSources.filter { !$0.active }
            
            // we derive the video role from the sync clip's first video media.
            // we'll also add any audio roles found in case sync sources are missing and
            // audio roles can't be derived from them.
            let childVideoRoles = _fcpRolesForNearestDescendant(
                resources: resources,
                auditions: auditions,
                mcClipAngles: mcClipAngles,
                firstGenerationOnly: false,
                firstElementEachGenerationOnly: true,
                types: [.video],
                ignoring: inactiveAudioRoleSources.asAnyRoles()
            )
            add(roles: childVideoRoles, isInherited: true)
            
            if activeAudioRoleSources.isEmpty {
                let childAudioRoles = _fcpRolesForNearestDescendant(
                    resources: resources,
                    auditions: auditions,
                    mcClipAngles: mcClipAngles,
                    firstGenerationOnly: false,
                    firstElementEachGenerationOnly: true,
                    types: [.audio],
                    ignoring: inactiveAudioRoleSources.asAnyRoles()
                )
                add(roles: childAudioRoles, isInherited: true)
            } else {
                add(roles: activeAudioRoleSources.asAnyRoles(), isInherited: true)
            }
            
            // print(localRoles.map(\.role).map(\.rawValue), 
            //       Array(ancestorElements(includingSelf: false)).count)
            
        case .title:
            guard let title = fcpAsTitle else { break }
            if let role = title.role {
                add(role: .video(role), isInherited: false)
            }
            
        case .video:
            guard let video = fcpAsVideo else { break }
            if let role = video.role {
                add(role: .video(role), isInherited: false)
            }
            
        // MARK: sequence
            
        case .sequence:
            break
            
        case .spine:
            break
            
        default:
            // N/A or not yet handled
            return []
        }
        
        let mappedRoles: [FinalCutPro.FCPXML.AnyInterpolatedRole] = localRoles.map {
            $0.isInherited
                ? .inherited($0.role)
                : .assigned($0.role)
        }
        
        return mappedRoles
    }
    
    /// FCPXML: Attempts to extract assigned roles for the first child clip found.
    func _fcpRolesForNearestDescendant<I: Sequence<FinalCutPro.FCPXML.AnyRole>>(
        resources: XMLElement? = nil,
        auditions: FinalCutPro.FCPXML.Audition.AuditionMask, // = .active
        mcClipAngles: FinalCutPro.FCPXML.MCClip.AngleMask, // = .active
        firstGenerationOnly: Bool,
        firstElementEachGenerationOnly: Bool,
        types: Set<FinalCutPro.FCPXML.RoleType> = .allCases,
        ignoring ignoreRoles: I
    ) -> [FinalCutPro.FCPXML.AnyRole] {
        var collectedRoles: [FinalCutPro.FCPXML.AnyRole] = []
        
        func add(_ newRoles: some Sequence<FinalCutPro.FCPXML.AnyRole>) {
            newRoles.forEach { collectedRoles.insert($0) }
        }
        
        func elements(for element: XMLElement) -> some Sequence<XMLElement> {
            // TODO: refactor using `_fcpFirstChildTimelineElement(excluding: [.gap])`
            
            var elements: AnySequence = firstElementEachGenerationOnly
                ? element.fcpTimelineElements.prefix(1).asAnySequence
                : element.fcpTimelineElements.asAnySequence
            
            // gaps may appear before an actual clip in a multicam angle.
            // FCP skips them and looks to the first clip in the angle.
            // (gaps are timelines but also cannot have roles)
            elements = elements
                .filter { $0.fcpElementType != .gap }
                .asAnySequence
            
            return elements
        }
        
        func localRoles(for element: XMLElement) -> some Sequence<FinalCutPro.FCPXML.AnyRole> {
            // all roles returned are considered inherited,
            // so we'll strip its `AnyInterpolatedRole` case to return `[AnyRole]`
            element
                ._fcpLocalRoles(resources: resources, auditions: auditions, mcClipAngles: mcClipAngles)
                .filter { types.contains($0.wrapped.roleType) }
                .filter { !ignoreRoles.contains($0.wrapped) }
                .map(\.wrapped)
        }
        
        let localElements = elements(for: self)
        
        for localElement in localElements {
            let roles = localRoles(for: localElement)
            add(roles)
            
            if !firstGenerationOnly {
                let childElements = elements(for: localElement)
                
                for childElement in childElements {
                    let childRoles = localRoles(for: childElement)
                    add(childRoles)
                }
            }
        }
        
        return collectedRoles
    }
}

// MARK: - Default Roles

// Known default roles Final Cut Pro uses.
// If an element does not have a user-assigned role, Final Cut Pro uses
// certain defaults.
// TODO: These are English-only defaults, would be nice to localize them

extension FinalCutPro.FCPXML.AudioRole {
    static let defaultAudioRole: Self = Self(rawValue: "Dialogue")!
}

extension FinalCutPro.FCPXML.VideoRole {
    static let defaultVideoRole: Self = Self(rawValue: "Video")!
    static let titlesRole: Self = Self(rawValue: "Titles")!
}

extension FinalCutPro.FCPXML {
    
    static let defaultAudioRole: AnyRole = .audio(.defaultAudioRole)
    static let defaultVideoRole: AnyRole = .video(.defaultVideoRole)
    static let titlesRole: AnyRole = .video(.titlesRole)
    
    /// Returns known default role(s) that Final Cut Pro uses for a given element type.
    /// If an element does not have a user-assigned role, Final Cut Pro uses
    /// certain defaults that are not written to the FCPXML file so we have to provide them.
    static func _defaultRoles(for elementType: ElementType) -> [AnyRole] {
        switch elementType {
        // MARK: annotations
            
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
            
        // MARK: clips
            
        case .assetClip:
            // note that an asset-clip can contain video and/or audio
            return []
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
        case .sequence:
            return []
        case .spine:
            return []
            
        default:
            return []
        }
    }
    
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
        let defaultRoles = _defaultRoles(for: elementType)
        if !localRoles.containsVideoRoles {
            localRoles.append(contentsOf: defaultRoles.videoRoles().map { .defaulted($0) })
        }
        if !localRoles.containsAudioRoles {
            localRoles.append(contentsOf: defaultRoles.audioRoles().map { .defaulted($0) })
        }
        if !localRoles.containsCaptionRoles {
            localRoles.append(contentsOf: defaultRoles.captionRoles().map { .defaulted($0) })
        }
        
        return localRoles.sortedByRoleType()
    }
}

extension XMLElement {
    /// FCPXML: Attempt to extract default roles for the first child clip found.
    func _fcpDefaultRolesForNearestDescendant() -> [FinalCutPro.FCPXML.AnyRole] {
        let contents = fcpStoryElements
        guard let firstChild = contents.first else { return [] }
        guard let elementType = firstChild.fcpElementType else { return [] }
        return FinalCutPro.FCPXML._defaultRoles(for: elementType)
    }
}

#endif
