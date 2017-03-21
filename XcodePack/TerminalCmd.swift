//
//  TerminalCmd.swift
//  TestDeShell
//
//  Created by 刘俊杰 on 2017/2/9.
//  Copyright © 2017年 天翼. All rights reserved.
//

import Cocoa

//终端命令
struct TerminalCmd {
    @discardableResult
    func tCmd(cmd:String , block:((String) -> Void)? = nil) -> Int32 {
        return tCmd(cmd: cmd, launchPath: "/bin/bash", block:block)
    }
    
    @discardableResult
    func tCmd(cmd:String, launchPath:String, block:((String) -> Void)? = nil) -> Int32 {
        // 初始化并设置shell路径
        let task = Process()
        task.qualityOfService = .default
        task.launchPath = launchPath
        // -c 用来执行string-commands（命令字符串），也就说不管后面的字符串里是什么都会被当做shellcode来执行
        task.arguments = ["-c", cmd]
        task.currentDirectoryPath = Bundle.main.resourcePath!
        // 新建输出管道作为Task的输出
        let pip = Pipe()
        task.standardOutput = pip
        // 开始task
        let file = pip.fileHandleForReading
        file.readabilityHandler = { a in
            let data = a.availableData
            guard let srt = String(data: data, encoding: .utf8) else {
                return
            }
            //生成日志
            if let b = block {
                b(srt)
            }
        }
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
}
