//
//  Utils.swift
//  MacTest
//
//  Created by 刘俊杰 on 2017/2/9.
//  Copyright © 2017年 天翼. All rights reserved.
//

import Cocoa

fileprivate let kExportOptionsPlist =  Bundle.main.path(forResource: "exportOptions", ofType: "plist")
//configuration for iOS build setting
fileprivate let kConfiguration = "Release"
fileprivate let kOutputPath = "Desktop" //会在桌面创建输出ipa文件的目录

class AutoPack : NSObject {
    
    private lazy var cmd: TerminalCmd = {
        return TerminalCmd()
    }()
    private(set) var ipaPath: String?
    
    private let filePath:String
    private let projectName:String
    private let suffixName:String
    private let project:String
    
    public var runningLog: ((String) -> Void)?
    public var didFinish: ((Int32, String) -> Void)?
    
    init(_ filePath:String, project:String) {
        self.filePath = filePath
        self.project = project
        let spot = project.characters.index(of: ".")!
        self.projectName = String(project.characters.prefix(upTo: spot))
        self.suffixName = String(project.characters.suffix(from: spot))
    }
    
    /// 打包
    func build() {
        let typeName    = projectType(suffixName: suffixName)
        let archivePath = buildArchivePath(filePath: filePath, name: projectName)
        var cmdCode = "cd " + filePath + "; "
        cmdCode += "xcodebuild -\(typeName) \(project) -scheme \(projectName) -configuration \(kConfiguration) archive -archivePath \(archivePath) -destination generic/platform=iOS; "
        debugPrint("命令代码：" + cmdCode)
        let status = self.cmd.tCmd(cmd:cmdCode) { log in
            if let r = self.runningLog { r(log) }
        }
        if status != 0 {
            if let finish = self.didFinish {
                finish(status, "")
            }
        } else {
            let exportDirectory = self.ipaOutputPath(filePath, projectName: projectName)
            let cmdCodeIpa = "xcodebuild -exportArchive -archivePath \(archivePath) -exportPath \(exportDirectory) -exportOptionsPlist \(kExportOptionsPlist!); "
            debugPrint("命令代码：" + cmdCodeIpa)
            let status1 = self.cmd.tCmd(cmd:cmdCodeIpa) { log in
                if let r = self.runningLog { r(log) }
            }
            if let finish = self.didFinish {
                let ipaPath = exportDirectory + "/" + projectName + ".ipa"
                finish(status1,ipaPath)
            }
        }
        cmd.tCmd(cmd: "rm -r \(archivePath);")
    }
}

extension AutoPack {
    
    fileprivate func projectType(suffixName:String) -> String {
        var typeName = ""
        switch suffixName {
        case ".xcworkspace":
            typeName = "workspace"
            break
        case ".xcodeproj":
            typeName = "project"
            break
        default:
            debugPrint("不符合要求")
            break;
        }
        return typeName
    }
    
    //创建输出IPA文件路径: ~/Desktop/{projectName}{2016-12-28_08-08-10}
    fileprivate func ipaOutputPath(_ filePath:String, projectName:String) -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dataString = format.string(from: date)
        let path = filePath.components(separatedBy: "/")[1...2].reduce("/") { (res, node) -> String in
            return res +  node + "/"
        }
        return path + kOutputPath + "/" + projectName + dataString
    }
    
    fileprivate func buildArchivePath(filePath:String,name:String) -> String {
        return filePath + "/" + name + ".xcarchive"
    }
}

