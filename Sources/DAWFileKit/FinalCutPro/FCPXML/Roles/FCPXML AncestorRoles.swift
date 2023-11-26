//
//  FCPXML AncestorRoles.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

extension FinalCutPro.FCPXML {
    /// Describes ancestors of an element and their interpolated roles.
    public struct AncestorRoles: Equatable, Hashable {
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
        public var roles: Set<FinalCutPro.FCPXML.AnyInterpolatedRole>
        
        public init(
            elementType: FinalCutPro.FCPXML.ElementType,
            roles: Set<FinalCutPro.FCPXML.AnyInterpolatedRole> = []
        ) {
            self.elementType = elementType
            self.roles = roles
        }
    }
}

extension FinalCutPro.FCPXML.AncestorRoles {
    /// Flattens all ancestor roles to produce a set of effective inherited roles for an element.
    /// Includes the source of the role inheritance interpolation.
    public func flattenedInterpolatedRoles() -> Set<FinalCutPro.FCPXML.AnyInterpolatedRole> {
        var outputRoles: Set<FinalCutPro.FCPXML.AnyInterpolatedRole> = []
        
        let elementAudioRoles = elements.flatMap { $0.roles.audioRoles }
        if let audioRole = flatten(singleRoleType: elementAudioRoles) {
            outputRoles.insert(audioRole)
        }
        
        let elementVideoRoles = elements.flatMap { $0.roles.videoRoles }
        if let videoRole = flatten(singleRoleType: elementVideoRoles) {
            outputRoles.insert(videoRole)
        }
        
        let elementCaptionRoles = elements.flatMap { $0.roles.captionRoles }
        if let captionRole = flatten(singleRoleType: elementCaptionRoles) {
            outputRoles.insert(captionRole)
        }
        
        return outputRoles
    }
    
    /// Flattens all ancestor roles to produce a set of effective inherited roles for an element.
    public func flattenedRoles() -> Set<FinalCutPro.FCPXML.AnyRole> {
        Set(flattenedInterpolatedRoles().map(\.wrapped))
    }
    
    /// Only supply a collection containing roles of the same type, ie: only `.audio()` roles.
    /// This favors assigned roles and prevents defaulted roles from overriding them.
    func flatten(
        singleRoleType roles: [FinalCutPro.FCPXML.AnyInterpolatedRole]
    ) -> FinalCutPro.FCPXML.AnyInterpolatedRole? {
        var effectiveRole: FinalCutPro.FCPXML.AnyInterpolatedRole?
        var foundAssigned: Bool = false
        
        for role in roles {
            switch role {
            case .assigned, .inherited:
                effectiveRole = role
                foundAssigned = true
            case .defaulted:
                if !foundAssigned { effectiveRole = role }
            }
        }
        
        return effectiveRole
    }
}

// MARK: - FCPXML Parsing

extension FinalCutPro.FCPXML {
    /// Analyzes an element and its ancestors and returns typed information about their roles.
    static func inheritedRoles(
        of xmlLeaf: XMLElement,
        breadcrumbs: [XMLElement],
        resources: [String: FinalCutPro.FCPXML.AnyResource],
        auditions: Audition.Mask // = .activeAudition
    ) -> AncestorRoles {
        var ancestorRoles = AncestorRoles()
        
        let elements = breadcrumbs + [xmlLeaf]
        
        for index in elements.indices {
            let breadcrumb = elements[index]
            let isLastElement = index == elements.indices.last
            let bcRoles = roles(
                of: breadcrumb,
                resources: resources,
                auditions: auditions
            )
            guard let bcType = ElementType(from: breadcrumb) else { continue }
            
            var defaultedRoles = addDefaultRoles(for: bcType, to: bcRoles)
            
            // differentiate assigned ancestor roles
            if !isLastElement {
                defaultedRoles = defaultedRoles.replaceAssignedRolesWithInherited()
            }
            
            if !defaultedRoles.isEmpty {
                let elementRoles = AncestorRoles.ElementRoles(elementType: bcType, roles: defaultedRoles)
                ancestorRoles.elements.append(elementRoles)
            }
        }
        
        return ancestorRoles
    }
}

extension Set<FinalCutPro.FCPXML.AnyInterpolatedRole> {
    /// Replaces any non-nil roles wrapped in `assigned` cases and re-wraps them in an `inherited`
    /// case instead.
    func replaceAssignedRolesWithInherited() -> Self {
        let roles: [FinalCutPro.FCPXML.AnyInterpolatedRole] = map {
            switch $0 {
            case let .assigned(role):
                return .inherited(role)
            default:
                return $0
            }
        }
        let rolesSet = Set(roles)
        return rolesSet
    }
}

extension FinalCutPro.FCPXML.AncestorRoles.ElementRoles {
    /// Replaces any non-nil roles wrapped in `assigned` cases and re-wraps them in an `inherited`
    /// case instead.
    func replaceAssignedRolesWithInherited() -> Self {
        Self(
            elementType: elementType,
            roles: roles.replaceAssignedRolesWithInherited()
        )
    }
}

#endif
