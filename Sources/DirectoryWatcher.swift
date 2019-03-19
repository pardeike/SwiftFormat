//
//  FilesWatcher.swift
//  CommandLineTool
//
//  Created by Andreas Pardeike on 2019-03-19.
//  Copyright 2016 Nick Lockwood
//
//  Distributed under the permissive MIT license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/SwiftFormat
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

public final class DirectoryWatcher {
    static let debounce = Double(3)
    static var lastActions: [String: Date] = [:]

    static func isDir(_ path: String) -> Bool {
        var dir = ObjCBool(false)
        return FileManager.default.fileExists(atPath: path, isDirectory: &dir) && dir.boolValue
    }

    public static func watch(_ root: String, predicate: @escaping (String) -> Bool, action: @escaping (String) -> Void) {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(atPath: root) else { return }
        enumerator.allObjects.map { $0 as! String }.filter(isDir).forEach { dir in
            _ = FileWatcher.watch(dir, [.all]) { _, _ in
                guard let files = try? fm.contentsOfDirectory(atPath: dir) else { return }
                files.filter(predicate).map { "\(dir)/\($0)" }.forEach { file in
                    guard let attr = try? fm.attributesOfItem(atPath: file) else { return }
                    let modified = attr[FileAttributeKey.modificationDate] as! Date
                    let ago = -modified.timeIntervalSinceNow
                    if ago < 0.5 {
                        let lastAction = lastActions[file]
                        if lastAction == nil || lastAction!.timeIntervalSinceNow < -debounce {
                            lastActions[file] = Date()
                            action(file)
                        }
                    }
                }
            }
        }
    }
}
