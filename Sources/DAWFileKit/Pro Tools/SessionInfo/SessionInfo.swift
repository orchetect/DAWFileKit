//
//  SessionInfo.swift
//  DAWFileKit • https://github.com/orchetect/DAWFileKit
//

import TimecodeKit

// MARK: - ProTools.SessionInfo

extension ProTools {
    
    /// Contains parsed data after reading a Pro Tools Session Info text file.
    public struct SessionInfo {
        
        // MARK: Contents
        
        /// Meta data contained in the main header of the data file.
        public var main = Main()
        
        /// Files listing (online).
        public var onlineFiles: [File]?
        
        /// Files listing (offline).
        public var offlineFiles: [File]?
        
        /// Clips listing (online).
        public var onlineClips: [Clip]?
        
        /// Clips listing (offline).
        public var offlineClips: [Clip]?
        
        /// Plugin listing.
        public var plugins: [Plugin]?
        
        /// Tracks listing.
        public var tracks: [Track]?
        
        /// Markers listing.
        public var markers: [Marker]?
        
        /// Holds any extraneous sections or data that was not recognized while parsing the file.
        public var orphanData: [(heading: String, content: [String])]?
        
        // MARK: Constants
        
        /// Array of file types for use with NSOpenPanel / NSSavePanel
        public static let fileTypes = ["public.txt" ,"txt"]
        
    }
    
}

extension ProTools.SessionInfo {
    
    /// Contains the global session meta data
    /// (from the Session Info Text file header)
    public struct Main {
        
        public var name: String?
        public var sampleRate: Double?
        public var bitDepth: String?
        public var startTimecode: Timecode?
        public var frameRate: Timecode.FrameRate?
        public var audioTrackCount: Int?
        public var audioClipCount: Int?
        public var audioFileCount: Int?
        
    }
    
    /// Represents a file used in the session
    public struct File {
        
        var filename: String = ""
        var path: String = ""
        
        /// Flag determining if file was online (true) or offline (false)
        var online: Bool = true
        
    }
    
    /// Represents a clip used in the session
    public struct Clip {
        
        var name: String = ""
        var sourceFile: String = ""
        var channel: String? = nil
        
        /// Flag determining if clip was online (true) or offline (false)
        var online: Bool = true
        
    }
    
    /// Represents a plug-in used in the session
    public struct Plugin {
        
        var manufacturer: String = ""
        var name: String = ""
        var version: String = ""
        var format: String = ""
        var stems: String = ""
        var numberOfInstances: String = ""
        
    }
    
    /// Represents a track and its contents
    public struct Track {
        
        public var name: String = ""
        public var comments: String = ""
        
        public var userDelay: Int = 0
        
        public var state: Set<State> = []
        
        /// A track's state
        public enum State: String {
            
            case inactive	= "Inactive"
            case hidden		= "Hidden"
            case muted		= "Muted"
            case solo		= "Solo"
            case soloSafe	= "SoloSafe"
            
        }
        
        public var plugins: [String] = []
        
        public var clips: [Clip] = []
        
        /// Represents a clip contained on a track.
        public struct Clip {
            
            public var channel: Int = 0
            public var event: Int = 0
            public var name: String = ""
            public var startTimecode: Timecode?
            public var endTimecode: Timecode?
            public var duration: Timecode?
            public var state: State = .unmuted
            
            /// A clip's state (such as 'Muted', 'Unmuted')
            public enum State: String {
                
                // ***** there may be more states possible than this -- need to test
                case muted		= "Muted"
                case unmuted	= "Unmuted"
                
            }
            
        }
        
    }
    
    /// Represents a single marker and its related info
    public struct Marker {
        
        public var number: Int?
        
        public var timecode: Timecode?
        
        public var timeReference: String = ""
        
        public enum Units {
            case samples
            case ticks
        }
        
        public var units: Units = .samples
        
        public var name: String = ""
        public var comment: String?
        
        // init
        
        public init() { }
        
        public init(number: Int? = nil,
                    timecode: Timecode? = nil,
                    timeReference: String = "",
                    units: Units = .samples,
                    name: String = "",
                    comment: String? = nil) {
            
            self.number = number
            self.timecode = timecode
            self.timeReference = timeReference
            self.units = units
            self.name = name
            self.comment = comment
        }
        
        /// Convenience function - instances an `Timecode` to the `timecode` property and returns true if timecode is valid.
        mutating func validate(timecodeString: String,
                               at frameRate: Timecode.FrameRate) -> Bool {
            
            timecode = ProTools.kTimecode(timecodeString, at: frameRate)
            
            return timecode != nil
            
        }
        
    }
    
}
