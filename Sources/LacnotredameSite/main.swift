import Foundation
import Plot
import Publish
import Files

// This type acts as the configuration for your website.
public struct LacnotredameSite: Website {
    public enum SectionID: String, WebsiteSectionID {
    // Add the sections that you want your website to contain here:

    case about
    case map
    case water
  }

    public struct ItemMetadata: WebsiteItemMetadata {
    // Add any site-specific metadata that you want to use here.
  }

  // Update these properties to configure your website:
    public var url = URL(string: "https://lacnotredame.org")!
    public var name = "Lac Notre-Dame and Usher Lake Association"
    public var description =
    "Homepage of the Lac Notre-Dame and Usher Lake Association in La Pêche Québec Canada"
    public var language: Language { .english }
    public var imagePath: Path? { nil }
    public var favicon: Favicon? { Favicon(path: "favicon.ico", type: "image/x-icon") }
}

let thisFile = try File(path: "\(#file)").parent?.parent
var xCodepath: String = thisFile!.path
//if CommandLine.arguments.count < 2 {
//    print("""
//    Publish -> Markdown Lint Checker
//    -------------------------------
//    The $(SRCROOT) needs to be passed as an argument in XCode Run Scheme
//    """)
//
//} else {
//    xCodepath = CommandLine.arguments[1]
//}

// This will generate your website using the built-in Foundation theme:
//try LacnotredameSite().publish(withTheme: .bootstrap)
try LacnotredameSite().publish(
  at: nil,
  using: [
    //        .group(plugins.map(PublishingStep.installPlugin)),
    .optional(.copyResources()),
    .step(named: "Use custom DateFormatter") { context in
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      context.dateFormatter = formatter
    },
    .if(false, .installPlugin(.markdownLint)),
    .addMarkdownFiles(),
//    .add404Page(),
    .sortItems(by: \.date, order: .descending),
    //        .group(additionalSteps),
    .generateHTML(withTheme: .bootstrap, indentation: nil),
    //        .unwrap(.default) { config in
    //            .generateRSSFeed(
    //                including: [],
    //                config: config
    //            )
    //        },
    .moveWebsitePages(paths: [("404","404.html")]),
    .generateSiteMap(excluding: ["main","404"], indentedBy: nil),
    .if(true, .installPlugin(.compressFiles)),
    
    //        .unwrap(nil, PublishingStep.deploy)
  ],
  file: #file
)
extension PublishingStep where Site == LacnotredameSite {
    // this is not ideal but if the pages do not contain any links that will break, it is of some use
    static func moveWebsitePages(paths: [(String, String)]) -> Self {
        .step(named: "Move some pages") { context in
            let outputFol: Folder = try context.outputFolder(at: "")
//            let outputLoc = outputFol.path

            for (fromPath, toPath) in paths {
                let origFolder :Folder = try outputFol.subfolder(at: fromPath)
                let originFileLoc: File = try origFolder.file(named: "index.html")
                try originFileLoc.rename(to: toPath, keepExtension: true)
//                let targetFile = toPath
                try originFileLoc.move(to: outputFol)
                if origFolder.isEmpty(includingHidden: true) {
                    try origFolder.delete()
                }
                try originFileLoc.rename(to: fromPath, keepExtension: true)
                }
        }
    }
}

extension PublishingStep where Site == LacnotredameSite {
    static func add404Page() -> Self {
        .step(named: "Create 404 page") { ctx in
            let ct = Content(title: "Page not found",
                             description: "Use these links to Sections"

            )
            let pg = Page(path: "404", content: ct)
            ctx.addPage(pg)
        }
    }
}
