//
//  FCPXML ElementContext.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro.FCPXML {
    /// Context for a model element.
    ///
    /// Adds context information for an element's parent, as well as absolute timecode information.
    public struct ElementContext {
        /// The absolute start timecode of the element.
        public var absoluteStart: Timecode?
        
        /// Contains an event name if the element is a descendent of an event.
        public var ancestorEventName: String?
        
        /// Contains a project name if the element is a descendent of a project.
        public var ancestorProjectName: String?
        
        /// The parent clip's type.
        public var parentType: StoryElementType
        
        /// The parent clip's name.
        public var parentName: String?
        
        /// The parent clip's absolute start time.
        public var parentAbsoluteStart: Timecode?
        
        /// The parent clip's duration.
        public var parentDuration: Timecode?
        
        /// - Note: Ancestors is ordered from furthest ancestor to closest ancestor of the `parent`.
        init<Element: FCPXMLExtractableElement>(
            element: Element,
            settings: FCPXMLExtractionSettings,
            parent: AnyStoryElement,
            ancestorsOfParent: [AnyStoryElement]
        ) {
            ancestorEventName = settings.ancestorEventName
            ancestorProjectName = settings.ancestorProjectName
            
            parentType = parent.storyElementType
            parentName = parent.name
            parentAbsoluteStart = Self.aggregateOffset(parent: parent, ancestorsOfParent: ancestorsOfParent)
            parentDuration = parent.duration
            
            // calculate absolute start
            
            let parentStart = Self.nearestStart(parent: parent, ancestorsOfParent: ancestorsOfParent)
            
            if let elementStart = element.start,
               let parentStart = parentStart,
               let parentAbsoluteStart = parentAbsoluteStart
            {
                let localElementStart = elementStart - parentStart
                if let elementAbsoluteStart = try? parentAbsoluteStart.adding(localElementStart, by: .wrapping) {
                    absoluteStart = elementAbsoluteStart
                } else {
                    print("Error offsetting timecode for element \(element.name?.quoted ?? "").")
                }
            } else {
                let pas = parentAbsoluteStart?.stringValue(format: [.showSubFrames]) ?? "missing"
                let ps = parentStart?.stringValue(format: [.showSubFrames]) ?? "missing"
                print(
                    "Error calculating absolute timecode for element \(element.name?.quoted ?? "")."
                    + " Parent absolute start: \(pas) Parent start: \(ps)"
                )
            }
        }
        
        /// Return absolute timecode of innermost parent by calculating aggregate offset of ancestors.
        /// - Note: Ancestors is ordered from furthest ancestor to closest ancestor of the `parent`.
        private static func aggregateOffset(
            parent: AnyStoryElement,
            ancestorsOfParent: [AnyStoryElement]
        ) -> Timecode? {
            let ancestors = ancestorsOfParent + [parent] // topmost -> innermost
            
            var pos: Timecode?
            
            func add(_ other: Timecode?) {
                guard let other = other else { return }
                let newTC = pos ?? Timecode(.zero, using: other.properties)
                pos = try? newTC.adding(other, by: .wrapping)
            }
            
            for ancestor in ancestors {
                switch ancestor {
                case let .anyClip(clip):
                    add(clip.offset)
                    
                case .sequence(_ /* let sequence */):
                    // pos = sequence.startTimecode
                    break
                    
                case let .spine(spine):
                    add(spine.offset)
                }
                
            }
            
            return pos
        }
        
        /// Return nearest `start` attribute value, starting from closest parent and traversing up
        /// through ancestors.
        /// - Note: Ancestors is ordered from furthest ancestor to closest ancestor of the `parent`.
        private static func nearestStart(
            parent: AnyStoryElement,
            ancestorsOfParent: [AnyStoryElement]
        ) -> Timecode? {
            let ancestors = ancestorsOfParent + [parent] // topmost -> innermost
            
            for ancestor in ancestors.reversed() {
                if let start = ancestor.start { return start }
            }
            
            return nil
        }
    }
}

#endif
