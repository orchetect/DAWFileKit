//
//  FCPXML Sequence Clip.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import CoreMedia
@_implementationOnly import OTCore

// TODO: Refactor this as "FinalCutPro.FCP.AnyClip", refactor parsing into more general story element parser

extension FinalCutPro.FCPXML {
    /// Clip story element.
    /// Represents a basic unit of editing.
    ///
    /// > Final Cut Pro FCPXML 1.11 Reference:
    /// >
    /// > Use a `clip` element to describe a timeline sequence created from a source media file. A
    /// > `clip` contains video and/or audio elements, each of which represents a media component
    /// > (usually a track) in media. Specify the timing of the edit through the 
    /// > [Timing Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/clip
    /// > ).
    /// >
    /// > You can also use a `clip` element as an immediate child element of an event element to
    /// > represent a browser clip. In this case, use the [Timeline Attributes](
    /// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements/clip
    /// > ) to specify its format, etc.
    public enum Clip: FCPXMLStoryElement {
        case assetClip(AssetClip)
        case title(Title)
        case video(Video)
        
        // TODO: add additional clip types
    }
}

// MARK: - Clip Common

extension FinalCutPro.FCPXML.Clip {
    static func getRef(
        from xmlLeaf: XMLElement
    ) -> String {
        xmlLeaf.attributeStringValue(forName: Attributes.ref.rawValue) ?? ""
    }
    
    static func getName(
        from xmlLeaf: XMLElement
    ) -> String {
        xmlLeaf.attributeStringValue(forName: Attributes.name.rawValue) ?? ""
    }
    
    static func getMarkers(
        from xmlLeaf: XMLElement,
        sequenceFrameRate frameRate: TimecodeFrameRate
    ) -> [FinalCutPro.FCPXML.Marker] {
        let children = xmlLeaf.children?.lazy
            .compactMap { $0 as? XMLElement } ?? []
        
        var markers: [FinalCutPro.FCPXML.Marker] = []
        
        children.forEach {
            let itemName = $0.name ?? ""
            guard let item = FinalCutPro.FCPXML.Clip.ClipItem(rawValue: itemName)
            else {
                print("Info: skipping clip item \(itemName.quoted). Not handled.")
                return // next forEach
            }
            
            // TODO: we'll just parse markers for the time being. more items can be added in future.
            switch item {
            case .marker, .chapterMarker:
                guard let marker = FinalCutPro.FCPXML.Marker(
                    from: $0,
                    sequenceFrameRate: frameRate
                )
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
    // TODO: refactor into more general story element parser
    static func parseClips(
        from xmlLeaf: XMLElement,
        frameRate: TimecodeFrameRate,
        resources: [String: FinalCutPro.FCPXML.Resource]
    ) -> [Clip] {
        xmlLeaf.children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .compactMap { childLeaf in
                guard let name = childLeaf.name,
                      let clipType = ClipType(rawValue: name)
                else {
                    print("Error: unhandled sequence clip type \(childLeaf.name ?? "")")
                    return nil
                }
                
                switch clipType {
                case .assetClip:
                    let clip = Clip.AssetClip(
                        from: childLeaf,
                        frameRate: frameRate,
                        resources: resources
                    )
                    return .assetClip(clip)
                    
                case .title:
                    let clip = Clip.Title(
                        from: childLeaf,
                        frameRate: frameRate,
                        resources: resources
                    )
                    return .title(clip)
                    
                case .video:
                    let clip = Clip.Video(
                        from: childLeaf,
                        frameRate: frameRate,
                        resources: resources
                    )
                    return .video(clip)
                    
                }
            } ?? []
    }
}

#endif
