//
//  TCPClientOrganizer.swift
//  UDPToTCPSwift
//
//  Created by Koray Koska on 7/2/21.
//

import Foundation
import Socket
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

class TCPCLientOrganizer {

    private var registeredClients: [Socket.Address: Socket] = [:]

    init() {
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
        return lhs.sin6_family == rhs.sin6_family && lhs.sin6_port == rhs.sin6_port && lhs.sin6_flowinfo == rhs.sin6_flowinfo && lhs.sin6_addr == rhs.sin6_addr && lhs.sin6_scope_id == rhs.sin6_scope_id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(sin6_family)
        hasher.combine(sin6_port)
        hasher.combine(sin6_flowinfo)
        hasher.combine(sin6_addr)
        hasher.combine(sin6_scope_id)
    }
}

extension in6_addr: Equatable, Hashable {
    public static func == (lhs: in6_addr, rhs: in6_addr) -> Bool {
        return lhs.__u6_addr == rhs.__u6_addr
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(__u6_addr)
    }
}

extension in6_addr.__Unnamed_union___u6_addr: Equatable, Hashable {
    public static func == (lhs: in6_addr.__Unnamed_union___u6_addr, rhs: in6_addr.__Unnamed_union___u6_addr) -> Bool {
        return lhs.__u6_addr8 == rhs.__u6_addr8 && lhs.__u6_addr16 == rhs.__u6_addr16 && lhs.__u6_addr32 == rhs.__u6_addr32
    }

    public func hash(into hasher: inout Hasher) {
        var tmp8 = __u6_addr8
        let arr_8 = [__uint8_t](UnsafeBufferPointer(start: &tmp8.0, count: MemoryLayout.size(ofValue: tmp8)))

        var tmp16 = __u6_addr16
        let arr_16 = [__uint16_t](UnsafeBufferPointer(start: &tmp16.0, count: MemoryLayout.size(ofValue: tmp16)))

        var tmp32 = __u6_addr32
        let arr_32 = [__uint32_t](UnsafeBufferPointer(start: &tmp32.0, count: MemoryLayout.size(ofValue: tmp32)))

        hasher.combine(arr_8)
        hasher.combine(arr_16)
        hasher.combine(arr_32)
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

func == <T:Equatable> (tuple1: (T, T, T, T), tuple2: (T, T, T, T)) -> Bool {
    return tuple1.0 == tuple2.0 && tuple1.1 == tuple2.1 && tuple1.2 == tuple2.2 && tuple1.3 == tuple2.3
}

func == <T:Equatable> (tuple1: (T, T, T, T, T, T, T, T), tuple2: (T, T, T, T, T, T, T, T)) -> Bool {
    return tuple1.0 == tuple2.0 && tuple1.1 == tuple2.1 && tuple1.2 == tuple2.2 && tuple1.3 == tuple2.3 &&
        tuple1.4 == tuple2.4 && tuple1.5 == tuple2.5 && tuple1.6 == tuple2.6 && tuple1.7 == tuple2.7
}

func == <T:Equatable> (tuple1: (T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T), tuple2: (T, T, T, T, T, T, T, T, T, T, T, T, T, T, T, T)) -> Bool {
    return tuple1.0 == tuple2.0 && tuple1.1 == tuple2.1 && tuple1.2 == tuple2.2 && tuple1.3 == tuple2.3 &&
        tuple1.4 == tuple2.4 && tuple1.5 == tuple2.5 && tuple1.6 == tuple2.6 && tuple1.7 == tuple2.7 &&
        tuple1.8 == tuple2.8 && tuple1.9 == tuple2.9 && tuple1.10 == tuple2.10 && tuple1.11 == tuple2.11 &&
        tuple1.12 == tuple2.12 && tuple1.13 == tuple2.13 && tuple1.14 == tuple2.14 && tuple1.15 == tuple2.15
}
