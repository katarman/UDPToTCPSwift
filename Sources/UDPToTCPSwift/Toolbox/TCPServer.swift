//
//  TCPServer.swift
//  UDPToTCPSwift
//
//  Created by Koray Koska on 7/2/21.
//

import Foundation
import Socket

class TCPServer {

    // MARK: - Properties

    let port: Int
    let socket: Socket
    let listenQueue = DispatchQueue(label: "UDPToTCP.UDP.SocketServer.Listen")
    let writeQueue = DispatchQueue(label: "UDPToTCP.UDP.SocketServer.Write")
    let callbackQueue = DispatchQueue(label: "UDPToTCP.UDP.SocketServer.Callback")

    var messageCallback: ((_ data: Data, _ from: Socket) -> Void)?



    private(set) var shouldRun: Bool

    // MARK: - Initialization

    required init(port: Int) throws {
        self.port = port

        let socket = try Socket.create(family: .inet, type: .stream, proto: .tcp)
        try socket.listen(on: port, node: "0.0.0.0")
        self.socket = socket

        self.shouldRun = true

        setupListener()
    }

    // MARK: - Public API

    func send(data: Data, to socket: Socket) throws {
        let _ = try writeQueue.sync {
            return try socket.write(from: data)
        }
    }

    func stop() {
        socket.close()
        shouldRun = false
    }

    // MARK: - Helpers

    private func setupListener() {
        listenQueue.async {
            while self.shouldRun && self.socket.isActive {
                if let s = try? self.socket.acceptClientConnection() {

                }
            }

            self.stop()
        }
    }
}
