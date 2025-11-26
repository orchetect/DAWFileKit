//
//  SRTFile Time Utilities Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileTools
import SwiftExtensions
import Testing
import TimecodeKitCore

@Suite struct SRTFileTimeUtilitiesTests {
    @Test
    func parseSRTTimestamp_Strict() {
        // invalid strings
        #expect(Time(srtEncodedString: "", strict: true) == nil)
        #expect(Time(srtEncodedString: " ", strict: true) == nil)
        #expect(Time(srtEncodedString: "asdf", strict: true) == nil)
        #expect(Time(srtEncodedString: "ab:cd:ef,ghi", strict: true) == nil)
        #expect(Time(srtEncodedString: "0", strict: true) == nil)
        
        // invalid milliseconds separator
        #expect(Time(srtEncodedString: "00:00:00.000", strict: true) == nil)
        #expect(Time(srtEncodedString: "00:00:00:000", strict: true) == nil)
        #expect(Time(srtEncodedString: "01:20:14.213", strict: true) == nil)
        #expect(Time(srtEncodedString: "01:20:14:213", strict: true) == nil)
        
        // invalid padding
        #expect(Time(srtEncodedString: "00:00:00,0", strict: true) == nil)
        #expect(Time(srtEncodedString: "00:00:00,00", strict: true) == nil)
        #expect(Time(srtEncodedString: "00:00:00,0000", strict: true) == nil)
        #expect(Time(srtEncodedString: "0:00:00,000", strict: true) == nil)
        #expect(Time(srtEncodedString: "0:0:00,000", strict: true) == nil)
        #expect(Time(srtEncodedString: "0:0:0,000", strict: true) == nil)
        #expect(Time(srtEncodedString: "1:20:14,213", strict: true) == nil)
        
        // superfluous whitespace
        #expect(Time(srtEncodedString: "00:00:00,000 ", strict: true) == nil)
        #expect(Time(srtEncodedString: " 00:00:00,000", strict: true) == nil)
        #expect(Time(srtEncodedString: " 00:00:00,000 ", strict: true) == nil)
        #expect(Time(srtEncodedString: "00:00:00, 000", strict: true) == nil)
        #expect(Time(srtEncodedString: "01:20:14,213 ", strict: true) == nil)
        #expect(Time(srtEncodedString: " 01:20:14,213", strict: true) == nil)
        #expect(Time(srtEncodedString: " 01:20:14,213 ", strict: true) == nil)
        #expect(Time(srtEncodedString: "01:20:14, 213", strict: true) == nil)
        
        // valid
        #expect(Time(srtEncodedString: "00:00:00,000", strict: true) == .zero)
        #expect(Time(srtEncodedString: "01:20:14,213", strict: true)
            == Time(hours: 1, minutes: 20, seconds: 14, milliseconds: 213)
        )
    }
    
    @Test
    func parseSRTTimestamp_NonStrict() {
        // invalid strings
        #expect(Time(srtEncodedString: "", strict: false) == nil)
        #expect(Time(srtEncodedString: " ", strict: false) == nil)
        #expect(Time(srtEncodedString: "asdf", strict: false) == nil)
        #expect(Time(srtEncodedString: "ab:cd:ef,ghi", strict: false) == nil)
        #expect(Time(srtEncodedString: "0", strict: false) == nil)
        
        // non-standard milliseconds separator
        #expect(Time(srtEncodedString: "00:00:00.000", strict: false) == .zero)
        #expect(Time(srtEncodedString: "00:00:00:000", strict: false) == nil) // `:` should never separate sec from ms
        
        // non-standard padding
        #expect(Time(srtEncodedString: "00:00:00,0", strict: false) == .zero)
        #expect(Time(srtEncodedString: "00:00:00,00", strict: false) == .zero)
        #expect(Time(srtEncodedString: "00:00:00,0000", strict: false) == nil) // ms should never be > 3 digits
        #expect(Time(srtEncodedString: "0:00:00,000", strict: false) == .zero)
        #expect(Time(srtEncodedString: "0:0:00,000", strict: false) == .zero)
        #expect(Time(srtEncodedString: "0:0:0,0", strict: false) == .zero)
        #expect(Time(srtEncodedString: "0:0:0,00", strict: false) == .zero)
        #expect(Time(srtEncodedString: "0:0:0,000", strict: false) == .zero)
        
        // superfluous whitespace
        #expect(Time(srtEncodedString: "00:00:00,000 ", strict: false) == .zero)
        #expect(Time(srtEncodedString: " 00:00:00,000", strict: false) == .zero)
        #expect(Time(srtEncodedString: " 00:00:00,000 ", strict: false) == .zero)
        #expect(Time(srtEncodedString: "00:00:00, 000", strict: false) == .zero)
        #expect(Time(srtEncodedString: "0:0:0, 0", strict: false) == .zero)
        #expect(Time(srtEncodedString: "0:0:0, 00", strict: false) == .zero)
        #expect(Time(srtEncodedString: "0:0:0, 000", strict: false) == .zero)
        #expect(Time(srtEncodedString: "0:0:0, 0", strict: false) == .zero)
        #expect(Time(srtEncodedString: "0 : 0 : 0, 0", strict: false) == .zero)
        #expect(Time(srtEncodedString: "0 : 0 : 0 , 0", strict: false) == .zero)
        #expect(Time(srtEncodedString: " 0  :  0  :  0  ,  0 ", strict: false) == .zero)
        
        // valid
        #expect(Time(srtEncodedString: "00:00:00,000", strict: false) == .zero)
        
        let time = Time(hours: 1, minutes: 20, seconds: 14, milliseconds: 213)
        #expect(Time(srtEncodedString: "01:20:14,213", strict: false) == time)
        #expect(Time(srtEncodedString: "01;20;14.213", strict: false) == time)
        #expect(Time(srtEncodedString: " 01:20:14,213", strict: false) == time)
        #expect(Time(srtEncodedString: " 01;20;14.213", strict: false) == time)
        #expect(Time(srtEncodedString: "01:20:14,213 ", strict: false) == time)
        #expect(Time(srtEncodedString: "01;20;14.213 ", strict: false) == time)
        #expect(Time(srtEncodedString: " 01:20:14,213 ", strict: false) == time)
        #expect(Time(srtEncodedString: " 01;20;14.213 ", strict: false) == time)
        #expect(Time(srtEncodedString: "1:20:14,213", strict: false) == time)
        #expect(Time(srtEncodedString: "1;20;14.213", strict: false) == time)
        #expect(Time(srtEncodedString: "1:020:014,213", strict: false) == time)
        #expect(Time(srtEncodedString: "1;020;014.213", strict: false) == time)
        #expect(Time(srtEncodedString: "001:020:014,213", strict: false) == time)
        #expect(Time(srtEncodedString: "001;020;014.213", strict: false) == time)
        #expect(Time(srtEncodedString: "001 : 020 : 014 , 213", strict: false) == time)
        #expect(Time(srtEncodedString: "001 ; 020 ; 014 . 213", strict: false) == time)
        
        // edge cases
        #expect(Time(srtEncodedString: "00:00:18,1234", strict: false) == nil) // ms should never be > 3 digits
        #expect(Time(srtEncodedString: "00;00;18.1234", strict: false) == nil) // ms should never be > 3 digits
    }
}
