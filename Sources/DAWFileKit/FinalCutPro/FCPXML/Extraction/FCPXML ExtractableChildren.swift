//
//  FCPXML ExtractableChildren.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Extractable children contained within the element.
    struct ExtractableChildren {
        var children: DirectChildren?
        
        /// Explicit descendants and their children, if any, in special circumstances.
        ///
        /// - Note: This is not used for all descendants of any element, but for rare cases where a
        /// generational jump is required due to how elements are referenced. (`mc-clip` is one such example).
        ///
        /// Descendants are ordered nearest to furthest descendant.
        var descendants: [Descendant]?
    }
}

extension FinalCutPro.FCPXML.ExtractableChildren: Sendable { }

// MARK: - Static Constructors

extension FinalCutPro.FCPXML.ExtractableChildren {
    static let directChildren = Self(children: .all, descendants: nil)
    
    static func specificChildren(_ specificChildren: any Swift.Sequence<XMLElement>) -> Self {
        Self(children: .specific(specificChildren), descendants: nil)
    }
}

// MARK: - Values

extension FinalCutPro.FCPXML.ExtractableChildren {
    enum DirectChildren {
        /// All direct child elements of the element.
        case all
        
        /// Specific direct child elements of the element.
        case specific(_ specificChildren: any Swift.Sequence<XMLElement>)
    }
}

// TODO: XMLElement is not Sendable
extension FinalCutPro.FCPXML.ExtractableChildren.DirectChildren: @unchecked Sendable { }

extension FinalCutPro.FCPXML.ExtractableChildren {
    struct Descendant {
        let element: XMLElement
        let children: FinalCutPro.FCPXML.ExtractableChildren?
    }
}

// TODO: XMLElement is not Sendable
extension FinalCutPro.FCPXML.ExtractableChildren.Descendant: @unchecked Sendable { }

// MARK: - Init

extension FinalCutPro.FCPXML.ExtractableChildren {
    init?(
        of element: XMLElement,
        resources: XMLElement?,
        auditions: FinalCutPro.FCPXML.Audition.AuditionMask, // = .active
        mcClipAngleMask: FinalCutPro.FCPXML.MCClip.AngleMask // = .active
    ) {
        guard let fcpElementType = element.fcpElementType else { return nil }
        
        switch fcpElementType {
        // MARK: annotations
            
        case .caption:
            self = .directChildren
            
        case .keyword:
            return nil
            
        case .marker:
            return nil
                
        // MARK: clips
            
        case .assetClip:
            self = .directChildren
            
        case .audio:
            self = .directChildren
            
        case .audition:
            switch auditions {
            case .active:
                self = .specificChildren(
                    [element.fcpAsAudition?.activeClip]
                        .compactMap { $0 }
                )
            case .all:
                self = .directChildren
            }
            
        case .clip:
            self = .directChildren
            
        case .gap:
            self = .directChildren
            
        case .liveDrawing:
            self = .directChildren // TODO: ?
            
        case .mcClip: 
            // a.k.a. Multicam Clip
            // points to a `media` resource which will contain one `multicam`.
            // an `mc-clip` can point to only one `media` resource, but
            // the `mc-source` children in the `mc-clip` dictate what parts
            // of the `multicam` are used.
            
            // we need to know which video angle and audio angle the `mc-clip`
            // is referencing. they may be different angles or the same angle.
            // then we extract from those angle's storylines, ignoring the
            // other angles that may be present in the `multicam`.
            // so we can't just return the `media` resource and recurse, we need
            // to actually know which angles are used by the `mc-clip`.
            
            guard let multicamSources = element.fcpAsMCClip?.sources,
               let mediaResource = element.fcpResource(in: resources)?.fcpAsMedia,
               let multicam = mediaResource.multicam
            else {
                self = .directChildren
                return
            }
            
            var descendants: [FinalCutPro.FCPXML.ExtractableChildren.Descendant] = []
            
            // can omit, not really important
            // descendants.append(.init(element: mcSource, children: nil))
            
            descendants.append(.init(element: mediaResource.element, children: nil))
            
            switch mcClipAngleMask {
            case .active:
                let (audio, video) = multicam
                    .audioVideoMCAngles(forMulticamSources: multicamSources)
                
                // remove nils and reduce any duplicate elements
                let reducedMCAngles = [video, audio] // video first, audio second
                    .compactMap { $0?.element }
                    .removingDuplicates()
                
                // provide explicit descendants
                descendants.append(
                    .init(element: multicam.element, children: .specificChildren(reducedMCAngles))
                )
                
            case .all:
                // provide explicit descendants
                descendants.append(
                    .init(element: multicam.element, children: .directChildren)
                )
            }
            
            let ec = FinalCutPro.FCPXML.ExtractableChildren(
                children: .all,
                descendants: descendants
            )
            self = ec
            
        case .refClip:
            // a.k.a. Compound Clip
            // points to a `media` resource which will contain one `sequence`
            
            if let mediaResource = element.fcpResource(in: resources) {
                let ec = FinalCutPro.FCPXML.ExtractableChildren(
                    children: .all,
                    descendants: [.init(element: mediaResource, children: .directChildren)]
                )
                self = ec
            } else {
                self = .directChildren
            }
            
        case .syncClip:
            self = .directChildren
            
        case .title:
            self = .directChildren
            
        case .transition:
            self = .directChildren
            
        case .video:
            self = .directChildren
            
        // MARK: sequence
            
        case .sequence:
            // should only be a `spine` element, but return all children anyway
            self = .directChildren
            
        case .spine:
            self = .directChildren
            
        // MARK: structure
            
        case .library:
            // can contain one or more `event`s and `smart-collection`s
            self = .directChildren
            
        case .event:
            // can contain `project`s and `clips`
            // as well as collection folders, keyword collections, smart collections
            self = .directChildren
            
        case .project:
            // contains a `sequence` element
            self = .directChildren
            
        // MARK: resources
            
        case .resources:
            return nil
            
        case .asset:
            return nil
            
        case .effect:
            return nil
            
        case .format:
            return nil
            
        case .locator:
            return nil
            
        case .media:
            // used by `ref-clip` story element, media will contain a `sequence`
            // used by `mc-clip` story element, media will contain a `multicam`
            // self = .directChildren
            
            // don't return children here. elements that use a media resource
            // will point to specific children/descendants instead.
            return nil
            
        case .objectTracker:
            return nil
            
        // MARK: resource sub-elements
            
        case .mcAngle:
            // `mc-angle` is similar to a `sequence`
            self = .directChildren
            
        default:
            return nil
        }
    }
}

// parent/container
extension XMLElement {
    /// Extractable children contained within the element.
    func _fcpExtractableChildren(
        resources: XMLElement?,
        auditions: FinalCutPro.FCPXML.Audition.AuditionMask, // = .active
        mcClipAngleMask: FinalCutPro.FCPXML.MCClip.AngleMask // = .active
    ) -> FinalCutPro.FCPXML.ExtractableChildren? {
        FinalCutPro.FCPXML.ExtractableChildren(
            of: self,
            resources: resources,
            auditions: auditions,
            mcClipAngleMask: mcClipAngleMask
        )
    }
}

#endif
