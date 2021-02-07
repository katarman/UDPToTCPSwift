//
//  TCPClientOrganizer.swift
//  UDPToTCPSwift
//
//  Created by Koray Koska on 7/2/21.
//

import Foundation
import Socket
import Logging
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

class TCPCLientOrganizer {

    let logger: Logger?

    private var registeredClients: [Socket.Address: Socket] = [:]

    init(logger: Logger? = nil) {
        self.logger = logger
    }

    func register(tcp: Socket, for address: Socket.Address) {
        registeredClients[address] = tcp
    }

    func delete(for address: Socket.Address) {
        registeredClients[address] = nil
    }

    func get(for address: Socket.Address) -> Socket? {
        return registeredClients[address]
    }

    func clean() {
        for (_, v) in registeredClients {
            v.close()
        }
    }

    func registerReadCallback(for address: Socket.Address, callback: @escaping (_ data: Data) -> Void) {
        let queue = DispatchQueue(label: "TCPCLientOrganizer.ReadCallback")

        queue.async {
            while let socket = self.registeredClients[address] {
                var data = Data()
                let ret = try? socket.read(into: &data)
                if (ret == nil || ret == 0) && socket.remoteConnectionClosed {
                    socket.close()
                    self.delete(for: address)
                    self.logger?.debug("TCP Connection was closed by the Server")
                } else {
                    callback(data)
                }
            }
        }
    }
}

extension Socket.Address: Hashable, Equatable {
    public static func == (lhs: Socket.Address, rhs: Socket.Address) -> Bool {
        switch lhs {
        case .ipv4(let sock):
            switch rhs {
            case .ipv4(let sockR):
                return sock == sockR
            default:
                return false
            }
        case .ipv6(let sock):
            switch rhs {
            case .ipv6(let sockR):
                return sock == sockR
            default:
                return false
            }
        case .unix(let sock):
            switch rhs {
            case .unix(let sockR):
                return sock == sockR
            default:
                return false
            }
        }
    }

    public func hash(into hasher: inout Hasher) {
        switch self {
        case .ipv4(let sock):
            hasher.combine(sock)
        case .ipv6(let sock):
            hasher.combine(sock)
        case .unix(let sock):
            hasher.combine(sock)
        }
    }
}

extension sockaddr_in: Equatable, Hashable {
    public static func == (lhs: sockaddr_in, rhs: sockaddr_in) -> Bool {
        return lhs.sin_family == rhs.sin_family && lhs.sin_port == rhs.sin_port && lhs.sin_addr == rhs.sin_addr
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(sin_family)
        hasher.combine(sin_port)
        hasher.combine(sin_addr)
    }
}

extension in_addr: Equatable, Hashable {
    public static func == (lhs: in_addr, rhs: in_addr) -> Bool {
        return lhs.s_addr == rhs.s_addr
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(s_addr)
    }
}

extension sockaddr_in6: Equatable, Hashable {
    public static func == (lhs: sockaddr_in6, rhs: sockaddr_in6) -> Bool {
        var addr = lhs.sin6_addr
        let pointer = UnsafeBufferPointer(start: UnsafePointer(&addr), count: MemoryLayout<in6_addr>.size)
        let rawPointer = UnsafeRawBufferPointer(UnsafeMutableBufferPointer(mutating: pointer))
        let lAddr = [UInt8](rawPointer)

        var addrR = lhs.sin6_addr
        let pointerR = UnsafeBufferPointer(start: UnsafePointer(&addrR), count: MemoryLayout<in6_addr>.size)
        let rawPointerR = UnsafeRawBufferPointer(UnsafeMutableBufferPointer(mutating: pointerR))
        let rAddr = [UInt8](rawPointerR)

        return lhs.sin6_family == rhs.sin6_family && lhs.sin6_port == rhs.sin6_port && lhs.sin6_flowinfo == rhs.sin6_flowinfo && lhs.sin6_scope_id == rhs.sin6_scope_id && lAddr == rAddr
    }

    public func hash(into hasher: inout Hasher) {
        var addr = sin6_addr
        let pointer = UnsafeBufferPointer(start: UnsafePointer(&addr), count: MemoryLayout<in6_addr>.size)
        let rawPointer = UnsafeRawBufferPointer(UnsafeMutableBufferPointer(mutating: pointer))
        let rawAddr = [UInt8](rawPointer)

        hasher.combine(sin6_family)
        hasher.combine(sin6_port)
        hasher.combine(sin6_flowinfo)
        hasher.combine(rawAddr)
        hasher.combine(sin6_scope_id)
    }
}

extension sockaddr_un: Equatable, Hashable {
    public static func == (lhs: sockaddr_un, rhs: sockaddr_un) -> Bool {
        var tmp = lhs.sun_path
        var tmp2 = rhs.sun_path
        let sun_path_arr = [Int8](UnsafeBufferPointer(start: &tmp.0, count: MemoryLayout.size(ofValue: tmp)))
        let sun_path_arr2 = [Int8](UnsafeBufferPointer(start: &tmp2.0, count: MemoryLayout.size(ofValue: tmp2)))
        let sun_path_eq = sun_path_arr == sun_path_arr2

        return lhs.sun_family == rhs.sun_family && sun_path_eq
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(sun_family)

        var tmpSun = sun_path
        let sunArr = [Int8](UnsafeBufferPointer(start: &tmpSun.0, count: MemoryLayout.size(ofValue: tmpSun)))

        hasher.combine(sunArr)
    }
}
