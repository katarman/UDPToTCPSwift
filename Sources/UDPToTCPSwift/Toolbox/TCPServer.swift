//
//  TCPServer.swift
//  UDPToTCPSwift
//
//  Created by Koray Koska on 7/2/21.
//

import Foundation
import Socket

//struct TCPServer: SocketServer {
//
//    // MARK: - Properties
//
//    let port: Int
//    let socket: Socket
//    let listenQueue = DispatchQueue(label: "UDPToTCP.UDP.SocketServer.Listen")
//    let writeQueue = DispatchQueue(label: "UDPToTCP.UDP.SocketServer.Write")
//    let callbackQueue = DispatchQueue(label: "UDPToTCP.UDP.SocketServer.Callback")
//
//    var messageCallback: ((_ data: Data, _ from: Socket.Address?) -> Void)?
//
//    private var shouldRun: Bool
//
//    // MARK: - Initialization
//
//    init(port: Int) throws {
//        self.port = port
//
//        let socket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
//        self.socket = socket
//
//        self.shouldRun = true
//
//        setupListener()
//    }
//
//    // MARK: - Public API
//
//    func send(data: Data, to address: Socket.Address) throws {
//        let _ = try writeQueue.sync {
//            return try socket.write(from: data, to: address)
//        }
//    }
//
//    mutating func stop() {
//        socket.close()
//        shouldRun = false
//    }
//
//    // MARK: - Helpers
//
//    private func setupListener() {
//        listenQueue.async {
//            while self.shouldRun {
//                var data = Data()
//                if let ret = try? self.socket.listen(forMessage: &data, on: self.port) {
//                    callbackQueue.async {
//                        self.messageCallback?(data, ret.address)
//                    }
//                }
//            }
//        }
//    }
//}
