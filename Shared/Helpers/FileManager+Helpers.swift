//
//  FileManager+Helpers.swift
//  Obfs4 VPN
//
//  Created by Benjamin Erhart on 20.05.20.
//  Copyright © 2020 Guardian Project. All rights reserved.
//

import Foundation

extension FileManager {

	var groupFolder: URL? {
		return containerURL(forSecurityApplicationGroupIdentifier: Config.groupId)
	}

	var vpnLogfile: URL? {
		return groupFolder?.appendingPathComponent("log")
	}

    var obfs4Logfile: URL? {
        return groupFolder?.appendingPathComponent("obfs4.log")
    }

	var vpnLog: String? {
		if let logfile = vpnLogfile {
			return try? String(contentsOf: logfile)
		}

		return nil
	}

    var obfs4Log: String? {
        if let logfile = obfs4Logfile {
            return try? String(contentsOf: logfile)
        }

        return nil
    }
}
