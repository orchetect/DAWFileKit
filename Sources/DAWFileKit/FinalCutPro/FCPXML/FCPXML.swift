//
//  FCPXML.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

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
    /// > Final Cut Pro FCPXML 1.11 Reference:
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
    ///
    /// [Official FCPXML Apple docs](
    /// https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/
    /// )
    public struct FCPXML {
        /// Direct access to the FCPXML document.
        public var xml: XMLDocument
    }
}

#endif
