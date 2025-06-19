//
//  Command.swift
//  TowerTweakCLI
//
//  Created by sylar on 2025/6/16.
//
import Combine
import Foundation
import PromiseKit
import CryptoKit
struct Command {
    // Get User Permission
    static func check() -> Promise<Void> {
//        return getuid() == 0 ? .value(()) : .init(error: CLIError.permission)
        .value(())
    }
    
    //Get Tower Container Path
    static func getTowerContainerPath() -> Promise<URL> {
        return Promise() { seal in
            let user = NSUserName()
            let path = NSHomeDirectoryForUser(user)
            guard let path = path else {return seal.reject(CLIError.containerPathError)}
            var p = NSURL.fileURL(withPath: path)
            if #available(macOS 13.0, *) {
                p = p.appendingPathComponent("Library")
                p = p.appendingPathComponent("Application Support")
                p = p.appendingPathComponent("com.fournova.Tower3")
                //Find Trail Plist in Sub Foloders
                guard FileManager.default.fileExists(atPath: p.path(percentEncoded: false)) else { return  seal.reject(CLIError.containerPathError)}
                if let enumerator = FileManager.default.enumerator(at: p, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                    for case let fileURL as URL in enumerator {
                        do {
                            let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                            if fileAttributes.isRegularFile! {
                                if fileURL.lastPathComponent == "trial.plist" {
                                    print("Get User Trail License At Path: \(fileURL)")
                                    return seal.fulfill(fileURL)
                                }
                            }
                        } catch { print(error, fileURL) }
                    }
                }
                return seal.reject(CLIError.containerPathError)
            } else {
                // Fallback on earlier versions
                return seal.reject(CLIError.containerPathError)
            }
        }
    }
    
    
    //Read And Modify Trail Plist
    @discardableResult
    static func readAndModifyPlist(path plistP:URL) -> Promise<Void> {
        return Promise() {seal in
            if #available(macOS 13.0, *) {
                guard FileManager.default.fileExists(atPath: plistP.path(percentEncoded: false)) else { return  seal.reject(CLIError.containerPathError)}
                let licenseDic = try? NSDictionary.init(contentsOf: plistP, error: ())
                guard let licenseDic = licenseDic else {return seal.reject(CLIError.containerPathError)}
                
                guard let expireationData = licenseDic["expiration_date"] , let machine = licenseDic["machine"] , let product = licenseDic["product"] , let productVersion = licenseDic["product_version"] , let appType = licenseDic["type"] , let user = licenseDic["user"] , let code = licenseDic["code"] as? String else {return seal.reject(CLIError.trialDataError)}
                
                //Calculate first
                let hashSalt = "JuD324AiNyS89oTtS10sVyJoUaAgNv1q"
                var licenseInfo = "\(expireationData),\(machine),\(product),\(productVersion),\(appType),\(user)\(hashSalt)"
                var oriDigset = Insecure.MD5.hash(data: Data(licenseInfo.utf8)).map { String(format: "%02hhx", $0) }.joined()
                
                guard oriDigset == code else {
                    return seal.reject(CLIError.licenseAlgorithmError)
                }
                
                //Algorithm && Salt is correct
                //Crack Time
                let newLicenseDic = NSMutableDictionary(dictionary: licenseDic)
                let newDate = "2099-02-21T23:59:59Z"
                licenseInfo = "\(newDate),\(machine),\(product),\(productVersion),\(appType),\(user)\(hashSalt)"
                oriDigset = Insecure.MD5.hash(data: Data(licenseInfo.utf8)).map { String(format: "%02hhx", $0) }.joined()
                newLicenseDic["expiration_date"] = newDate
                newLicenseDic["code"] = oriDigset
                //Write To Local
                do {
                    try newLicenseDic.write(to: plistP)
                } catch let e {
                    return seal.reject(CLIError.executeCommand(command: "Write License Error", errorDes: e.localizedDescription))
                }
               
                return seal.fulfill(())
                
            } else {
                // Fallback on earlier versions
                return seal.reject(CLIError.containerPathError)
            }
        }
    }
}
