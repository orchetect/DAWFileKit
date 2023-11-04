//
//  FCPXML.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

extension FinalCutPro {
    /// Final Cut Pro XML file (FCPXML/FCPXMLD)
    ///
    /// General structure when exporting from Final Cut Pro:
    ///
    /// ```xml
    /// <fcpxml version="1.9">
    ///   <resources>
    ///     <format id="r1" ... >
    ///   </resources>
    ///   <library location="file:/// ...">
    ///     <event name="MyEvent" ... >
    ///       <project name="MyProject" ... >
    ///         <sequence ... >
    ///           <spine>
    ///             <!-- clips listed here -->
    ///           </spine>
    ///         </sequence>
    ///       </project>
    ///     </event>
    ///   </library>
    /// </fcpxml>
    /// ```
    ///
    /// > Note: Starting in FCPXML 1.9, the elements that describe how to organize and use media assets are optional.
    /// > The only required element in the `fcpxml` root element is the `resources` element.
    /// >
    /// > ```xml
    /// > <fcpxml version="1.9">
    /// >   <resources> ... </resources>
    /// >   <project name="MyProject" ... >
    /// >     <sequence ... > ... </sequence>
    /// >   </project>
    /// >   <event name="MyEvent" ... > ... </event>
    /// >   <asset-clip ... />
    /// > </fcpxml>
    /// > ```
    ///
    /// [Official FCPXML Apple docs](https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/)
    public struct FCPXML {
        /// Direct access to the FCP XML file.
        public var xml: XMLDocument
    }
}

// MARK: - XMLRoot/*

extension FinalCutPro.FCPXML {
    enum RootElements: String {
        case fcpxml
    }
    
    /// The root "fcpxml" XML element.
    public var xmlRoot: XMLElement? {
        xml.children?
            .lazy
            .compactMap { $0 as? XMLElement }
            .first(where: { $0.name == RootElements.fcpxml.rawValue })
    }
    
    enum FCPXMLAttributes: String {
        case version
    }
}

// MARK: - XMLRoot/fcpxml/*

extension FinalCutPro.FCPXML {
    /// > Final Cut Pro FCPXML Reference:
    /// >
    /// > The root element in an FCPXML document is `fcpxml`, which can contain the following elements:
    /// > - A `resources` element, that contains descriptions of media assets and other resources.
    /// > - An optional `import-options` element, that controls how Final Cut Pro imports the FCPXML document.
    /// > - One of the following optional elements that describe how to organize and use media assets:
    /// >   - a `library` element that contains a list of event elements;
    /// >   - a series of `event` elements that contain story elements and project elements; or
    /// >   - a combination of story elements and `project` elements.
    /// >
    /// > Note: Starting in FCPXML 1.9, the elements that describe how to organize and use media assets are optional. 
    /// > The only required element in the `fcpxml` root element is the `resources` element.
    enum FCPXMLElements: String {
        case resources
        case library
        case event
        case importOptions = "import-options"
    }
    
    /// The `resources` XML element.
    /// Exactly one of these elements is always required, regardless of the version of the FCPXML.
    var xmlResources: XMLElement? {
        xmlRoot?.elements(forName: FCPXMLElements.resources.rawValue).first
    }
    
    /// The `library` XML element, if it exists.
    /// One or zero of these elements may be present within the `fcpxml` element.
    public var xmlLibrary: XMLElement? {
        xmlRoot?.elements(forName: FCPXMLElements.library.rawValue).first
    }
}

#endif
