//
//  FCPXMLEffectElement.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

import Foundation

// TODO: will likely factor this out, as it does not align with the DTD's structure.

/// FCPXML adjustment and effects elements.
///
/// - Audio Adjustment Elements
///   - `adjust-EQ`
///   - `adjust-humReduction`
///   - `adjust-loudness`
///   - `adjust-matchEQ`
///   - `adjust-noiseReduction`
///   - `adjust-panner`
///   - `adjust-volume`
/// - Video Adjustment Elements
///   - `adjust-blend`
///   - `adjust-cinematic`
///   - `adjust-conform`
///   - `adjust-corners`
///   - `adjust-crop`
///   - `adjust-rollingShutter`
///   - `adjust-stabilization`
///   - `adjust-transform`
/// - 360 Adjustment Elements
///   - `adjust-360-transform`
///   - `adjust-orientation`
///   - `adjust-reorient`
/// - `transition`
/// - `title`
///   - `text`
///   - `text-style`
///     - `text-style-def`
/// - `caption`
/// - `filter-audio`
/// - `filter-video`
/// - Masked Filters
///   - `mask-isolation`
///   - `mask-shape`
/// - Adjustment Attributes and Effect Parameters (see Apple FCPXML Reference)
/// - Animation
///   - `keyframeAnimation`
///
/// > Final Cut Pro FCPXML 1.11 Reference:
/// >
/// > See [this topic](
/// > https://developer.apple.com/documentation/professional_video_applications/fcpxml_reference/story_elements
/// > ).
// public protocol FCPXMLEffectElement { }

#endif
