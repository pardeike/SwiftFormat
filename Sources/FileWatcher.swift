//
//  FileWatcher.swift
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

public final class FileWatcher {
	
	private var dispatchSource : DispatchSourceFileSystemObject?
	
	public static func watch(_ path: String, _ eventMask: DispatchSource.FileSystemEvent, _ changedCallback: @escaping (FileWatcher, String) -> Void) -> FileWatcher? {
		let watcher = FileWatcher()
		let fd = open(path, O_EVTONLY)
		guard fd >= 0 else { return nil }
		let dispatchSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fd, eventMask: eventMask, queue: DispatchQueue.main)
		dispatchSource.setEventHandler { changedCallback(watcher, path) }
		dispatchSource.setCancelHandler { close(fd) }
		watcher.dispatchSource = dispatchSource
		dispatchSource.resume()
		return watcher
	}
	
	public func stop() {
		guard let dispatchSource = dispatchSource else { return }
		dispatchSource.setEventHandler(handler: nil)
		dispatchSource.cancel()
		self.dispatchSource = nil
	}
	
	deinit {
		stop()
	}
}
