//
//  Connection.swift
//  Supersign
//
//  Created by Kabir Oberai on 15/11/19.
//  Copyright © 2019 Kabir Oberai. All rights reserved.
//

import Foundation
import SwiftyMobileDevice

class Connection {

    private static let label = "supersign"

    private(set) var isClosed = false

    private let usbmuxHandler: USBMuxHandler
    let device: Device
    let client: LockdownClient
    private let heartbeatHandler: HeartbeatHandler

    init(udid: String, pairingKeys: URL, progress: (Double) -> Void) throws {
        progress(0/0)

        usbmuxHandler = USBMuxHandler(udid: udid, pairingKeys: pairingKeys)
        progress(1/4)

        device = try Device(udid: udid)
        progress(2/4)

        client = try LockdownClient(device: device, label: Self.label, performHandshake: true)
        progress(3/4)

        heartbeatHandler = HeartbeatHandler(device: device, client: client)
        progress(4/4)
    }

    deinit { close() }

    func close() {
        guard !isClosed else { return }
        isClosed = true

        heartbeatHandler.stop()
        usbmuxHandler.stop()
    }

    func startClient<T: Service>(_ type: T.Type = T.self, sendEscrowBag: Bool = false) throws -> T {
        try .init(device: device, service: .init(client: client, sendEscrowBag: sendEscrowBag))
    }

}
