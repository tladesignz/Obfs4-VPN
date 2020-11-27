//
//  ViewController.swift
//  Obfs4 VPN
//
//  Created by Benjamin Erhart on 27.11.20.
//  Copyright © 2020 Guardian Project. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private enum Info: Int {
        case vpnLog = 0
        case obfs4Log = 1
    }

    @IBOutlet weak var confStatusLb: UILabel!
    @IBOutlet weak var confBt: UIButton!
    @IBOutlet weak var errorLb: UILabel!
    @IBOutlet weak var sessionStatusLb: UILabel!
    @IBOutlet weak var sessionBt: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var logTv: UITextView!

    private static let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .percent
        nf.maximumFractionDigits = 1

        return nf
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        let nc = NotificationCenter.default

        nc.addObserver(self, selector: #selector(updateUi), name: .vpnStatusChanged, object: nil)
        nc.addObserver(self, selector: #selector(updateUi), name: .vpnProgress, object: nil)

        clear()
        updateLog(continuous: true)
    }


    // MARK: Actions

    @IBAction func check() {
        guard let url = URL(string: "") else {
            return
        }

        UIApplication.shared.open(url, options: [:])
    }

    @IBAction func clear() {
        if let logfile = FileManager.default.vpnLogfile {
            try? "".write(to: logfile, atomically: true, encoding: .utf8)
        }

        if let logfile = FileManager.default.obfs4Logfile {
            try? "".write(to: logfile, atomically: true, encoding: .utf8)
        }

        updateUi()
    }

    @IBAction func changeConf() {
        switch VpnManager.shared.confStatus {
        case .notInstalled:
            VpnManager.shared.install()

        case .disabled:
            VpnManager.shared.enable()

        case .enabled:
            VpnManager.shared.disable()
        }
    }

    @IBAction func changeSession() {
        switch VpnManager.shared.sessionStatus {
        case .connected, .connecting:
            VpnManager.shared.disconnect()

        case .disconnected, .disconnecting:
            VpnManager.shared.connect()

        default:
            break
        }
    }

    @IBAction func switchInfo() {
        updateLog()
    }


    // MARK: Observers

    @objc func updateUi(_ notification: Notification? = nil) {
        confStatusLb.text = String(format: NSLocalizedString("VPN Configuration: %@", comment: ""),
                                   VpnManager.shared.confStatus.description)

        switch VpnManager.shared.confStatus {
        case .notInstalled:
            confBt.setTitle(NSLocalizedString("Install", comment: ""))

        case .disabled:
            confBt.setTitle(NSLocalizedString("Enable", comment: ""))

        case .enabled:
            confBt.setTitle(NSLocalizedString("Disable", comment: ""))
        }

        setError(VpnManager.shared.error)

        var progress = ""

        if notification?.name == .vpnProgress,
            let raw = notification?.object as? Float {

            progress = ViewController.nf.string(from: NSNumber(value: raw)) ?? ""

        }

        sessionStatusLb.text = String(format: NSLocalizedString("Session: %@", comment: ""),
                                      [VpnManager.shared.sessionStatus.description, progress].joined(separator: " "))

        switch VpnManager.shared.sessionStatus {
        case .connected, .connecting:
            sessionBt.setTitle(NSLocalizedString("Disconnect", comment: ""))
            sessionBt.isEnabled = true

        case .disconnected, .disconnecting:
            sessionBt.setTitle(NSLocalizedString("Connect", comment: ""))
            sessionBt.isEnabled = true

        default:
            sessionBt.isEnabled = false
        }

        updateLog()
    }

    private var running = false

    private func updateLog(continuous: Bool = false) {
        if !running {
            running = true

            let text = segmentedControl.selectedSegmentIndex == Info.obfs4Log.rawValue
                ? FileManager.default.obfs4Log
                : FileManager.default.vpnLog

            if logTv.text != text {
                logTv.text = text
                logTv.scrollToBottom()
            }

            running = false
        }

        if continuous {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.updateLog(continuous: true)
            }
        }
    }


    // MARK: Private Methods

    private func setError(_ error: Error?) {
        if let error = error {
            errorLb.isHidden = false
            errorLb.text = String(format: NSLocalizedString("Error: %@", comment: ""),
                                  error.localizedDescription)
        }
        else {
            errorLb.isHidden = true
        }
    }
}

