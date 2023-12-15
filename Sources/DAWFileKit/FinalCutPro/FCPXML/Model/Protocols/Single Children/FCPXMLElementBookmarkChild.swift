//
//  FCPXMLElementBookmarkChild.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2023 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit

public protocol FCPXMLElementBookmarkChild: FCPXMLElement {
    /// Security-scoped bookmark data in a base64-encoded string.
    /// Access the `stringValue` property on the returned element.
    var bookmark: XMLElement? { get }
    
    /// Security-scoped bookmark data.
    /// Returns the decoded ``bookmark`` base64-encoded string as `Data`.
    var bookmarkData: Data? { get set }
}

extension FCPXMLElementBookmarkChild {
    // TODO: add set support, not just read-only
    public var bookmark: XMLElement? {
        element.firstChildElement(named: "bookmark")
    }
    
    public var bookmarkData: Data? {
        get {
            guard let value = element
                .firstChildElement(whereFCPElementType: .bookmark)?
                .stringValue
            else { return nil }
            
            return Data(base64Encoded: value)
        }
        set {
            let v = newValue?.base64EncodedString()
            element._updateChildElement(named: "bookmark", newStringValue: v)
        }
    }
}

#endif
