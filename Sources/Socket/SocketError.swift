//
//  SocketError.swift
//  BlueSocket
//
//  Created by Bikramjeet Singh on 18/08/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

public struct SocketError: Swift.Error, CustomStringConvertible {
	
	public struct ErrorConstants {
		public static let SOCKET_ERR_DOMAIN						= "com.ibm.oss.Socket.ErrorDomain"
		
		public static let SOCKET_ERR_UNABLE_TO_CREATE_SOCKET    = -9999
		public static let SOCKET_ERR_BAD_DESCRIPTOR				= -9998
		public static let SOCKET_ERR_ALREADY_CONNECTED			= -9997
		public static let SOCKET_ERR_NOT_CONNECTED				= -9996
		public static let SOCKET_ERR_NOT_LISTENING				= -9995
		public static let SOCKET_ERR_ACCEPT_FAILED				= -9994
		public static let SOCKET_ERR_SETSOCKOPT_FAILED			= -9993
		public static let SOCKET_ERR_BIND_FAILED				= -9992
		public static let SOCKET_ERR_INVALID_HOSTNAME			= -9991
		public static let SOCKET_ERR_INVALID_PORT				= -9990
		public static let SOCKET_ERR_GETADDRINFO_FAILED			= -9989
		public static let SOCKET_ERR_CONNECT_FAILED				= -9988
		public static let SOCKET_ERR_MISSING_CONNECTION_DATA	= -9987
		public static let SOCKET_ERR_SELECT_FAILED				= -9986
		public static let SOCKET_ERR_LISTEN_FAILED				= -9985
		public static let SOCKET_ERR_INVALID_BUFFER				= -9984
		public static let SOCKET_ERR_INVALID_BUFFER_SIZE		= -9983
		public static let SOCKET_ERR_RECV_FAILED				= -9982
		public static let SOCKET_ERR_RECV_BUFFER_TOO_SMALL		= -9981
		public static let SOCKET_ERR_WRITE_FAILED				= -9980
		public static let SOCKET_ERR_GET_FCNTL_FAILED			= -9979
		public static let SOCKET_ERR_SET_FCNTL_FAILED			= -9978
		public static let SOCKET_ERR_NOT_IMPLEMENTED			= -9977
		public static let SOCKET_ERR_NOT_SUPPORTED_YET			= -9976
		public static let SOCKET_ERR_BAD_SIGNATURE_PARAMETERS	= -9975
		public static let SOCKET_ERR_INTERNAL					= -9974
		public static let SOCKET_ERR_WRONG_PROTOCOL				= -9973
		public static let SOCKET_ERR_NOT_ACTIVE					= -9972
		public static let SOCKET_ERR_CONNECTION_RESET			= -9971
		public static let SOCKET_ERR_SET_RECV_TIMEOUT_FAILED	= -9970
		public static let SOCKET_ERR_SET_WRITE_TIMEOUT_FAILED	= -9969
		public static let SOCKET_ERR_CONNECT_TIMEOUT			= -9968
		public static let SOCKET_ERR_GETSOCKOPT_FAILED			= -9967
		public static let SOCKET_ERR_INVALID_DELEGATE_CALL		= -9966
		public static let SOCKET_ERR_MISSING_SIGNATURE			= -9965
		public static let SOCKET_ERR_PARAMETER_ERROR			= -9964
	}
	
	///
	/// The error domain.
	///
	public let domain: String = ErrorConstants.SOCKET_ERR_DOMAIN
	
	///
	/// The error code: **see constants above for possible errors** (Readonly)
	///
	public internal(set) var errorCode: Int32
	
	///
	/// The reason for the error **(if available)** (Readonly)
	///
	public internal(set) var errorReason: String?
	
	///
	/// Returns a string description of the error. (Readonly)
	///
	public var description: String {
		
		let reason: String = self.errorReason ?? "Reason: Unavailable"
		return "Error code: \(self.errorCode)(0x\(String(self.errorCode, radix: 16, uppercase: true))), \(reason)"
	}
	
	///
	/// The buffer size needed to complete the read. (Readonly)
	///
	public internal(set) var bufferSizeNeeded: Int32
	
	// MARK: -- Public Functions
	
	///
	/// Initializes an Error Instance
	///
	/// - Parameters:
	///		- code:		Error code
	/// 	- reason:	Optional Error Reason
	///
	/// - Returns: Error instance
	///
	init(code: Int, reason: String?) {
		
		self.errorCode = Int32(code)
		self.errorReason = reason
		self.bufferSizeNeeded = 0
	}
	
	///
	/// Initializes an Error Instance for a too small receive buffer error.
	///
	///	- Parameter bufferSize:	Required buffer size
	///
	///	- Returns: Error Instance
	///
	init(bufferSize: Int) {
		
		self.init(code: ErrorConstants.SOCKET_ERR_RECV_BUFFER_TOO_SMALL, reason: "Socket has an invalid buffer, the size is too small")
		self.bufferSizeNeeded = Int32(bufferSize)
	}
	
	///
	/// Initializes an Error instance using SSLError
	///
	/// - Parameter error: SSLError instance to be transformed
	///
	/// - Returns: Error Instance
	init(with error: SSLError) {
		
		self.init(code: error.errCode, reason: error.description)
	}
}
