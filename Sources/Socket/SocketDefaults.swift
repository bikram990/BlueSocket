//
//  SocketDefaults.swift
//  BlueSocket
//
//  Created by Bikramjeet Singh on 19/08/18.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

public struct SocketDefaults {
	public static let SOCKET_MINIMUM_READ_BUFFER_SIZE		= 1024
	public static let SOCKET_DEFAULT_READ_BUFFER_SIZE		= 4096
	public static let SOCKET_DEFAULT_SSL_READ_BUFFER_SIZE	= 32768
	public static let SOCKET_MAXIMUM_SSL_READ_BUFFER_SIZE	= 8000000
	public static let SOCKET_DEFAULT_MAX_BACKLOG			= 50
	#if os(macOS) || os(iOS) || os(tvOS)
	public static let SOCKET_MAX_DARWIN_BACKLOG				= 128
	#endif
	
	public static let SOCKET_INVALID_PORT					= Int32(0)
	public static let SOCKET_INVALID_DESCRIPTOR 			= Int32(-1)
	
	public static let INADDR_ANY							= in_addr_t(0)
	
	public static let NO_HOSTNAME							= "No hostname"
}
