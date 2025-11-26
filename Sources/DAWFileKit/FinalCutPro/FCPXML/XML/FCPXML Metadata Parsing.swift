//
//  FCPXML Metadata Parsing.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2024 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import SwiftExtensions

// MARK: - Metadata Contents

extension XMLElement {
    /// FCPXML:
    /// When called on a `metadata` element, returns the first child `md` element with the given
    /// metadata `key`.
    func _fcpMetadataChild(forKey key: FinalCutPro.FCPXML.Metadata.Key) -> XMLElement? {
        _fcpMetadataChild(forKey: key.rawValue)
    }
    
    /// FCPXML:
    /// When called on a `metadata` element, returns the first child `md` element with the given
    /// metadata `key`.
    @_disfavoredOverload
    func _fcpMetadataChild(forKey key: String) -> XMLElement? {
        childElements
            .first(whereAttribute: "key", hasValue: key)
    }
}

extension XMLElement {
    /// When called on a `metadata` element, returns the `value` attribute for the first child `md`
    /// element with the given metadata `key`.
    /// Note: Only call this for metadata keys that are known to have a string value.
    func _fcpMetadataChildStringValue(forKey key: FinalCutPro.FCPXML.Metadata.Key) -> String? {
        _fcpMetadataChildStringValue(forKey: key.rawValue)
    }
    
    /// When called on a `metadata` element, returns the `value` attribute for the first child `md`
    /// element with the given metadata `key`.
    /// Note: Only call this for metadata keys that are known to have a string value.
    @_disfavoredOverload
    func _fcpMetadataChildStringValue(forKey key: String) -> String? {
        childElements
            .first(whereAttribute: "key", hasValue: key)?
            .fcpValue
    }
}

extension XMLElement {
    /// FCPXML:
    /// When called on a `metadata` element, returns the interior string array for the first child
    /// `md` element with the given metadata `key`.
    /// Note: Only call this for metadata keys that are known to have a string array.
    ///
    /// - Returns: Array if the `md` child element exists. Returns nil if the `md` child
    ///   does not exist.
    func _fcpMetadataChildStringArrayValue(
        forKey key: FinalCutPro.FCPXML.Metadata.Key
    ) -> [String]? {
        _fcpMetadataChildStringArrayValue(forKey: key.rawValue)
    }
    
    /// FCPXML:
    /// When called on a `metadata` element, returns the interior string array for the first child
    /// `md` element with the given metadata `key`.
    /// Note: Only call this for metadata keys that are known to have a string array.
    ///
    /// - Returns: Array if the `md` child element exists. Returns nil if the `md` child
    ///   does not exist.
    @_disfavoredOverload
    func _fcpMetadataChildStringArrayValue(
        forKey key: String
    ) -> [String]? {
        childElements
            .first(whereAttribute: "key", hasValue: key)?
            ._getFirstChildStringArray()
    }
}

extension XMLElement {
    /// FCPXML:
    /// When called on a `metadata` element, updates the string value for the first child `md`
    /// element with the given metadata `key`.
    /// If the child exists, its value will be updated.
    /// If the child does not exist, it will be created.
    /// If the new value is nil, the child will be removed if it exists.
    func _fcpUpdateMetadataChild(
        forKey key: FinalCutPro.FCPXML.Metadata.Key,
        with newValue: String?
    ) {
        _fcpUpdateMetadataChild(forKey: key.rawValue, with: newValue)
    }
    
    /// FCPXML:
    /// When called on a `metadata` element, updates the string value for the first child `md`
    /// element with the given metadata `key`.
    /// If the child exists, its value will be updated.
    /// If the child does not exist, it will be created.
    /// If the new value is nil, the child will be removed if it exists.
    func _fcpUpdateMetadataChild(
        forKey key: String,
        with newValue: String?
    ) {
        // should only be called on `metadata` XML elements
        guard self.name == "metadata" else { return }
        
        if let newValue {
            // non-nil value
            
            if let existingMDElement = childElements
                .filter(whereElementNamed: "md")
                .first(whereAttribute: "key", hasValue: key)
            {
                existingMDElement.fcpValue = newValue
            } else {
                let newMDElement = XMLElement(
                    name: "md",
                    attributes: [
                        (name: "key", value: key),
                        (name: "value", value: newValue),
                    ]
                )
                addChild(newMDElement)
            }
        } else {
            // nil value
            
            // remove `md` child(s) if any exist.
            // only one per key should exist, but all matching the key will be deleted as a failsafe.
            removeChildren { child in
                child.name == "md"
                && child.stringValue(forAttributeNamed: "key") == key
            }
        }
    }
}

extension XMLElement {
    /// FCPXML:
    /// When called on a `metadata` element, updates the child string array for the first child `md`
    /// element with the given metadata `key`.
    /// If the child exists, its contents will be updated.
    /// If the child does not exist, it will be created.
    /// If the new array is empty or nil, the child will be removed if it exists.
    func _fcpUpdateMetadataChild(
        forKey key: FinalCutPro.FCPXML.Metadata.Key,
        with newArray: [String]?
    ) {
        _fcpUpdateMetadataChild(forKey: key.rawValue, with: newArray)
    }
    
    /// FCPXML:
    /// When called on a `metadata` element, updates the child string array for the first child `md`
    /// element with the given metadata `key`.
    /// If the child exists, its contents will be updated.
    /// If the child does not exist, it will be created.
    /// If the new array is empty or nil, the child will be removed if it exists.
    func _fcpUpdateMetadataChild(
        forKey key: String,
        with newArray: [String]?
    ) {
        // should only be called on `metadata` XML elements
        guard self.name == "metadata" else { return }
        
        if let newArray, !newArray.isEmpty {
            // contains one or more values
            
            // this will be non-nil if the `md` child already exists
            var mdElement: XMLElement? = childElements
                .filter(whereElementNamed: "md")
                .first(whereAttribute: "key", hasValue: key)
            
            // otherwise, create `md` child if needed
            if mdElement == nil {
                // `md` child
                let newMDElement = XMLElement(
                    name: "md",
                    attributes: [
                        (name: "key", value: key)
                    ]
                )
                addChild(newMDElement)
                
                // update local reference
                mdElement = newMDElement
            }
            
            // grab `md` child strong reference
            guard let mdElement else { return }
            
            mdElement._setFirstChildStringArray(newArray)
            
        } else {
            // contains no values
            
            // remove `md` child(s) if any exist.
            // only one per key should exist, but all matching the key will be deleted as a failsafe.
            removeChildren { child in
                child.name == "md"
                && child.stringValue(forAttributeNamed: "key") == key
            }
        }
    }
}

// MARK: - XML Utilities

extension XMLElement {
    /// Returns the first `array` child element with each element mapped to its XML string value.
    /// Returns `nil` if the array does not exist.
    func _getFirstChildStringArray() -> [String]? {
        firstChildElement(named: "array")?
            .children?
            .compactMap(\.stringValue)
    }
    
    /// Sets the contents of the first `array` child element by updating the existing array if
    /// found, or adds a new array if necessary.
    /// Removes the array if the new array is nil.
    func _setFirstChildStringArray(_ newArray: [String]?) {
        guard let newArray else {
            // remove array if new array is nil
            removeChildren { child in
                child.name == "array"
            }
            return
        }
        
        // if existing array is found, empty it
        let existingArrayElement = firstChildElement(named: "array")
        if let existingArrayElement {
            existingArrayElement.removeAllChildren()
        }
        
        // point to existing array or create new array if needed
        let arrayElement = existingArrayElement ?? {
            let newArrayElement = XMLElement(name: "array")
            addChild(newArrayElement)
            return newArrayElement
        }()
        
        // add array elements
        for newArrayString in newArray {
            let newArrayElement = XMLElement()
            newArrayElement.stringValue = newArrayString
            arrayElement.addChild(newArrayElement)
        }
    }
}

#endif
