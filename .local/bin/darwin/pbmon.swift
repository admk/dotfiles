#!/usr/bin/swift
// A simple CLI tool for macOS
// to monitor clipboard changes
// and output the contents as a JSON stream
import Foundation
import AppKit

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(
                data: self,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String { html2AttributedString?.string ?? "" }
}
extension StringProtocol {
    var html2AttributedString: NSAttributedString? {
        Data(utf8).html2AttributedString
    }
    var html2String: String {
        html2AttributedString?.string ?? ""
    }
}

class PasteboardMonitor:NSObject {
    var clipTimer:Timer? = nil
    var counter = 0
    var pasteboard = NSPasteboard.general

    func checkChanges(interval: Double) {
        clipTimer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: false,
            block: {_ in
                let newCount = self.pasteboard.changeCount
                var clipType = "text"
                var clipData = ""
                if (newCount != self.counter) {
                    self.counter = newCount
                    if let str: String = self.pasteboard.string(
                        forType: NSPasteboard.PasteboardType.string
                    ) {
                        clipData = str
                    }
                    if (clipData != "") {
                        print(clipData)
                    }
                }
                self.checkChanges(interval: interval)
            })
    }
}

let arguments = CommandLine.arguments
var interval: Double = 0.5

if (
    arguments.count > 1 &&
    (arguments[1]=="--help" || arguments[1]=="-h" || arguments[1]=="-?")
) {
    let cmd = arguments[0]
    print("\(cmd) 1.0.1\n\nUsage:\n -h - Show help\n -i - Set update interval in seconds (default -i \(interval))")
} else {
    if (arguments.count > 2 && arguments[1]=="-i") {
        interval = (arguments[2] as NSString).doubleValue
    }

    setbuf(__stdoutp, nil);

    let cli = PasteboardMonitor()
    cli.checkChanges(interval: interval)

    signal(SIGINT, SIG_IGN)
    let sigintSource = DispatchSource.makeSignalSource(
        signal: SIGINT, queue: DispatchQueue.main)
    sigintSource.setEventHandler { exit(0) }
    sigintSource.resume()

    let theRL = RunLoop.current
    while theRL.run(mode: RunLoop.Mode.default, before: .distantFuture) {}
}
