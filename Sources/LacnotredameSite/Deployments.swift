//
//  File.swift
//
//
//  Created by Stephen Hume on 2021-04-03.
//

import Files
import Foundation
import Publish
import ShellOut

extension DeploymentMethod {
  /// Deploy a website to a given remote using Git.
  /// - parameter remote: The full address of the remote to deploy to.
  public static func gitolite(_ remote: String) -> Self {
    DeploymentMethod(name: "Gitolite (\(remote))") { context in
      let folder = try context.createDeploymentFolder(withPrefix: "Gitolite") { folder in

        if !folder.containsSubfolder(named: ".git") {
          try shellOut(to: .gitInit(), at: folder.path)

          try shellOut(
            to: "git remote add origin \(remote)",
            at: folder.path
          )
        }

        try shellOut(
          to: "git remote set-url origin \(remote)",
          at: folder.path
        )

        _ = try? shellOut(
          to: .gitPull(remote: "origin", branch: "master"),
          at: folder.path
        )

        try folder.empty()
      }

      //                    _ = try? shellOut(
      //                        to:"git clone -f ssh://(\(remote)",
      ////                        to: .gitClone(url: URL(string: "ssh://(\(remote))")! ),
      //                        at: folder.path
      //                    )
      //                }
      //
      //
      //
      //                _ = try? shellOut(
      //                    to: .gitPull(remote: "origin", branch: "master"),
      //                    at: folder.path
      //                )
      //
      //                try folder.empty()
      //            }

      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
      let dateString = dateFormatter.string(from: Date())

      do {
        try shellOut(
          to: """
            git add . && git commit -a -m \"Publish deploy \(dateString)\" --allow-empty
            """,
          at: folder.path
        )

        try shellOut(
          to: .gitPush(remote: "origin", branch: "+refs/heads/master"),
          at: folder.path
        )
      } catch let error as ShellOutError {
        throw PublishingError(infoMessage: error.message)
      } catch {
        throw error
      }
    }
  }

  //    /// Deploy a website to a given GitHub repository.
  //    /// - parameter repository: The full name of the repository (including its username).
  //    /// - parameter useSSH: Whether an SSH connection should be used (preferred).
  //    static func gitHub(_ repository: String, useSSH: Bool = true) -> Self {
  //        let prefix = useSSH ? "git@github.com:" : "https://github.com/"
  //        return git("\(prefix)\(repository).git")
  //    }
}
