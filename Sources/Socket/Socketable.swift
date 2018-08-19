//
//  Socketable.swift
//  Call-for-Code-macOS
//
//  Created by Bikramjeet Singh on 17/07/18.
//  Copyright © 2018 Bikram990. All rights reserved.
//

import Foundation

public protocol Socketable: SocketReader, SocketWriter {
    var remoteHostname:String { get }
    var remotePort:Int32 { get }
    var signature:SocketSignature? { get }
    var delegate:SSLServiceDelegate? { get set }
    var isListening:Bool { get }
    var listeningPort:Int32 { get }
    var socketfd:Int32 { get }
    var remoteConnectionClosed:Bool { get }
    
    func acceptClientConnectionP(invokeDelegate:Bool) throws -> Socketable
    func setBlocking(mode:Bool) throws
    func listen(on port:Int, maxBacklogSize:Int, allowPortReuse:Bool) throws
    func invokeDelegateOnAcceptP(for: Socketable) throws
    func close()
    
    func write(from buffer: UnsafeRawPointer, bufSize: Int) throws -> Int
    
    func createReadDataSource(onQueue queue:DispatchQueue) throws -> DispatchSourceProtocol
    func createWriteDataSource(onQueue queue:DispatchQueue) throws -> DispatchSourceProtocol
}

extension Socketable {
    func acceptClientConnectionP() throws -> Socketable {
        return try self.acceptClientConnectionP(invokeDelegate: true)
    }
}

extension Socket: Socketable {
    public func createReadDataSource(onQueue queue:DispatchQueue) throws -> DispatchSourceProtocol {
        return DispatchSource.makeReadSource(fileDescriptor: self.socketfd,
                                             queue: queue)
    }
    
    public func createWriteDataSource(onQueue queue:DispatchQueue) throws -> DispatchSourceProtocol {
        return DispatchSource.makeWriteSource(fileDescriptor: self.socketfd,
                                              queue: queue)
    }
    
    public func acceptClientConnectionP(invokeDelegate: Bool) throws -> Socketable {
        return try self.acceptClientConnection(invokeDelegate: invokeDelegate)
    }
    
    public func invokeDelegateOnAcceptP(for socket: Socketable) throws {
        try self.invokeDelegateOnAccept(for: socket as! Socket)
    }
}
