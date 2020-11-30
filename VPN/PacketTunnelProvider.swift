//
//  PacketTunnelProvider.swift
//  VPN
//
//  Created by Benjamin Erhart on 27.11.20.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {

    static let ENABLE_LOGGING = true



    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        IPtProxy.setStateLocation(PacketTunnelProvider.obfs4Logfile!.deletingLastPathComponent().path)

        IPtProxyStartObfs4Proxy("DEBUG", true, true)


        TunnelInterface.setup(with: packetFlow)
        TunnelInterface.startTun2Socks(Int32(IPtProxyObfs4SocksPort),
                                       withUsername: "iCepa",
                                       andPassword: "iCepa");

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            TunnelInterface.processPackets()
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        TunnelInterface.stop()

        IPtProxyStopObfs4Proxy()

        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }



    // MARK: Logging

    func log(_ message: String) {
        PacketTunnelProvider.log(message, to: PacketTunnelProvider.vpnLogfile)
    }

    static var vpnLogfile: URL? = {
        if let url = FileManager.default.vpnLogfile {
            // Reset log on first write.
            try? "".write(to: url, atomically: true, encoding: .utf8)

            return url
        }

        return nil
    }()

    static var obfs4Logfile: URL? = {
        if let url = FileManager.default.obfs4Logfile {
            // Reset log on first write.
            try? "".write(to: url, atomically: true, encoding: .utf8)

            return url
        }

        return nil
    }()

    static func log(_ message: String, to: URL?) {
        guard ENABLE_LOGGING,
            let url = to,
            let data = message.trimmingCharacters(in: .whitespacesAndNewlines).appending("\n").data(using: .utf8),
            let fh = try? FileHandle(forUpdating: url) else {
                return
        }

        defer {
            fh.closeFile()
        }

        fh.seekToEndOfFile()
        fh.write(data)
    }
}
