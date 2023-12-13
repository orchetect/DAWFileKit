//
//  FCPXML AncestorRoles.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation
import OTCore

extension FinalCutPro.FCPXML {
    /// Describes ancestors of an element and their interpolated roles.
    public struct AncestorRoles: Equatable, Hashable {
        /// Element roles, ordered from nearest to furthest ancestor.
        public var elements: [ElementRoles]
        
        public init(elements: [ElementRoles] = []) {
            self.elements = elements
        }
    }
}
extension FinalCutPro.FCPXML.AncestorRoles {
    /// Describes an ancestor element and its interpolated roles.
    public struct ElementRoles: Equatable, Hashable {
        public var elementType: FinalCutPro.FCPXML.ElementType
        public var roles: [FinalCutPro.FCPXML.AnyInterpolatedRole]
        
        public init(
            elementType: FinalCutPro.FCPXML.ElementType,
            roles: [FinalCutPro.FCPXML.AnyInterpolatedRole] = []
        ) {
            self.elementType = elementType
            self.roles = roles
        }
    }
}

extension FinalCutPro.FCPXML.AncestorRoles {
    /// Flattens all ancestor roles to produce a set of effective inherited roles for an element.
    /// Includes the source of the role inheritance interpolation.
    public func flattenedInterpolatedRoles() -> [FinalCutPro.FCPXML.AnyInterpolatedRole] {
        var outputRoles: [FinalCutPro.FCPXML.AnyInterpolatedRole] = []
        
        let elementVideoRoles = elements.map { $0.roles.videoRoles() }
        let videoRoles = _flatten(singleRoleType: elementVideoRoles)
        outputRoles.append(contentsOf: videoRoles)
        
        let elementAudioRoles = elements.map { $0.roles.audioRoles() }
        let audioRoles = _flatten(singleRoleType: elementAudioRoles)
        outputRoles.append(contentsOf: audioRoles)
        
        let elementCaptionRoles = elements.map { $0.roles.captionRoles() }
        let captionRoles = _flatten(singleRoleType: elementCaptionRoles)
        outputRoles.append(contentsOf: captionRoles)
        
        outputRoles.removeDuplicates()
        
        return outputRoles
    }
    
    /// Flattens all ancestor roles to produce a set of effective inherited roles for an element.
    public func flattenedRoles() -> [FinalCutPro.FCPXML.AnyRole] {
        flattenedInterpolatedRoles().map(\.wrapped)
    }
    
    /// Only supply a collection containing roles of the same type, ie: only `.audio()` roles.
    /// This favors assigned roles and prevents defaulted roles from overriding them.
    func _flatten(
        singleRoleType elementsRoles: [[FinalCutPro.FCPXML.AnyInterpolatedRole]]
    ) -> [FinalCutPro.FCPXML.AnyInterpolatedRole] {
        var effectiveRoles: [FinalCutPro.FCPXML.AnyInterpolatedRole] = []
        
        func containsAssignedOrInherited(_ roles: [FinalCutPro.FCPXML.AnyInterpolatedRole]) -> Bool {
            roles.contains(where: \.isAssigned) ||
            roles.contains(where: \.isInherited)
        }
        
        // it's possible for an element to have more than one valid audio role.
        // ie: `sync-clip` can have `sync-source` with more than one `audio-role-source`
        // and FCP shows them all in a comma-separated list for Audio Role,
        // ie: "Dialogue.MixL" and "Dialogue.MixR" shown in GUI as "MixL, MixR" for Audio Role
        // but both roles are selected in the drop-down role menu of course.
        for elementRoles in elementsRoles.reversed() {
            if containsAssignedOrInherited(elementRoles) {
                effectiveRoles.removeAll()
            }
            
            for role in elementRoles {
                switch role {
                case .assigned, .inherited:
                    effectiveRoles.append(role)
                case .defaulted:
                    if !containsAssignedOrInherited(effectiveRoles) {
                        effectiveRoles.append(role)
                    }
                }
            }
        }
        
        return effectiveRoles
    }
}

// MARK: - FCPXML Parsing

extension XMLElement {
    /// FCPXML: Analyzes an element and its ancestors and returns typed information about their roles.
    ///
    /// Ancestors are ordered nearest to furthest.
    func _fcpInheritedRoles(
        ancestors: [XMLElement],
        resources: XMLElement? = nil,
        auditions: FinalCutPro.FCPXML.Audition.AuditionMask, // = .activeAudition
        mcClipAngles: FinalCutPro.FCPXML.MCClip.AngleMask // = .active
    ) -> FinalCutPro.FCPXML.AncestorRoles {
        var ancestorRoles = FinalCutPro.FCPXML.AncestorRoles()
        
        // reversed to get ordering of furthest ancestor to closest
        let elements = ([self] + ancestors).reversed()
        
        // print(elements.map(\.name!))
        
        // iterate from furthest ancestor to closest
        for index in elements.indices {
            let breadcrumb = elements[index]
            let isLastElement = index == elements.indices.last // self
            var bcRoles = breadcrumb._fcpLocalRoles(
                resources: resources,
                auditions: auditions,
                mcClipAngles: mcClipAngles
            )
            
            guard let bcType = breadcrumb.fcpElementType else { continue }
            
            bcRoles = FinalCutPro.FCPXML.addDefaultRoles(for: bcType, to: bcRoles)
            
            // differentiate assigned ancestor roles
            if !isLastElement {
                bcRoles = bcRoles._fcpReplacingAssignedRolesWithInherited()
            }
            
            if !bcRoles.isEmpty {
                let elementRoles = FinalCutPro.FCPXML.AncestorRoles.ElementRoles(
                    elementType: bcType, 
                    roles: bcRoles
                )
                ancestorRoles.elements.insert(elementRoles, at: 0)
            }
        }
        
        // print(ancestorRoles.elements.map {
        //     $0.elementType.rawValue + ": " + $0.roles.map(\.wrapped).map(\.rawValue).joined(separator: " - ")
        // })
        
        return ancestorRoles
    }
}

extension Sequence where Element == FinalCutPro.FCPXML.AnyInterpolatedRole {
    /// Replaces any non-nil roles wrapped in `assigned` cases and re-wraps them in an `inherited`
    /// case instead.
    func _fcpReplacingAssignedRolesWithInherited() -> [Element] {
        let roles: [FinalCutPro.FCPXML.AnyInterpolatedRole] = map {
            switch $0 {
            case let .assigned(role):
                return .inherited(role)
            default:
                return $0
            }
        }
        return roles
    }
}

extension FinalCutPro.FCPXML.AncestorRoles.ElementRoles {
    /// Replaces any non-nil roles wrapped in `assigned` cases and re-wraps them in an `inherited`
    /// case instead.
    func _fcpReplacingAssignedRolesWithInherited() -> Self {
        Self(
            elementType: elementType,
            roles: roles._fcpReplacingAssignedRolesWithInherited()
        )
    }
}

#endif
