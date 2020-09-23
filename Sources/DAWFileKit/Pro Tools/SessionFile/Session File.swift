//
//  ProTools/SessionFile/Session File.swift
//  DAWFileKit
//
//  Created by Steffan Andrews on 2018-11-02.
//  Copyright © 2018 Steffan Andrews. All rights reserved.
//

import Foundation

#warning("> this code is experimental; not fully tested")

extension ProTools {
	
	/// Attempts to decrypt a Pro Tools session file. Pass the raw contents of the file in, and the decrypted contents will be returned. Returns nil in case of failure.
	/// Derived from open-source code found at https://github.com/zamaudio/ptformat (GNU license)
	public func decryptPTSessionFile(contents: Data) -> Data? {
		
		var ptfunxored: Data = Data()
		ptfunxored.reserveCapacity(contents.count)	// size data block to same size as input data
		
		// The first 20 bytes are always unencrypted
		ptfunxored = contents.prefix(0x14)
		
		// Check minimum length
		if ptfunxored.count < 0x14 { return nil }
		
		let xor_type = Int(ptfunxored[0x12])
		let xor_value = Int(ptfunxored[0x13])
		let xor_len = 256
		
		var xor_delta = 0
		
		// xor_type 0x01 = ProTools 5, 6, 7, 8 and 9
		// xor_type 0x05 = ProTools 10, 11, 12
		switch xor_type {
		case 0x01:
			xor_delta = gen_xor_delta(xorValue: xor_value, mul: 53, negative: false);
		case 0x05:
			xor_delta = gen_xor_delta(xorValue: xor_value, mul: 11, negative: true);
		default:
			return nil
		}
		
		var xxor = [Int](repeating: 0, count: xor_len)
		
		// Generate the xor_key
		for i in 0..<xor_len {
			xxor[i] = (i * xor_delta) & 0xff
		}
		
		var xor_index: Int = 0
		var dataOffset: Int = 0x14
		
		// Read file and decrypt rest of file
		for byte in contents.suffix(from: dataOffset) {
			xor_index = (xor_type == 0x01) ? (dataOffset & 0xff) : (dataOffset >> 12) & 0xff
			guard let decryptedByte = UInt8(exactly: Int(byte) ^ xxor[xor_index]) // xor, not exponent power
				else { return nil }
			
			ptfunxored.append(decryptedByte)
			dataOffset += 1
		}
		
		return ptfunxored
		
	}
	
	/// Helper func for decryptPTSessionFile
	private func gen_xor_delta(xorValue: Int, mul: Int, negative: Bool) -> Int {
		
		for i in 0...255 {
			if (((i * mul) & 0xff) == xorValue) {
				return negative ? i * -1 : i
			}
		}
		
		// shouldn't happen
		print("gen_xor_delta: Returned without finding XOR reference value. This shouldn't happen. File decryption may not have succeeded.")
		return 0
		
	}

}
