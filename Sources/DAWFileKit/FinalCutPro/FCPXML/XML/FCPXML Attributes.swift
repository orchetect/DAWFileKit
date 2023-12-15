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
    /// FCPXML: Get or set the value of the `format` attribute.
    public var fcpFormat: String? {
        get { stringValue(forAttributeNamed: "format") }
        set { addAttribute(withName: "format", value: newValue) }
    }
    
    /// FCPXML: Get or set the value of the `id` attribute.
    public var fcpID: String? {
        get { stringValue(forAttributeNamed: "id") }
        set { addAttribute(withName: "id", value: newValue) }
    }
    
    /// FCPXML: Get or set the value of the `uid` attribute.
    public var fcpUID: String? {
        get { stringValue(forAttributeNamed: "uid") }
        set { addAttribute(withName: "uid", value: newValue) }
    }
    
    /// FCPXML: Get or set the value of the `name` attribute.
    public var fcpName: String? {
        get { stringValue(forAttributeNamed: "name") }
        set { addAttribute(withName: "name", value: newValue) }
    }
    
    /// FCPXML: Get or set the value of the `note` attribute.
    public var fcpNote: String? {
        get { stringValue(forAttributeNamed: "note") }
        set { addAttribute(withName: "note", value: newValue) }
    }
    
    /// FCPXML: Get or set the value of the `ref` attribute.
    public var fcpRef: String? {
        get { stringValue(forAttributeNamed: "ref") }
        set { addAttribute(withName: "ref", value: newValue) }
    }
    
    /// FCPXML: Get or set the value of the `src` attribute.
    public var fcpSRC: String? {
        get { stringValue(forAttributeNamed: "src") }
        set { addAttribute(withName: "src", value: newValue) }
    }
    
    /// FCPXML: Get or set the value of the `value` attribute.
    public var fcpValue: String? {
        get { stringValue(forAttributeNamed: "value") }
        set { addAttribute(withName: "value", value: newValue) }
    }
}

// MARK: - Time Attributes

extension XMLElement {
    /// FCPXML: Get or set the value of the `audioStart` attribute.
    /// Use on `asset-clip`, `clip`, `mc-clip`, `ref-clip` or `sync-clip`.
    public var fcpAudioStart: Fraction? {
        get { _fcpGetFraction(forAttribute: "audioStart") }
        set { _fcpSet(fraction: newValue, forAttribute: "audioStart") }
    }
    
    /// FCPXML: Get or set the value of the `audioDuration` attribute.
    /// Use on `asset-clip`, `clip`, `mc-clip`, `ref-clip` or `sync-clip`.
    public var fcpAudioDuration: Fraction? {
        get { _fcpGetFraction(forAttribute: "audioDuration") }
        set { _fcpSet(fraction: newValue, forAttribute: "audioDuration") }
    }
    
    /// FCPXML: Get or set the value of the `duration` attribute.
    public var fcpDuration: Fraction? {
        get { _fcpGetFraction(forAttribute: "duration") }
        set { _fcpSet(fraction: newValue, forAttribute: "duration") }
    }
    
    /// FCPXML: Get or set the value of the `frameDuration` attribute.
    public var fcpFrameDuration: Fraction? {
        get { _fcpGetFraction(forAttribute: "frameDuration") }
        set { _fcpSet(fraction: newValue, forAttribute: "frameDuration") }
    }
    
    /// FCPXML: Get or set the value of the `start` attribute.
    public var fcpStart: Fraction? {
        get { _fcpGetFraction(forAttribute: "start") }
        set { _fcpSet(fraction: newValue, forAttribute: "start") }
    }
    
    /// FCPXML: Get or set the value of the `tcStart` attribute.
    public var fcpTCStart: Fraction? {
        get { _fcpGetFraction(forAttribute: "tcStart") }
        set { _fcpSet(fraction: newValue, forAttribute: "tcStart") }
    }
    
    /// FCPXML: Get or set the value of the `offset` attribute.
    public var fcpOffset: Fraction? {
        get { _fcpGetFraction(forAttribute: "offset") }
        set { _fcpSet(fraction: newValue, forAttribute: "offset") }
    }
    
    /// FCPXML: Get or set the value of the `tcFormat` attribute.
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
    /// FCPXML: Get the value of the `active` attribute.
    public func fcpGetActive(default defaultValue: Bool) -> Bool {
        getBool(forAttribute: "active") ?? defaultValue
    }
    
    /// FCPXML: Set the value of the `active` attribute.
    /// Removes the attribute if the new value equals the default value.
    public func fcpSet(active newValue: Bool?, default defaultValue: Bool) {
        _fcpSet(
            bool: newValue,
            forAttribute: "active",
            defaultValue: defaultValue,
            removeIfDefault: true
        )
    }
}

extension XMLElement {
    /// FCPXML: Get the value of the `enabled` attribute.
    public func fcpGetEnabled(default defaultValue: Bool) -> Bool {
        getBool(forAttribute: "enabled") ?? defaultValue
    }
    
    /// FCPXML: Set the value of the `enabled` attribute.
    /// Removes the attribute if the new value equals the default value.
    public func fcpSet(enabled newValue: Bool?, default defaultValue: Bool) {
        _fcpSet(
            bool: newValue,
            forAttribute: "enabled",
            defaultValue: defaultValue,
            removeIfDefault: true
        )
    }
}

extension XMLElement {
    /// FCPXML: Get or set the value of the `role` attribute.
    public var fcpLane: Int? {
        get { getInt(forAttribute: "lane") }
        set { set(int: newValue, forAttribute: "lane") }
    }
}

// MARK: - Role Attributes

extension XMLElement {
    /// FCPXML: Get the value of the `role` attribute as a specific role type.
    public func fcpRole<R: FCPXMLRole>(as roleType: R.Type) -> R? {
        guard let value = stringValue(forAttributeNamed: "role")
        else { return nil }
        
        return R(rawValue: value)
    }
    
    /// FCPXML: Set the value of the `role` attribute.
    public func fcpSet<R: FCPXMLRole>(role: R?) {
        addAttribute(withName: "role", value: role?.rawValue)
    }
    
    /// FCPXML: Get or set the value of the `audioRole` attribute.
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
    
    /// FCPXML: Get or set the value of the `videoRole` attribute.
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

// MARK: - Internal Helpers

extension XMLElement {
    /// FCPXML: Get an attribute time value as a `Fraction` instance.
    func _fcpGetFraction(forAttribute attributeName: String) -> Fraction? {
        guard let value = stringValue(forAttributeNamed: attributeName)
        else { return nil }
        
        return Fraction(fcpxmlString: value)
    }
    
    /// FCPXML: Set an attribute time value from a `Fraction` instance.
    func _fcpSet(fraction newValue: Fraction?, forAttribute attributeName: String) {
        addAttribute(withName: attributeName,
                     value: newValue?.fcpxmlStringValue)
    }
}

extension XMLElement {
    /// FCPXML: Set a `Bool` attribute value.
    func _fcpSet(
        bool newValue: Bool?,
        forAttribute attributeName: String,
        defaultValue: Bool,
        removeIfDefault: Bool
    ) {
        set(
            bool: newValue,
            forAttribute: attributeName,
            defaultValue: defaultValue,
            removeIfDefault: removeIfDefault,
            useInt: true // FCPXML always uses "1" or "0"
        )
    }
}

#endif
