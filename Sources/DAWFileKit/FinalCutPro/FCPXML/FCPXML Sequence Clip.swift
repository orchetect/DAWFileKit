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

extension FinalCutPro.FCPXML.Sequence {
    public enum ClipType: String {
        case title
        
        // TODO: add additional clip types
    }
    
    /// Sequence Clip.
    public enum Clip {
        case title(Title)
        
        // TODO: add additional clip types
    }
}

extension FinalCutPro.FCPXML.Sequence.Clip {
    // <title ref="r2" offset="0s" name="Basic Title" start="0s" duration="1920919/30000s">
    /// Title Clip.
    ///
    /// This is a FCP meta type and video is generated.
    /// Its frame rate is inferred from the sequence.
    /// Therefore, "tcFormat" (NDF/DF) attribute is not stored in <title> XML itself.
    public struct Title {
        public let ref: String // resource ID
        public let offset: Timecode
        public let name: String
        public let start: Timecode
        public let duration: Timecode
        
        // Contents
        public let markers: [FinalCutPro.FCPXML.Marker]
        
        internal init(
            ref: String,
            offset: Timecode,
            name: String,
            start: Timecode,
            duration: Timecode,
            markers: [FinalCutPro.FCPXML.Marker]
        ) {
            self.ref = ref
            self.offset = offset
            self.name = name
            self.start = start
            self.duration = duration
            self.markers = markers
        }
    }
}

extension FinalCutPro.FCPXML.Sequence.Clip.Title {
    /// Title clip XML Attributes.
    public enum Attributes: String {
        case ref // resource ID
        case offset
        case name
        case start
        case duration
    }
    
    /// Note: `frameDuration` and `tcFormat` is not stored in <title>,
    /// it's inferred from the parent sequence.
    internal init(
        from xmlLeaf: XMLElement,
        sequenceFrameRate frameRate: TimecodeFrameRate
    ) {
        // "ref"
        ref = xmlLeaf.attributeStringValue(forName: Attributes.ref.rawValue) ?? ""
        
        // "offset"
        if let offsetString = xmlLeaf.attributeStringValue(forName: Attributes.offset.rawValue),
           let tc = try? FinalCutPro.FCPXML.timecode(
            fromString: offsetString,
            frameRate: frameRate
           )
        {
            offset = tc
        } else {
            print("Error: offset could not be decoded. Defaulting to 00:00:00:00 @ 30fps.")
            offset = FinalCutPro.formTimecode(at: ._30)
        }
        
        // "name"
        name = xmlLeaf.attributeStringValue(forName: Attributes.name.rawValue) ?? ""
        
        // "start"
        if let startString = xmlLeaf.attributeStringValue(forName: Attributes.start.rawValue),
           let tc = try? FinalCutPro.FCPXML.timecode(
            fromString: startString,
            frameRate: frameRate
           )
        {
            start = tc
        } else {
            print("Error: start could not be decoded. Defaulting to 00:00:00:00 @ 30fps.")
            start = FinalCutPro.formTimecode(at: ._30)
        }
        
        // "duration"
        if let durationString = xmlLeaf.attributeStringValue(forName: Attributes.duration.rawValue),
           let tc = try? FinalCutPro.FCPXML.timecode(
            fromString: durationString,
            frameRate: frameRate
           )
        {
            duration = tc
        } else {
            print("Error: duration could not be decoded. Defaulting to 00:00:00:00 @ 30fps.")
            duration = FinalCutPro.formTimecode(at: ._30)
        }
        
        // contents
        let children = xmlLeaf.children?.lazy
            .compactMap { $0 as? XMLElement } ?? []
        
        var markers: [FinalCutPro.FCPXML.Marker] = []
        
        children.forEach {
            let itemName = $0.name ?? ""
            guard let item = FinalCutPro.FCPXML.Sequence.Clip.ClipItem(rawValue: itemName)
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
        
        self.markers = markers
    }
}

extension FinalCutPro.FCPXML.Sequence.Clip {
    /// Items within clips.
    public enum ClipItem: String {
        case marker // includes standard and to-do markers
        case chapterMarker = "chapter-marker"
        
        // TODO: add additional clip items
    }
}

extension FinalCutPro.FCPXML.Sequence {
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
                case .title:
                    let clip = Clip.Title(
                        from: childLeaf,
                        sequenceFrameRate: frameRate
                    )
                    return .title(clip)
                }
            } ?? []
    }
}

#endif
