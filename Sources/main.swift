// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser
import Foundation
import PromiseKit

enum App {
    static let root = "/Applications"
    static let app = root.appending("/Tower.app")
    static let macos = app.appending("/Contents/MacOS")
    static let binary = macos.appending("/Tower")
    static let backup = macos.appending("/Tower.bak")
    static let injectLib = macos.appending("/Tower_tweak.dylib")
}

enum CLIError: LocalizedError {
    case permission
    case containerPathError
    case trialDataError
    case licenseAlgorithmError
    case insertDylib
    case executeCommand(command:String , errorDes:String)
    
    var errorDescription: String? {
        switch self {
        case .permission:
            return "Please run with `sudo`."
        case .containerPathError:
            return "Can't Find Tower App Container Path"
        case .insertDylib:
            return "Insert dylib failed"
        case .trialDataError:
            return "Trail License Data Error"
        case .licenseAlgorithmError:
            return "The Algorithm is Desperated!"
        case let .executeCommand(command, errorDes):
            return "Executing Command: \(command) Error: \(errorDes)"
        }
    }
}

struct Tweak: ParsableCommand {
    static let configuration: CommandConfiguration = .init(commandName: "towertweak-cli", abstract: "A command line utility to Tweak Tower Git MacOS App", subcommands: [Unlimited.self], defaultSubcommand: Self.self)
}

struct Unlimited: ParsableCommand {
    static let configuration: CommandConfiguration = .init(abstract: "UnlimitedTime Usage")

    func run() throws {
        firstly {
            // Check Privileges
            Command.check()
        }.then {
            Command.getTowerContainerPath()
        }.then { plistPath in
            Command.readAndModifyPlist(path: plistPath)
        }.done { _ in
            print("Success Write New License Info , Please Reopen Tower Git App!")
        }.catch { error in
            print("Install failed: \(error.localizedDescription)")
        }.finally {
            CFRunLoopStop(CFRunLoopGetCurrent())
        }
    }
}
let logoStr = """
    ########  #######  ##      ## ######## ########     ######## ##      ## ########    ###    ##    ## 
       ##    ##     ## ##  ##  ## ##       ##     ##       ##    ##  ##  ## ##         ## ##   ##   ##  
       ##    ##     ## ##  ##  ## ##       ##     ##       ##    ##  ##  ## ##        ##   ##  ##  ##   
       ##    ##     ## ##  ##  ## ######   ########        ##    ##  ##  ## ######   ##     ## #####    
       ##    ##     ## ##  ##  ## ##       ##   ##         ##    ##  ##  ## ##       ######### ##  ##   
       ##    ##     ## ##  ##  ## ##       ##    ##        ##    ##  ##  ## ##       ##     ## ##   ##  
       ##     #######   ###  ###  ######## ##     ##       ##     ###  ###  ######## ##     ## ##    ## 
    """
print(logoStr)
Tweak.main()
CFRunLoopRun()
