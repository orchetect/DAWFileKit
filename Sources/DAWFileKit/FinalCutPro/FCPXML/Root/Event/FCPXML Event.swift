//
//  FCPXML Event.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import CoreMedia

extension FinalCutPro.FCPXML {
    /// Represent a single event in a library.
    ///
    /// > Final Cut Pro FCPXML Reference:
    /// >
    /// > An event may contain clips as story elements and projects, along with keyword collections
    /// > and smart collections. The keyword-collection and smart-collection elements organize clips
    /// > by keywords and other matching criteria listed under the Smart Collection Match Elements.
    public struct Event {
        public let name: String
        public let projects: [Project]
    }
}

#endif
