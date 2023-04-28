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
        case assetClip
        case title
        case video
        
        // TODO: add additional clip types
    }
    
    /// Sequence Clip.
    public enum Clip {
        case assetClip(AssetClip)
        case title(Title)
        case video(Video)
        
        // TODO: add additional clip types
    }
}

// MARK: - Clip Common

extension FinalCutPro.FCPXML.Sequence.Clip {
    /// Clip XML Attributes.
    public enum Attributes: String {
        case ref // resource ID
        case offset
        case name
        case start
        case duration
        
        case audioRole
        case role // video role
    }
    
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
            return FinalCutPro.formTimecode(at: ._30)
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
        
        return markers
    }
}

// MARK: - Asset Clip

extension FinalCutPro.FCPXML.Sequence.Clip {
    // <asset-clip ref="r2" offset="0s" name="Nature Makes You Happy" duration="355100/2500s" tcFormat="NDF" audioRole="dialogue">
    /// Asset Clip.
    public struct AssetClip {
        public let ref: String // resource ID
        public let offset: Timecode
        public let name: String
        public let duration: Timecode
        public let audioRole: String
        
        internal init(
            ref: String,
            offset: Timecode,
            name: String,
            duration: Timecode,
            audioRole: String
        ) {
            self.ref = ref
            self.offset = offset
            self.name = name
            self.duration = duration
            self.audioRole = audioRole
        }
    }
}

extension FinalCutPro.FCPXML.Sequence.Clip.AssetClip {
    /// Asset clip XML Attributes.
    public enum Attributes: String {
        case ref // resource ID
        case offset
        case name
        case duration
        case audioRole
    }
    
    internal init(
        from xmlLeaf: XMLElement,
        sequenceFrameRate frameRate: TimecodeFrameRate
    ) {
        // "ref"
        ref = FinalCutPro.FCPXML.Sequence.Clip.getRef(from: xmlLeaf)
        
        // "offset"
        offset = FinalCutPro.FCPXML.Sequence.Clip.getTimecode(
            attribute: .offset,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // "name"
        name = FinalCutPro.FCPXML.Sequence.Clip.getName(from: xmlLeaf)
        
        // "duration"
        duration = FinalCutPro.FCPXML.Sequence.Clip.getTimecode(
            attribute: .duration,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // "audioRole"
        audioRole = xmlLeaf.attributeStringValue(forName: Attributes.audioRole.rawValue) ?? ""
    }
}

// MARK: - Title Clip

extension FinalCutPro.FCPXML.Sequence.Clip {
    // <title ref="r2" offset="0s" name="Basic Title" start="0s" duration="1920919/30000s">
    /// Title Clip.
    ///
    /// This is a FCP meta type and video is generated.
    /// Its frame rate is inferred from the sequence.
    /// Therefore, "tcFormat" (NDF/DF) attribute is not stored in `<title>` XML itself.
    public struct Title {
        public let ref: String // resource ID
        public let offset: Timecode
        public let name: String
        public let start: Timecode
        public let duration: Timecode
        // TODO: add audio/video roles?
        
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
    
    /// Note: `frameDuration` and `tcFormat` is not stored in `<title>`,
    /// it's inferred from the parent sequence.
    internal init(
        from xmlLeaf: XMLElement,
        sequenceFrameRate frameRate: TimecodeFrameRate
    ) {
        // "ref"
        ref = FinalCutPro.FCPXML.Sequence.Clip.getRef(from: xmlLeaf)
        
        // "offset"
        offset = FinalCutPro.FCPXML.Sequence.Clip.getTimecode(
            attribute: .offset,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // "name"
        name = FinalCutPro.FCPXML.Sequence.Clip.getName(from: xmlLeaf)
        
        // "start"
        start = FinalCutPro.FCPXML.Sequence.Clip.getTimecode(
            attribute: .start,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // "duration"
        duration = FinalCutPro.FCPXML.Sequence.Clip.getTimecode(
            attribute: .duration,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // contents
        markers = FinalCutPro.FCPXML.Sequence.Clip.getMarkers(from: xmlLeaf, sequenceFrameRate: frameRate)
    }
}

// MARK: - Video Clip

extension FinalCutPro.FCPXML.Sequence.Clip {
    // <video ref="r7" offset="869600/2500s" name="Clouds" start="3600s" duration="250300/2500s" role="Sample Role.Sample Role-1">
    /// Video Clip.
    public struct Video {
        public let ref: String // resource ID
        public let offset: Timecode
        public let name: String
        public let start: Timecode
        public let duration: Timecode
        public let role: String
        
        internal init(
            ref: String,
            offset: Timecode,
            name: String,
            start: Timecode,
            duration: Timecode,
            role: String
        ) {
            self.ref = ref
            self.offset = offset
            self.name = name
            self.start = start
            self.duration = duration
            self.role = role
        }
    }
}

extension FinalCutPro.FCPXML.Sequence.Clip.Video {
    /// Video clip XML Attributes.
    public enum Attributes: String {
        case ref // resource ID
        case offset
        case name
        case start
        case duration
        case role
    }
    
    internal init(
        from xmlLeaf: XMLElement,
        sequenceFrameRate frameRate: TimecodeFrameRate
    ) {
        // "ref"
        ref = FinalCutPro.FCPXML.Sequence.Clip.getRef(from: xmlLeaf)
        
        // "offset"
        offset = FinalCutPro.FCPXML.Sequence.Clip.getTimecode(
            attribute: .offset,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // "name"
        name = FinalCutPro.FCPXML.Sequence.Clip.getName(from: xmlLeaf)
        
        // "start"
        start = FinalCutPro.FCPXML.Sequence.Clip.getTimecode(
            attribute: .start,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // "duration"
        duration = FinalCutPro.FCPXML.Sequence.Clip.getTimecode(
            attribute: .duration,
            from: xmlLeaf,
            sequenceFrameRate: frameRate
        )
        
        // "role"
        role = xmlLeaf.attributeStringValue(forName: Attributes.role.rawValue) ?? ""
    }
}

// MARK: - Clip Item

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
