//
//  BottleSettings.swift
//  Whisky
//
//  Created by Isaac Marovitz on 31/03/2023.
//

import Foundation

struct BottleSettingsData: Codable {
    var wineVersion: String = "8.5"
    var baseSettings: BaseSettingsData = BaseSettingsData()
}

struct BaseSettingsData: Codable {
    var windowsVersion: WinVersion = .win7
    var dxvk: Bool = false
    var dxvkHud: Bool = false
    var metalHud: Bool = false
    var metalTrace: Bool = false
    var esync: Bool = false

    func environmentVariables(environment: inout [String: String]) {
        if dxvk {
            environment.updateValue("d3d11,dxgi,d3d10core=n,b", forKey: "WINEDLLOVERRIDES")
            if dxvkHud {
                environment.updateValue("devinfo,fps,frametimes", forKey: "DXVK_HUD")
            }
        }

        if esync {
            environment.updateValue("1", forKey: "WINEESYNC")
        }

        if metalHud {
            environment.updateValue("1", forKey: "MTL_HUD_ENABLED")
        }

        if metalTrace {
            environment.updateValue("1", forKey: "METAL_CAPTURE_ENABLED")
            // Might not be needed
            environment.updateValue("2", forKey: "MVK_CONFIG_AUTO_GPU_CAPTURE_SCOPE")
        }
    }
}

class BottleSettings {
    var settings: BottleSettingsData {
        didSet {
            encode()
        }
    }

    var wineVersion: String {
        get {
            return settings.wineVersion
        }
        set {
            settings.wineVersion = newValue
        }
    }

    var windowsVersion: WinVersion {
        get {
            return settings.baseSettings.windowsVersion
        }
        set {
            settings.baseSettings.windowsVersion = newValue
        }
    }

    var dxvk: Bool {
        get {
            return settings.baseSettings.dxvk
        }
        set {
            settings.baseSettings.dxvk = newValue
        }
    }

    var dxvkHud: Bool {
        get {
            return settings.baseSettings.dxvkHud
        }
        set {
            settings.baseSettings.dxvkHud = newValue
        }
    }

    var metalHud: Bool {
        get {
            return settings.baseSettings.metalHud
        }
        set {
            settings.baseSettings.metalHud = newValue
        }
    }

    var metalTrace: Bool {
        get {
            return settings.baseSettings.metalTrace
        }
        set {
            settings.baseSettings.metalTrace = newValue
        }
    }

    var esync: Bool {
        get {
            return settings.baseSettings.esync
        }
        set {
            settings.baseSettings.esync = newValue
        }
    }

    let settingsUrl: URL

    init(bottleUrl: URL, name: String) {
        self.settingsUrl = bottleUrl.appendingPathComponent(name)
                                    .appendingPathExtension("plist")

        settings = BottleSettingsData()
        if !decode() {
            encode()
        }
    }

    @discardableResult
    public func decode() -> Bool {
        do {
            let data = try Data(contentsOf: settingsUrl)
            settings = try PropertyListDecoder().decode(BottleSettingsData.self, from: data)
            if settings.wineVersion != BottleSettingsData().wineVersion {
                print("Bottle has a different wine version!")
                settings.wineVersion = BottleSettingsData().wineVersion
            }
            return true
        } catch {
            print(error)
            return false
        }
    }

    @discardableResult
    public func encode() -> Bool {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        do {
            let data = try encoder.encode(settings)
            try data.write(to: settingsUrl)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
