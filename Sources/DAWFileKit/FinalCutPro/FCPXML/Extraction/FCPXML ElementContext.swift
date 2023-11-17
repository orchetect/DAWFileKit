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
        init<Element: _FCPXMLExtractableElement>(
            element: Element,
            settings: ExtractionSettings,
            parent: AnyStoryElement,
            ancestorsOfParent: [AnyStoryElement]
        ) {
            ancestorEventName = settings.ancestorEventName
            ancestorProjectName = settings.ancestorProjectName
            
            parentType = parent.storyElementType
            parentName = parent.name
            parentAbsoluteStart = Self.aggregateOffset(
                parent: parent,
                ancestorsOfParent: ancestorsOfParent
            )
            parentDuration = parent.duration
            
            absoluteStart = Self.calculateAbsoluteStart(
                element: element, 
                parent: parent,
                ancestorsOfParent: ancestorsOfParent,
                parentAbsoluteStart: parentAbsoluteStart
            )
        }
    }
}

extension FinalCutPro.FCPXML.ElementContext {
    private static func calculateAbsoluteStart<Element: _FCPXMLExtractableElement>(
        element: Element,
        parent: FinalCutPro.FCPXML.AnyStoryElement,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement],
        parentAbsoluteStart: Timecode?
    ) -> Timecode? {
        let parentStart = nearestStart(parent: parent, ancestorsOfParent: ancestorsOfParent)
        
        guard let elementStart = element.extractableStart,
              let parentStart = parentStart,
              let parentAbsoluteStart = parentAbsoluteStart
        else {
            let pas = parentAbsoluteStart?.stringValue(format: [.showSubFrames]) ?? "missing"
            let ps = parentStart?.stringValue(format: [.showSubFrames]) ?? "missing"
            print(
                "Error calculating absolute timecode for element \(element.extractableName?.quoted ?? "")."
                    + " Parent absolute start: \(pas) Parent start: \(ps)"
            )
            return nil
        }
        
        let localElementStart = elementStart - parentStart
        guard let elementAbsoluteStart = try? parentAbsoluteStart.adding(
            localElementStart,
            by: .wrapping
        )
        else {
            print("Error offsetting timecode for element \(element.extractableName?.quoted ?? "").")
            return nil
        }
        
        return elementAbsoluteStart
    }
    
    /// Return absolute timecode of innermost parent by calculating aggregate offset of ancestors.
    /// - Note: Ancestors is ordered from furthest ancestor to closest ancestor of the `parent`.
    private static func aggregateOffset(
        parent: FinalCutPro.FCPXML.AnyStoryElement,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement]
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
                
            case .sequence(_ /* let sequence */ ):
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
        parent: FinalCutPro.FCPXML.AnyStoryElement,
        ancestorsOfParent: [FinalCutPro.FCPXML.AnyStoryElement]
    ) -> Timecode? {
        let ancestors = ancestorsOfParent + [parent] // topmost -> innermost
        
        for ancestor in ancestors.reversed() {
            if let start = ancestor.start { return start }
        }
        
        return nil
    }
}

#endif
