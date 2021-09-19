//
//  Markdownlint+Step.swift
//
//
//  Created by Stephen Hume on 2020-01-03.
//

import Foundation
import Publish
import ShellOut

extension Plugin {
  static var markdownLint: Self {
    Plugin(name: "Running markdownlint on files") { context in
      do {
        try shellOut(to: "echo", arguments: ["$PATH"])
        // set xcode environment argument PATH in Edit Scheme to find markdownlint from brew install
        // PATH=/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/sbin:/usr/local/bin
        // for brew on an M1 mac installed in /opt/homebrew
        //                PATH=/Applications/Xcode.app/Contents/Developer/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/sbin:/opt/homebrew/bin
        //                print(output) // Hello world
        let basefolder = try (context.folder(at: "Sources").parent?.path)!
        try shellOut(
          to: "markdownlint",
          arguments: [
            "--output", basefolder + "Reports/markdownlintreport.txt", "--config",
            basefolder + "Reports/markdownlintconfig.json", "./",
          ], at: basefolder + "Content")
      } catch {
        let error = error as! ShellOutError
        print(error.message)  // Prints STDERR
        print(error.output)  // Prints STDOUT
      }
    }
  }
}
