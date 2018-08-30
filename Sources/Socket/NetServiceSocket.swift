//
//  NetServiceSocket.swift
//  KituraNet
//
//  Created by Bikramjeet Singh on 15/08/18.
//

import Foundation

public class StreamPair: NSObject, SocketReader, SocketWriter, StreamDelegate {
	
	typealias Error = SocketError
	typealias ErrorConstants = SocketError.ErrorConstants
	
    let inputStream:InputStream
    let outputStream:OutputStream
    
    var readSource:DispatchSourceUserDataAdd! = nil
    var writeSource:DispatchSourceUserDataAdd! = nil
    var readEventCounter:UInt = 0
    var writeEventCounter:UInt = 0
    
    var isInputStreamOpen:Bool = false
    var isOutputStreamOpen:Bool = false
    public var isOpen:Bool {
        get {
            return (self.isInputStreamOpen && self.isOutputStreamOpen)
        }
    }
    
    public init(inputStream:InputStream, outputStream:OutputStream) {
        self.inputStream = inputStream
        self.outputStream = outputStream
        super.init()
        
        self.inputStream.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        self.outputStream.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        self.inputStream.delegate = self
        self.outputStream.delegate = self
        self.inputStream.open()
        self.outputStream.open()
    }
    
    deinit {
        self.cancel()
        self.close()
    }
    
    public func createReadDataSource(onQueue queue:DispatchQueue) -> DispatchSourceProtocol {
        self.readSource = DispatchSource.makeUserDataAddSource(queue: queue)
        return self.readSource
    }
    
    public func createWriteDataSource(onQueue queue:DispatchQueue) -> DispatchSourceProtocol {
        self.writeSource = DispatchSource.makeUserDataAddSource(queue: queue)
        return self.writeSource
    }
    
    private func cancel() -> Void {
        if self.readSource != nil {
            self.readSource.cancel()
            self.readSource = nil
        }
        
        if self.writeSource != nil {
            self.writeSource.cancel()
            self.writeSource = nil
        }
    }
    
    public func close() -> Void {
        if self.isInputStreamOpen {
            self.isInputStreamOpen = false
            self.inputStream.close()
        }
        if self.isOutputStreamOpen {
            self.isOutputStreamOpen = false
            self.outputStream.close()
        }
    }
    
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .openCompleted:
            //tell that connection is open now
            print("did open")
            if aStream == self.inputStream {
                self.isInputStreamOpen = true
            }
            else if aStream == self.outputStream {
                self.isOutputStreamOpen = true
            }
        case .hasBytesAvailable:
            //read from input stream
            print("has bytes")
            self.addReadEvent()
        case .hasSpaceAvailable:
            //write to output stream
            print("has space")
            self.addWriteEvent()
        case .errorOccurred:
            print("error occurred")
            aStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            self.cancel()
        case .endEncountered:
            print("end encountered")
            aStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
            self.cancel()
        default:
            print("Unknown event")
        }
    }
    
    func addReadEvent() -> Void {
        if self.readSource != nil {
            print("adding event")
            self.readEventCounter += 1
            self.readSource.add(data: self.readEventCounter)
        }
        else {
            DispatchQueue.main.async {
                self.addReadEvent()
            }
        }
    }
    
    func addWriteEvent() -> Void {
        if self.writeSource != nil {
            print("adding event")
            self.writeEventCounter += 1
            self.writeSource.add(data: self.writeEventCounter)
        }
        else {
            DispatchQueue.main.async {
                self.addWriteEvent()
            }
        }
    }
    
    public func readString() throws -> String? {
        var data:Data = Data()
        _ = try self.read(into: &data)
        
        if let string = String.init(data: data, encoding: .utf8) {
            return string
        }
        else {
            throw Error(code: ErrorConstants.SOCKET_ERR_RECV_FAILED, reason: "Received Data is not convertible to string.")
        }
    }
    
    public func read(into data: inout Data) throws -> Int {
        guard self.isInputStreamOpen else {
            throw Error(code: ErrorConstants.SOCKET_ERR_NOT_CONNECTED, reason: "Input stream is not open")
        }
        var buffer = [UInt8](repeating: 0, count: 1)
        var readLength:Int = 0
        while (self.inputStream.hasBytesAvailable) {
            let bytesRead:Int = self.inputStream.read(&buffer, maxLength: buffer.count)
            if bytesRead >= 0 {
                readLength += bytesRead
                data.append(buffer, count: bytesRead)
            }
        }
        return readLength
    }
    
    public func read(into data: NSMutableData) throws -> Int {
        guard self.isInputStreamOpen else {
            throw Error(code: ErrorConstants.SOCKET_ERR_NOT_CONNECTED, reason: "Input stream is not open")
        }
        var buffer = [UInt8](repeating: 0, count: 1)
        var readLength:Int = 0
        while (self.inputStream.hasBytesAvailable) {
            let bytesRead:Int = self.inputStream.read(&buffer, maxLength: buffer.count)
            if bytesRead >= 0 {
                readLength += bytesRead
                data.append(buffer, length: bytesRead)
            }
        }
        return readLength
    }
    
    public func write(from data: Data) throws -> Int {
        let numberOfBytesWritten = try data.withUnsafeBytes {
            try self.write(from: $0, bufSize: data.count)
        }
        return numberOfBytesWritten
    }
    
    public func write(from data: NSData) throws -> Int {
        return try self.write(from: data as Data)
    }
    
    public func write(from string: String) throws -> Int {
        if let data:Data = string.data(using: .utf8) {
            return try self.write(from: data)
        }
        else {
            throw Error(code: ErrorConstants.SOCKET_ERR_WRITE_FAILED, reason: "Given string is not convertible to Data.")
        }
    }
    
    public func write(from buffer: UnsafeRawPointer, bufSize: Int) throws -> Int {
        guard self.isOutputStreamOpen else {
            throw Error(code: ErrorConstants.SOCKET_ERR_NOT_CONNECTED, reason: "Output stream is not open")
        }
        let numberOfBytesWritten = self.outputStream.write(buffer.assumingMemoryBound(to: UInt8.self), maxLength: bufSize)
        return numberOfBytesWritten
    }
    
}

//MARK: - NetServiceSocket
public class NetServiceSocket: NSObject, NetServiceDelegate, Socketable {
	
	public typealias Signature = SocketSignature
	public typealias Address = SocketSignature.Address
	public typealias ProtocolFamily = SocketSignature.ProtocolFamily
	public typealias SocketType = SocketSignature.SocketType
	public typealias SocketProtocol = SocketSignature.SocketProtocol
	public typealias Error = SocketError
	public typealias ErrorConstants = SocketError.ErrorConstants
	public typealias Defaults = SocketDefaults
    
    static var clientFileDescriptors:Array<Int32> = []
    static var serverFileDescriptors:Array<Int32> = []
    
    public var remoteHostname: String {
        get {
            return (self.isListening ? Defaults.NO_HOSTNAME : ((self.service != nil) ? self.service!.name : Defaults.NO_HOSTNAME))
        }
    }
    
    public var remotePort: Int32 = Defaults.SOCKET_INVALID_PORT
    public var signature: SocketSignature? = nil
    public var delegate: SSLServiceDelegate?
    public var isListening: Bool = false
    public var listeningPort: Int32 {
        get {
            return (self.isListening ? Int32(self.service!.port) : SocketDefaults.SOCKET_INVALID_PORT)
        }
    }
    
    public var socketfd: Int32
    public var remoteConnectionClosed: Bool {
        get {
            return (self.pair == nil)
        }
    }
    
    public func setBlocking(mode: Bool) throws {
        //this is always non-blocking
        if mode == true {
			throw Error(code: ErrorConstants.SOCKET_ERR_NOT_SUPPORTED_YET, reason: "Setting Blocking mode is not suppported")
        }
    }
    
    public func listen(on port: Int, maxBacklogSize: Int, allowPortReuse: Bool) throws {
        self.port = port
        try self.listenForConnections(includingPeer2Peer: true)
    }
    
    public func invokeDelegateOnAcceptP(for: Socketable) throws {
		throw Error(code: ErrorConstants.SOCKET_ERR_NOT_SUPPORTED_YET, reason: "invokeDelegateOnAcceptP is not suppported")
    }
    
    private let readySemaphore = DispatchSemaphore(value: 0)
    private let listenSemaphore = DispatchSemaphore(value: 0)
    private var runloop:RunLoop! = nil
    private var condition:NSCondition = NSCondition.init()
    var newSocket:NetServiceSocket! = nil
    
    public func acceptClientConnectionP(invokeDelegate: Bool) throws -> Socketable {
        self.condition.lock()
        self.readySemaphore.signal()
        self.condition.wait()
        self.condition.unlock()
        //TODO: report to delegates
        return self.newSocket
    }
    
    private(set) var service:NetService?
    
    var isServer:Bool = false
    var name:String?
    private(set) var type:String
    private(set) var domain:String
    var port:Int?
    
    private(set) public var pair:StreamPair?
    public var canWrite:Bool {
        get {
            return self.isServer ? false : self.pair!.outputStream.hasSpaceAvailable
        }
    }
    
    public var canRead:Bool {
        get {
            return self.isServer ? false : self.pair!.inputStream.hasBytesAvailable
        }
    }
    
    //MARK: - initializers
    public init(serverWithName name:String, type:String, domain:String, port:Int) {
        self.type = type
        self.domain = domain
        self.name = name
        self.port = port
        self.isServer = true
        if let lastFileDescriptor = NetServiceSocket.serverFileDescriptors.last {
            self.socketfd = lastFileDescriptor + 1
        }
        else {
            self.socketfd = 0
        }
        NetServiceSocket.serverFileDescriptors.append(self.socketfd)
    }
    
    init(withStreamPair pair:StreamPair, acceptedBySocket serverSocket:NetServiceSocket) {
        self.type = serverSocket.type
        self.domain = serverSocket.domain
        self.pair = pair
        self.port = serverSocket.port
        if let lastFileDescriptor = NetServiceSocket.clientFileDescriptors.last {
            self.socketfd = lastFileDescriptor + 1
        }
        else {
            self.socketfd = 0
        }
        NetServiceSocket.clientFileDescriptors.append(self.socketfd)
    }
    
    public init(withService service:NetService) throws {
        self.service = service
        self.type = service.type
        self.domain = service.domain
        self.remotePort = Int32(service.port)
        self.isServer = false
        if let lastFileDescriptor = NetServiceSocket.clientFileDescriptors.last {
            self.socketfd = lastFileDescriptor + 1
        }
        else {
            self.socketfd = 0
        }
        NetServiceSocket.clientFileDescriptors.append(self.socketfd)
        var inputStream:InputStream?
        var outputStream:OutputStream?
        guard service.getInputStream(&inputStream, outputStream: &outputStream),
            let input:InputStream = inputStream,
            let output:OutputStream = outputStream else {
            throw Error(code: ErrorConstants.SOCKET_ERR_NOT_ACTIVE, reason: "Failed to get input and ouput stream")
        }
        self.pair = StreamPair.init(inputStream: input, outputStream: output)
    }
    
    deinit {
        if self.isServer, let index:Int = NetServiceSocket.serverFileDescriptors.index(of: self.socketfd) {
            NetServiceSocket.serverFileDescriptors.remove(at: index)
        }
        else if let index:Int = NetServiceSocket.clientFileDescriptors.index(of: self.socketfd) {
            NetServiceSocket.clientFileDescriptors.remove(at: index)
        }
    }
    
    //MARK: - Listen
    func listenForConnections(includingPeer2Peer shouldIncludePeer2Peer:Bool) throws -> Void {
        guard let name:String = self.name else {
            throw Error(code: ErrorConstants.SOCKET_ERR_INVALID_HOSTNAME, reason: "Name is not set")
        }
        guard let port:Int = self.port else {
            throw Error(code: ErrorConstants.SOCKET_ERR_INVALID_PORT, reason: "Port is not set")
        }
        guard self.isServer else {
            throw Error(code: ErrorConstants.SOCKET_ERR_LISTEN_FAILED, reason: "Can't listen on a client type socket")
        }
        
        DispatchQueue.main.async {
            self.service = NetService.init(domain: self.domain, type: self.type, name: name, port: Int32(port))
            self.service?.delegate = self
            self.service?.includesPeerToPeer = shouldIncludePeer2Peer
            self.service?.publish(options: [NetService.Options.listenForConnections, NetService.Options.noAutoRename])
        }
        self.listenSemaphore.wait()
    }
    
    //MARK: - handling
    public func close() -> Void {
        self.service?.stop()
        self.pair?.close()
    }
    
    func streamPair() throws -> StreamPair {
		guard let pair:StreamPair = self.pair else {
			throw Error(code: ErrorConstants.SOCKET_ERR_BAD_DESCRIPTOR, reason: "Stream Pair is nil")
		}
        return pair
    }
	
	//MARK: - NetService Delegate
	public func netServiceWillPublish(_ sender: NetService) {
		
	}
	
	public func netServiceWillResolve(_ sender: NetService) {
		
	}
	
	public func netServiceDidResolveAddress(_ sender: NetService) {
		
	}
	
	public func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
		
	}
	
	public func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
		
	}
	
	public func netServiceDidPublish(_ sender: NetService) {
		//TODO: report to delegate
		self.isListening = true
		self.listenSemaphore.signal()
	}
	
	public func netServiceDidStop(_ sender: NetService) {
		//TODO: report to delegate
		self.isListening = false
	}
	
	public func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
		//TODO: report to delegate
		self.listenSemaphore.signal()
	}
	
	public func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
		self.readySemaphore.wait()
		let pair:StreamPair = StreamPair.init(inputStream: inputStream, outputStream: outputStream)
		let socket:NetServiceSocket = NetServiceSocket.init(withStreamPair: pair, acceptedBySocket: self)
		self.newSocket = socket
		self.condition.signal()
	}
    
    public func createReadDataSource(onQueue queue:DispatchQueue) throws -> DispatchSourceProtocol {
        return try self.streamPair().createReadDataSource(onQueue: queue)
    }
    
    public func createWriteDataSource(onQueue queue:DispatchQueue) throws -> DispatchSourceProtocol {
        return try self.streamPair().createWriteDataSource(onQueue: queue)
    }
    
    //MARK: - SocketRead
    ///
    /// Reads a string.
    ///
    /// - Returns: Optional String
    ///
    public func readString() throws -> String? {
        let pair:StreamPair = try self.streamPair()
        return try pair.readString()
    }
    
    ///
    /// Reads all available data into an Data object.
    ///
    /// - Parameter data: Data object to contain read data.
    ///
    /// - Returns: Integer representing the number of bytes read.
    ///
    public func read(into data: inout Data) throws -> Int {
        let pair:StreamPair = try self.streamPair()
        return try pair.read(into: &data)
    }
    
    ///
    /// Reads all available data into an NSMutableData object.
    ///
    /// - Parameter data: NSMutableData object to contain read data.
    ///
    /// - Returns: Integer representing the number of bytes read.
    ///
    public func read(into data: NSMutableData) throws -> Int {
        let pair:StreamPair = try self.streamPair()
        return try pair.read(into: data)
    }
    
    //MARK: - SocketWrite
    ///
    /// Writes data from Data object.
    ///
    /// - Parameter data: Data object containing the data to be written.
    ///
    @discardableResult public func write(from data: Data) throws -> Int {
        let pair:StreamPair = try self.streamPair()
        return try pair.write(from: data)
    }
    
    ///
    /// Writes data from NSData object.
    ///
    /// - Parameter data: NSData object containing the data to be written.
    ///
    @discardableResult public func write(from data: NSData) throws -> Int {
        let pair:StreamPair = try self.streamPair()
        return try pair.write(from: data)
    }
    
    ///
    /// Writes a string
    ///
    /// - Parameter string: String data to be written.
    ///
    @discardableResult public func write(from string: String) throws -> Int {
        let pair:StreamPair = try self.streamPair()
        return try pair.write(from: string)
    }
    
    @discardableResult public func write(from buffer: UnsafeRawPointer, bufSize: Int) throws -> Int {
        let pair:StreamPair = try self.streamPair()
        return try pair.write(from: buffer, bufSize:bufSize)
    }
}
