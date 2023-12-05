//
//  FCPXML Attributes.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import TimecodeKit
import OTCore

// MARK: - Basic Attributes

extension XMLElement {
    /// Get or set the value of the `format` attribute.
    public var fcpFormat: String? {
        get { stringValue(forAttributeNamed: "format") }
        set { addAttribute(withName: "format", value: newValue) }
    }
    
    /// Get or set the value of the `id` attribute.
    public var fcpID: String? {
        get { stringValue(forAttributeNamed: "id") }
        set { addAttribute(withName: "id", value: newValue) }
    }
    
    /// Get or set the value of the `uid` attribute.
    public var fcpUID: String? {
        get { stringValue(forAttributeNamed: "uid") }
        set { addAttribute(withName: "uid", value: newValue) }
    }
    
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
    
    /// Get or set the value of the `ref` attribute.
    public var fcpRef: String? {
        get { stringValue(forAttributeNamed: "ref") }
        set { addAttribute(withName: "ref", value: newValue) }
    }
    
    /// Get or set the value of the `src` attribute.
    public var fcpSRC: String? {
        get { stringValue(forAttributeNamed: "src") }
        set { addAttribute(withName: "src", value: newValue) }
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
    
    /// Get or set the value of the `frameDuration` attribute.
    public var fcpFrameDuration: Fraction? {
        get { getFraction(forAttribute: "frameDuration") }
        set { set(fraction: newValue, forAttribute: "frameDuration") }
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
    
    /// Get or set the value of the `tcFormat` attribute.
    public var fcpTCFormat: FinalCutPro.FCPXML.TimecodeFormat? {
        get {
            guard let value = stringValue(forAttributeNamed: "tcFormat")
            else { return nil }
            
            return FinalCutPro.FCPXML.TimecodeFormat(rawValue: value)
        }
        set {
            addAttribute(withName: "tcFormat", value: newValue?.rawValue)
        }
    }
}

// MARK: - Timeline Attributes

extension XMLElement {
    /// Get or set the value of the `active` attribute.
    public var fcpActive: Bool? {
        get { getBool(forAttribute: "active") }
        set { set(bool: newValue, forAttribute: "active") }
    }
    
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
    /// Get the value of the `role` attribute as a specific role type.
    public func fcpRole<R: FCPXMLRole>(as roleType: R.Type) -> R? {
        guard let value = stringValue(forAttributeNamed: "role")
        else { return nil }
        
        return R(rawValue: value)
    }
    
    /// Set the value of the `role` attribute.
    public func fcpSet<R: FCPXMLRole>(role: R?) {
        addAttribute(withName: "role", value: role?.rawValue)
    }
    
    /// Get or set the value of the `audioRole` attribute.
    public var fcpAudioRole: FinalCutPro.FCPXML.AudioRole? {
        get {
            guard let value = stringValue(forAttributeNamed: "audioRole")
            else { return nil }
            
            return FinalCutPro.FCPXML.AudioRole(rawValue: value)
        }
        set { 
            addAttribute(withName: "audioRole", value: newValue?.rawValue)
        }
    }
    
    /// Get or set the value of the `videoRole` attribute.
    public var fcpVideoRole: FinalCutPro.FCPXML.VideoRole? {
        get {
            guard let value = stringValue(forAttributeNamed: "videoRole")
            else { return nil }
            
            return FinalCutPro.FCPXML.VideoRole(rawValue: value)
        }
        set {
            addAttribute(withName: "videoRole", value: newValue?.rawValue)
        }
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

extension XMLElement {
    func getURL(forAttribute attributeName: String) -> URL? {
        guard let value = stringValue(forAttributeNamed: attributeName)
        else { return nil }
        return URL(string: value)
    }
    
    func set(url newValue: URL?, forAttribute attributeName: String) {
        addAttribute(withName: attributeName, value: newValue?.absoluteString)
    }
    
    // TODO: differentiate absolute URL from relative URL?
}

#endif
