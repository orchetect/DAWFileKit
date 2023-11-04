//
//  FCPXMLAnnotationElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

/// FCPXML annotation elements.
///
/// - `keyword`
/// - `marker`
/// - `chapter-marker`
/// - `analysis-marker`
/// - `rating`
/// - `note`
///
/// > Final Cut Pro FCPXML 1.11 Reference:
/// >
/// > Many story elements can contain annotations (keyword, markers, and so on) over a range of
/// > time, specified with the start and duration attributes. Add annotations to story elements
/// > using the elements listed under [Annotation and Note Elements](
/// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements
/// > ).
public protocol FCPXMLAnnotationElement { }

#endif
