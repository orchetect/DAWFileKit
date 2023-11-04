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

extension FinalCutPro.FCPXML {
    /// Sequence Clip.
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
    
    static func getTimecode(
        attribute: Attributes,
        from xmlLeaf: XMLElement,
        sequenceFrameRate frameRate: TimecodeFrameRate
    ) -> Timecode {
        if let offsetString = xmlLeaf.attributeStringValue(forName: attribute.rawValue),
           let tc = try? FinalCutPro.FCPXML.timecode(
            fromRational: offsetString,
            frameRate: frameRate
           )
        {
            return tc
        } else {
            print("Error: \(attribute.rawValue) could not be decoded. Defaulting to 00:00:00:00 @ 30fps.")
            return FinalCutPro.formTimecode(at: .fps30)
        }
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
    static func parseClips(
        from xmlLeaf: XMLElement,
        sequenceFrameRate frameRate: TimecodeFrameRate
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
                        sequenceFrameRate: frameRate
                    )
                    return .assetClip(clip)
                    
                case .title:
                    let clip = Clip.Title(
                        from: childLeaf,
                        sequenceFrameRate: frameRate
                    )
                    return .title(clip)
                    
                case .video:
                    let clip = Clip.Video(
                        from: childLeaf,
                        sequenceFrameRate: frameRate
                    )
                    return .video(clip)
                    
                }
            } ?? []
    }
}

#endif
