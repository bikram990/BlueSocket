//
//  SocketSignature.swift
//  BlueSocket
//
//  Created by Bikramjeet Singh on 18/08/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

///
/// Socket signature: contains the characteristics of the socket.
///
public struct SocketSignature: CustomStringConvertible {
	
	// MARK: -- ProtocolFamily
	
	///
	/// Socket Protocol Family Values
	///
	/// **Note:** Only the following are supported at this time:
	///			inet = AF_INET (IPV4)
	///			inet6 = AF_INET6 (IPV6)
	///			unix = AF_UNIX
	///
	public enum ProtocolFamily {
		
		/// AF_INET (IPV4)
		case inet
		
		/// AF_INET6 (IPV6)
		case inet6
		
		/// AF_UNIX
		case unix
		
		///
		/// Return the value for a particular case. (Readonly)
		///
		var value: Int32 {
			
			switch self {
				
			case .inet:
				return Int32(AF_INET)
				
			case .inet6:
				return Int32(AF_INET6)
				
			case .unix:
				return Int32(AF_UNIX)
			}
		}
		///
		/// Return enum equivalent of a raw value
		///
		/// - Parameter forValue: Value for which enum value is desired
		///
		/// - Returns: Optional contain enum value or nil
		///
		static func getFamily(forValue: Int32) -> ProtocolFamily? {
			
			switch forValue {
				
			case Int32(AF_INET):
				return .inet
			case Int32(AF_INET6):
				return .inet6
			case Int32(AF_UNIX):
				return .unix
			default:
				return nil
			}
		}
		
	}
	
	// MARK: -- SocketType
	
	///
	/// Socket Type Values
	///
	/// **Note:** Only the following are supported at this time:
	///			stream = SOCK_STREAM (Provides sequenced, reliable, two-way, connection-based byte streams.)
	///			datagram = SOCK_DGRAM (Supports datagrams (connectionless, unreliable messages of a fixed maximum length).)
	///
	public enum SocketType {
		
		/// SOCK_STREAM (Provides sequenced, reliable, two-way, connection-based byte streams.)
		case stream
		
		/// SOCK_DGRAM (Supports datagrams (connectionless, unreliable messages of a fixed maximum length).)
		case datagram
		
		///
		/// Return the value for a particular case. (Readonly)
		///
		var value: Int32 {
			
			switch self {
				
			case .stream:
				#if os(Linux)
				return Int32(SOCK_STREAM.rawValue)
				#else
				return SOCK_STREAM
				#endif
			case .datagram:
				#if os(Linux)
				return Int32(SOCK_DGRAM.rawValue)
				#else
				return SOCK_DGRAM
				#endif
			}
		}
		
		///
		/// Return enum equivalent of a raw value
		///
		/// - Parameter forValue: Value for which enum value is desired
		///
		/// - Returns: Optional contain enum value or nil
		///
		static func getType(forValue: Int32) -> SocketType? {
			
			#if os(Linux)
			switch forValue {
				
			case Int32(SOCK_STREAM.rawValue):
				return .stream
			case Int32(SOCK_DGRAM.rawValue):
				return .datagram
			default:
				return nil
			}
			#else
			switch forValue {
				
			case SOCK_STREAM:
				return .stream
			case SOCK_DGRAM:
				return .datagram
			default:
				return nil
			}
			#endif
		}
	}
	
	// MARK: -- SocketProtocol
	
	///
	/// Socket Protocol Values
	///
	/// **Note:** Only the following are supported at this time:
	///			tcp = IPPROTO_TCP
	///			udp = IPPROTO_UDP
	///			unix = Unix Domain Socket (raw value = 0)
	///
	public enum SocketProtocol: Int32 {
		
		/// IPPROTO_TCP
		case tcp
		
		/// IPPROTO_UDP
		case udp
		
		/// Unix Domain
		case unix
		
		///
		/// Return the value for a particular case. (Readonly)
		///
		var value: Int32 {
			
			switch self {
				
			case .tcp:
				return Int32(IPPROTO_TCP)
			case .udp:
				return Int32(IPPROTO_UDP)
			case .unix:
				return Int32(0)
			}
		}
		
		///
		/// Return enum equivalent of a raw value
		///
		/// - Parameter forValue: Value for which enum value is desired
		///
		/// - Returns: Optional contain enum value or nil
		///
		static func getProtocol(forValue: Int32) -> SocketProtocol? {
			
			switch forValue {
				
			case Int32(IPPROTO_TCP):
				return .tcp
			case Int32(IPPROTO_UDP):
				return .udp
			case Int32(0):
				return .unix
			default:
				return nil
			}
		}
	}
	
	// MARK: -- Socket Address
	
	///
	/// Socket Address
	///
	public enum Address {
		
		/// sockaddr_in
		case ipv4(sockaddr_in)
		
		/// sockaddr_in6
		case ipv6(sockaddr_in6)
		
		/// sockaddr_un
		case unix(sockaddr_un)
		
		///
		/// Size of address. (Readonly)
		///
		public var size: Int {
			
			switch self {
				
			case .ipv4( _):
				return MemoryLayout<(sockaddr_in)>.size
			case .ipv6( _):
				return MemoryLayout<(sockaddr_in6)>.size
			case .unix( _):
				return MemoryLayout<(sockaddr_un)>.size
			}
		}
		
		public var family: ProtocolFamily {
			switch self {
			case .ipv4(_):
				return ProtocolFamily.inet
			case .ipv6(_):
				return ProtocolFamily.inet6
			case .unix(_):
				return ProtocolFamily.unix
			}
		}
	}
	
	// MARK: -- Public Properties
	
	///
	/// Protocol Family
	///
	public internal(set) var protocolFamily: ProtocolFamily
	
	///
	/// Socket Type. (Readonly)
	///
	public internal(set) var socketType: SocketType
	
	///
	/// Socket Protocol. (Readonly)
	///
	public internal(set) var proto: SocketProtocol
	
	///
	/// Host name for connection. (Readonly)
	///
	public internal(set) var hostname: String? = Socket.Defaults.NO_HOSTNAME
	
	///
	/// Port for connection. (Readonly)
	///
	public internal(set) var port: Int32 = Socket.Defaults.SOCKET_INVALID_PORT
	
	///
	/// Path for .unix type sockets. (Readonly)
	public internal(set) var path: String? = nil
	
	///
	/// Address info for socket. (Readonly)
	///
	public internal(set) var address: Address? = nil
	
	///
	/// Flag to indicate whether `Socket` is secure or not. (Readonly)
	///
	public internal(set) var isSecure: Bool = false
	
	///
	/// True is socket bound, false otherwise.
	///
	public internal(set) var isBound: Bool = false
	
	///
	/// Returns a string description of the error.
	///
	public var description: String {
		
		return "Signature: family: \(protocolFamily), type: \(socketType), protocol: \(proto), address: \(address as Address?), hostname: \(hostname as String?), port: \(port), path: \(String(describing: path)), bound: \(isBound), secure: \(isSecure)"
	}
	
	// MARK: -- Public Functions
	
	///
	/// Create a socket signature
	///
	/// - Parameters:
	///		- protocolFamily:	The family of the socket to create.
	///		- socketType:		The type of socket to create.
	///		- proto:			The protocool to use for the socket.
	/// 	- address:			Address info for the socket.
	///
	/// - Returns: New Signature instance
	///
	public init?(protocolFamily: Int32, socketType: Int32, proto: Int32, address: Address?) throws {
		
		guard let family = ProtocolFamily.getFamily(forValue: protocolFamily),
			let type = SocketType.getType(forValue: socketType),
			let pro = SocketProtocol.getProtocol(forValue: proto) else {
				
				throw SocketError(code: SocketError.ErrorConstants.SOCKET_ERR_BAD_SIGNATURE_PARAMETERS, reason: "Bad family, type or protocol passed.")
		}
		
		// Validate the parameters...
		if type == .stream {
			guard pro == .tcp || pro == .unix else {
				
				throw SocketError(code: SocketError.ErrorConstants.SOCKET_ERR_BAD_SIGNATURE_PARAMETERS, reason: "Stream socket must use either .tcp or .unix for the protocol.")
			}
		}
		if type == .datagram {
			guard pro == .udp || pro == .unix else {
				
				throw SocketError(code: SocketError.ErrorConstants.SOCKET_ERR_BAD_SIGNATURE_PARAMETERS, reason: "Datagram socket must use .udp or .unix for the protocol.")
			}
		}
		
		self.protocolFamily = family
		self.socketType = type
		self.proto = pro
		
		self.address = address
		
	}
	
	///
	/// Create a socket signature
	///
	///	- Parameters:
	///		- protocolFamily:	The protocol family to use (only `.inet` and `.inet6` supported by this `init` function).
	///		- socketType:		The type of socket to create.
	///		- proto:			The protocool to use for the socket.
	/// 	- hostname:			Hostname for this signature.
	/// 	- port:				Port for this signature.
	///
	/// - Returns: New Signature instance
	///
	public init?(protocolFamily: ProtocolFamily, socketType: SocketType, proto: SocketProtocol, hostname: String?, port: Int32?) throws {
		
		// Make sure we have what we need...
		guard let _ = hostname,
			let port = port, protocolFamily == .inet || protocolFamily == .inet6 else {
				
				throw SocketError(code: SocketError.ErrorConstants.SOCKET_ERR_BAD_SIGNATURE_PARAMETERS, reason: "Missing hostname, port or both or invalid protocol family.")
		}
		
		self.protocolFamily = protocolFamily
		
		// Validate the parameters...
		if socketType == .stream {
			guard proto == .tcp || proto == .unix else {
				
				throw SocketError(code: SocketError.ErrorConstants.SOCKET_ERR_BAD_SIGNATURE_PARAMETERS, reason: "Stream socket must use either .tcp or .unix for the protocol.")
			}
		}
		if socketType == .datagram {
			guard proto == .udp || proto == .unix else {
				
				throw SocketError(code: SocketError.ErrorConstants.SOCKET_ERR_BAD_SIGNATURE_PARAMETERS, reason: "Datagram socket must use .udp or .unix for the protocol.")
			}
		}
		
		self.socketType = socketType
		self.proto = proto
		
		self.hostname = hostname
		self.port = port
	}
	
	///
	/// Create a socket signature
	///
	///	- Parameters:
	///		- socketType:		The type of socket to create.
	///		- proto:			The protocool to use for the socket.
	/// 	- path:				Pathname for this signature.
	///
	/// - Returns: New Signature instance
	///
	public init?(socketType: SocketType, proto: SocketProtocol, path: String?) throws {
		
		// Make sure we have what we need...
		guard let path = path, !path.isEmpty else {
			
			throw SocketError(code: SocketError.ErrorConstants.SOCKET_ERR_BAD_SIGNATURE_PARAMETERS, reason: "Missing pathname.")
		}
		
		// Default to Unix socket protocol family...
		self.protocolFamily = .unix
		
		self.socketType = socketType
		self.proto = proto
		
		// Validate the parameters...
		if socketType == .stream {
			guard proto == .tcp || proto == .unix else {
				
				throw SocketError(code: SocketError.ErrorConstants.SOCKET_ERR_BAD_SIGNATURE_PARAMETERS, reason: "Stream socket must use either .tcp or .unix for the protocol.")
			}
		}
		if socketType == .datagram {
			guard proto == .udp || proto == .unix else {
				
				throw SocketError(code: SocketError.ErrorConstants.SOCKET_ERR_BAD_SIGNATURE_PARAMETERS, reason: "Datagram socket must use .udp or .unix for the protocol.")
			}
		}
		
		self.path = path
		
		// Create the address...
		var remoteAddr = sockaddr_un()
		remoteAddr.sun_family = sa_family_t(AF_UNIX)
		
		let lengthOfPath = path.utf8.count
		
		// Validate the length...
		guard lengthOfPath < MemoryLayout.size(ofValue: remoteAddr.sun_path) else {
			
			throw SocketError(code: SocketError.ErrorConstants.SOCKET_ERR_BAD_SIGNATURE_PARAMETERS, reason: "Pathname supplied is too long.")
		}
		
		var remote = remoteAddr.sun_path.0
		_ = withUnsafeMutablePointer(to: &remote) { ptr in
			
			let buf = UnsafeMutableBufferPointer(start: ptr, count: MemoryLayout.size(ofValue: remoteAddr.sun_path))
			for (i, b) in path.utf8.enumerated() {
				buf[i] = Int8(b)
			}
		}
		
		#if !os(Linux)
		remoteAddr.sun_len = UInt8(MemoryLayout<UInt8>.size + MemoryLayout<sa_family_t>.size + path.utf8.count + 1)
		#endif
		
		self.address = .unix(remoteAddr)
	}
	
	///
	/// Create a socket signature
	///
	/// - Parameters:
	///		- protocolFamily:	The family of the socket to create.
	///		- socketType:		The type of socket to create.
	///		- proto:			The protocool to use for the socket.
	/// 	- address:			Address info for the socket.
	/// 	- hostname:			Hostname for this signature.
	/// 	- port:				Port for this signature.
	///
	/// - Returns: New Signature instance
	///
	internal init?(protocolFamily: Int32, socketType: Int32, proto: Int32, address: Address?, hostname: String?, port: Int32?) throws {
		
		// This constructor requires all items be present...
		guard let family = ProtocolFamily.getFamily(forValue: protocolFamily),
			let type = SocketType.getType(forValue: socketType),
			let pro = SocketProtocol.getProtocol(forValue: proto),
			let _ = hostname,
			let port = port else {
				
				throw SocketError(code: SocketError.ErrorConstants.SOCKET_ERR_BAD_SIGNATURE_PARAMETERS, reason: "Incomplete parameters.")
		}
		
		self.protocolFamily = family
		self.socketType = type
		self.proto = pro
		
		// Validate the parameters...
		if type == .stream {
			guard pro == .tcp || pro == .unix else {
				
				throw SocketError(code: SocketError.ErrorConstants.SOCKET_ERR_BAD_SIGNATURE_PARAMETERS, reason: "Stream socket must use either .tcp or .unix for the protocol.")
			}
		}
		if type == .datagram {
			guard pro == .udp else {
				
				throw SocketError(code: SocketError.ErrorConstants.SOCKET_ERR_BAD_SIGNATURE_PARAMETERS, reason: "Datagram socket must use .udp for the protocol.")
			}
		}
		
		self.address = address
		
		self.hostname = hostname
		self.port = port
	}
	
	///
	///	Retrieve the UNIX address as an UnsafeMutablePointer
	///
	///	- Returns: Tuple containing the pointer plus the size.  **Needs to be deallocated after use.**
	///
	internal func unixAddress() throws -> (UnsafeMutablePointer<UInt8>, Int) {
		
		// Throw an exception if the path is not set...
		if path == nil {
			
			throw SocketError(code: SocketError.ErrorConstants.SOCKET_ERR_BAD_SIGNATURE_PARAMETERS, reason: "Specified path contains zero (0) bytes.")
		}
		
		let utf8 = path!.utf8
		
		// macOS has a size identifier in front, Linux does not...
		#if os(Linux)
		let addrLen = MemoryLayout<sockaddr_un>.size
		#else
		let addrLen = MemoryLayout<UInt8>.size + MemoryLayout<sa_family_t>.size + utf8.count + 1
		#endif
		let addrPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: addrLen)
		
		var memLoc = 0
		
		// macOS uses one byte for sa_family_t, Linux uses two...
		#if os(Linux)
		let afUnixShort = UInt16(AF_UNIX)
		addrPtr[memLoc] = UInt8(afUnixShort & 0xFF)
		memLoc += 1
		addrPtr[memLoc] = UInt8((afUnixShort >> 8) & 0xFF)
		memLoc += 1
		#else
		addrPtr[memLoc] = UInt8(addrLen)
		memLoc += 1
		addrPtr[memLoc] = UInt8(AF_UNIX)
		memLoc += 1
		#endif
		
		// Copy the pathname...
		for char in utf8 {
			addrPtr[memLoc] = char
			memLoc += 1
		}
		
		addrPtr[memLoc] = 0
		
		return (addrPtr, addrLen)
	}
	
}
