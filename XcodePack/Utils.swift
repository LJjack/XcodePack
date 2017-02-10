//
//  Utils.swift
//  MacTest
//
//  Created by 刘俊杰 on 2017/2/9.
//  Copyright © 2017年 天翼. All rights reserved.
//

import Cocoa

class AutoPack : NSObject {
    //configuration for iOS build setting
    private let kConfiguration = "Release"
    private let kExportOptionsPlist =  Bundle.main.path(forResource: "exportOptions", ofType: "plist")//"/Users/bujiong/Documents/iOS/MacTest/MacTest/exportOptions.plist"
    //会在桌面创建输出ipa文件的目录
    private let kExportMainDirectory = "~/Desktop/"
    private lazy var cmd: TerminalCmd = {
        return TerminalCmd()
    }()
    
    public let cdFilePath:String
    public let project:String
    public let scheme:String
    public var runningLog: ((String) -> Void)?
    
    
    init(_ cdFilePath:String, project:String,scheme:String) {
        self.cdFilePath = cdFilePath
        self.project = project
        self.scheme = scheme
    }
    
    init(_ cdFilePath:String, project:String) {
        self.cdFilePath = cdFilePath
        self.project = project
        
        if let firstSpot = project.characters.index(of: ".") {
            self.scheme = String(project.characters.prefix(upTo: firstSpot))
        } else {
            self.scheme = ""
        }
        print("path:" + cdFilePath , "project:" + project, "scheme" + scheme );
    }
    func testd(c:String)  {
        cmd.tCmd(cmd: c) { (a) in
            print(a)
        }
    }
    /// 打包
    func build() {
        let type = buildType.work(name: project)
        var typeName = ""
        switch type {
        case .workspace:
            typeName = "workspace"
            break
        case .project:
            typeName = "project"
            break
        case .none:
            print("不符合要求")
            return
            
        }
        let archivePath = buildArchivePath(scheme)
        let archiveCmd = "xcodebuild -\(typeName) \(project) -scheme \(scheme) -configuration \(kConfiguration) archive -archivePath \(archivePath) -destination generic/platform=iOS"
        let cmdcdFilePath = "cd " + cdFilePath + "; "
        
        print("\n" + cmdcdFilePath + "\n" + archiveCmd)
        let status = cmd.tCmd(cmd: cmdcdFilePath + archiveCmd) { log in
            if let r = self.runningLog {
                r(log)
            }
        }
        if status != 0 {
            print("运行\(project)失败")
        } else {
            let res = exportArchive(scheme: scheme, archivePath: archivePath)
            print(res)
        }
    }
    
    //MARK: 私有方法
    
    enum buildType {
        case workspace,project,none
        static func work(name:String) -> buildType {
            if name.hasSuffix("xcodeproj") {
                return .project
            } else if name.hasSuffix("xcworkspace") {
                return .workspace
            }
            return .none
        }
    }
    
    //创建输出IPA文件路径: ~/Desktop/{scheme}{2016-12-28_08-08-10}
    private func buildExportDirectory(_ scheme:String) -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        let dataString = format.string(from: date)
        return kExportMainDirectory + scheme + dataString
    }
    private func buildArchivePath(_ tempName:String) -> String {
        return cdFilePath + "/" + tempName + ".xcarchive"
    }
    
    private func clearArchiveFile(archiveFile:String) {
        let clearCmd = "rm -r \(archiveFile)"
        cmd.tCmd(cmd: clearCmd) { log in
            if let r = self.runningLog {
                r(log)
            }
        }
    }
    
    @discardableResult
    private func exportArchive(scheme:String, archivePath:String) -> String {
        let exportDirectory = buildExportDirectory(scheme)
        guard let plist = kExportOptionsPlist  else {
            clearArchiveFile(archiveFile: archivePath)
            print("plist文件不存在")
            return exportDirectory
        }
        let exportCmd = "xcodebuild -exportArchive -archivePath \(archivePath) -exportPath \(exportDirectory) -exportOptionsPlist \(plist)"
        let stauts = cmd.tCmd(cmd: exportCmd) { log in
            if let r = self.runningLog {
                r(log)
            }
        }
        if stauts != 0 {
            print("生成ipa文件失败")
        } else {
            print("成功")
        }
        clearArchiveFile(archiveFile: archivePath)
        return exportDirectory
    }
}
