import CompressPublishPlugin
import CustomPagesPublishPlugin
import Files
import Foundation
import Plot
import Publish
import SiteCheckPublishPlugin

// This type acts as the configuration for your website.
public struct LacnotredameSite: Website {
  public enum SectionID: String, WebsiteSectionID {
    // Add the sections that you want your website to contain here:

    case about
    case map
    case water
    case main
  }

  public struct ItemMetadata: WebsiteItemMetadata {
    // Add any site-specific metadata that you want to use here.
    var title: String?
    var type: String?
    var author: String?
    var keywords: [String]?
    var basepath: String?
    var date: Date?
    var dateModified: Date?
    var wordCount: Int?  // future when long posts are an issue
    var suppresstitle: Bool? = false
    var draft: Bool? = false
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
pathsToMove[Path("main/index.html")] = Path("") // gets rid of index created that is not needed and main folder
allowedMailAddresses = [
  "mailto:info@lacnotredame.org"
]

baseFolder = try File(path: "\(#file)").parent?.parent?.parent

logger.logLevel = .warning
logger.info("lacnotredame.org site builder logger started")

if #available(macOS 10.11, *) {
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
      .if(true, .installPlugin(.markdownLint)),
      .addMarkdownFiles(),
      .sortItems(by: \.date, order: .descending),
      //        .group(additionalSteps),
      .generateHTML(withTheme: .bootstrap, indentation: nil),
      //        .unwrap(.default) { config in
      //            .generateRSSFeed(
      //                including: [],
      //                config: config
      //            )
      //        },
      .installPlugin(.moveWebsitePages),
      .generateURISiteMap(excluding: ["main"], indentedBy: nil),
      .if(true, .installPlugin(.pageScan)),
      .if(true, .installPlugin(.compressFiles)),

      //        .unwrap(nil, PublishingStep.deploy)
    ],
    file: #file
  )
} else {
  // Fallback on earlier versions
}
maxLinksToCheckPerScan = 6
checkSomeLinks()
//try? httpClient?.syncShutdown()
if #available(macOS 10.12, *) {
  archiveLinks()
} else {
  // Fallback on earlier versions
}
// from the output folder
// cd Output
// python -m SimpleHTTPServer 8000
//  python3 -m http.server

