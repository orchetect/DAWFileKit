//
//  General FCPXML Properties.swift.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

// MARK: - Basic Attributes

extension XMLElement {
    /// Get or set the value of the `name` attribute.
    public var fcpName: String? {
        get { stringValue(forAttributeNamed: "name") }
        set { addAttribute(withName: "name", value: newValue) }
    }
    
    /// Get or set the value of the `note` attribute.
    public var fcpNote: String? {
        get { stringValue(forAttributeNamed: "note") }
        set { addAttribute(withName: "note", value: newValue) }
    }
    
    /// Get or set the value of the `value` attribute.
    public var fcpValue: String? {
        get { stringValue(forAttributeNamed: "value") }
        set { addAttribute(withName: "value", value: newValue) }
    }
}

// MARK: - Time Attributes

extension XMLElement {
    /// Get or set the value of the `duration` attribute.
    public var fcpDuration: Fraction? {
        get { getFraction(forAttribute: "duration") }
        set { set(fraction: newValue, forAttribute: "duration") }
    }
    
    /// Get or set the value of the `start` attribute.
    public var fcpStart: Fraction? {
        get { getFraction(forAttribute: "start") }
        set { set(fraction: newValue, forAttribute: "start") }
    }
    
    /// Get or set the value of the `tcStart` attribute.
    public var fcpTCStart: Fraction? {
        get { getFraction(forAttribute: "tcStart") }
        set { set(fraction: newValue, forAttribute: "tcStart") }
    }
    
    /// Get or set the value of the `offset` attribute.
    public var fcpOffset: Fraction? {
        get { getFraction(forAttribute: "offset") }
        set { set(fraction: newValue, forAttribute: "offset") }
    }
}

// MARK: - Timeline Attributes

extension XMLElement {
    /// Get or set the value of the `enabled` attribute.
    public var fcpEnabled: Bool? {
        get { getBool(forAttribute: "enabled") }
        set { set(bool: newValue, forAttribute: "enabled") }
    }
    
    /// Get or set the value of the `role` attribute.
    public var fcpLane: Int? {
        get { getInt(forAttribute: "lane") }
        set { set(int: newValue, forAttribute: "lane") }
    }
}

// MARK: - Role Attributes

extension XMLElement {
    /// Get or set the value of the `role` attribute.
    public var fcpRole: String? {
        get { stringValue(forAttributeNamed: "role") }
        set { addAttribute(withName: "role", value: newValue) }
    }
}

// MARK: - Helpers

extension XMLElement {
    func getFraction(forAttribute attributeName: String) -> Fraction? {
        guard let value = stringValue(forAttributeNamed: attributeName)
        else { return nil }
        
        return Fraction(fcpxmlString: value)
    }
    
    func set(fraction newValue: Fraction?, forAttribute attributeName: String) {
        addAttribute(withName: attributeName,
                     value: newValue?.fcpxmlStringValue)
    }
}

extension XMLElement {
    func getBool(forAttribute attributeName: String) -> Bool? {
        guard let value = stringValue(forAttributeNamed: attributeName)
        else { return nil }
        
        switch value {
        case "0": return false
        case "1": return true
        default: return nil
        }
    }
    
    func set(bool newValue: Bool?, forAttribute attributeName: String) {
        guard let newValue = newValue else {
            addAttribute(withName: attributeName, value: nil)
            return
        }
        
        if newValue {
            // addAttribute(withName: "enabled", value: "1")
            // the absence of true implies a default of true
            // so we don't need to store a true value
            addAttribute(withName: attributeName, value: nil)
        } else {
            addAttribute(withName: attributeName, value: "0")
        }
    }
}

extension XMLElement {
    func getInt(forAttribute attributeName: String) -> Int? {
        stringValue(forAttributeNamed: attributeName)?.int
    }
    
    func set(int newValue: Int?, forAttribute attributeName: String) {
        addAttribute(withName: attributeName, value: newValue?.string)
    }
}

#endif
