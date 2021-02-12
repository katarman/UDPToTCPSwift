//
//  UDPServer.swift
//  UDPToTCPSwift
//
//  Created by Koray Koska on 7/2/21.
//

import Foundation
import Socket

class UDPServer {

    // MARK: - Properties

    let port: Int
    let socket: Socket
    let listenQueue = DispatchQueue(label: "UDPToTCP.UDP.SocketServer.Listen")
    let writeQueue = DispatchQueue(label: "UDPToTCP.UDP.SocketServer.Write")
    let callbackQueue = DispatchQueue(label: "UDPToTCP.UDP.SocketServer.Callback")

    var messageCallback: ((_ data: Data, _ from: Socket.Address?) -> Void)?

    private(set) var shouldRun: Bool

    // MARK: - Initialization

    required init(port: Int) throws {
        self.port = port

        let socket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
        try socket.listen(on: port, node: "0.0.0.0")
        try socket.setReadTimeout(value: 1000)
        self.socket = socket

        self.shouldRun = true

        setupListener()
    }

    // MARK: - Public API

    func send(data: Data, to address: Socket.Address) throws {
        let _ = try writeQueue.sync {
            return try socket.write(from: data, to: address)
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
                var data = Data()
                if let ret = try? self.socket.readDatagram(into: &data) {
                    if ret.bytesRead <= 0 {
                        if errno == EAGAIN {
                            // Timeout occured. Try again.
                            continue
                        } else {
                            self.stop()
                        }
                    } else {
                        self.callbackQueue.async {
                            self.messageCallback?(data, ret.address)
                        }
                    }
                } else {
                    self.stop()
                }
            }

            self.stop()
        }
    }
}
