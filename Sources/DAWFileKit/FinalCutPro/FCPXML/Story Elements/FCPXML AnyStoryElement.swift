//
//  FCPXML AnyStoryElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import CoreMedia
@_implementationOnly import OTCore

 extension FinalCutPro.FCPXML {
    /// Type-erased box containing a story element.
    public enum AnyStoryElement: FCPXMLStoryElement {
        case assetClip(AssetClip)
        case title(Title)
        case video(Video)

        // TODO: add additional clip types
    }
 }

// MARK: - Utilities

extension FinalCutPro.FCPXML {
    static func getMarkers(
        from xmlLeaf: XMLElement,
        frameRate: TimecodeFrameRate
    ) -> [FinalCutPro.FCPXML.Marker] {
        let children = xmlLeaf.children?.lazy
            .compactMap { $0 as? XMLElement } ?? []
        
        var markers: [FinalCutPro.FCPXML.Marker] = []
        
        children.forEach {
            let itemName = $0.name ?? ""
            guard let item = FinalCutPro.FCPXML.AnnotationType(rawValue: itemName)
            else {
                print("Info: skipping clip item \(itemName.quoted). Not handled.")
                return // next forEach
            }
            
            // TODO: we'll just parse markers for the time being. more items can be added in future.
            switch item {
            case .marker, .chapterMarker:
                guard let marker = FinalCutPro.FCPXML.Marker(from: $0, frameRate: frameRate)
                else {
                    print("Error: failed to parse marker.")
                    return // next forEach
                }
                markers.append(marker)
            }
        }
        
        return markers
    }
}

extension FinalCutPro.FCPXML {
    // TODO: this should parse any type of story element, not just clips
    // TODO: refactor into more general story element parser
    static func parseStoryElements(
        from xmlLeaf: XMLElement,
        frameRate: TimecodeFrameRate,
        resources: [String: FinalCutPro.FCPXML.AnyResource]
    ) -> [AnyStoryElement] {
        xmlLeaf.children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .compactMap { (childLeaf: XMLElement) -> AnyStoryElement? in
                guard let name = childLeaf.name else {
                    print("Error: unhandled story element type for xml leaf.)")
                    return nil
                }
                
                if let clipType = StoryElementType(rawValue: name) {
                    switch clipType {
                    case .assetClip:
                        guard let clip = AssetClip(
                            from: childLeaf,
                            frameRate: frameRate
                        ) else { return nil }
                        return .assetClip(clip)
                        
                    case .video:
                        guard let clip = Video(
                            from: childLeaf,
                            frameRate: frameRate
                        ) else { return nil }
                        return .video(clip)
                        
                    default:
                        break

                    }
                }
                
                // TODO: this probably needs to be refactored since title is not technically a story element type, but an effect type
                if let effectType = EffectElementType(rawValue: name) {
                    switch effectType {
                    case .title:
                        guard let clip = Title(
                            from: childLeaf,
                            frameRate: frameRate
                        ) else { return nil }
                        return .title(clip)
                    
                    default:
                        break
                    }
                }
                
                print("Error: unhandled story element type \(name.quoted)")
                return nil
            } ?? []
    }
}

#endif
