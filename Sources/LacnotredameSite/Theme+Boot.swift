//
//  File.swift
//  
//
//  Created by Stephen Hume on 2021-03-27.
//

import Publish


import Plot
import Ink

public extension Theme {
    /// The default "Foundation" theme that Publish ships with, a very
    /// basic theme mostly implemented for demonstration purposes.
    static var bootstrap: Self {
        Theme(
            htmlFactory: LNDFactory(),
            resourcePaths: []
        )
    }
}

public extension Node where Context == HTML.DocumentContext {
    /// Add an HTML `<head>` tag within the current context, based
    /// on inferred information from the current location and `Website`
    /// implementation.
    /// - Parameter location: The location to generate a `<head>` tag for.
    /// - Parameter site: The website on which the location is located.
    /// - Parameter titleSeparator: Any string to use to separate the location's
    ///   title from the name of the website. Default: `" | "`.
    /// - Parameter stylesheetPaths: The paths to any stylesheets to add to
    ///   the resulting HTML page. Default: `styles.css`.
    /// - Parameter rssFeedPath: The path to any RSS feed to associate with the
    ///   resulting HTML page. Default: `feed.rss`.
    /// - Parameter rssFeedTitle: An optional title for the page's RSS feed.
    static func head<T: Website>(
        for location: Location,
        on site: T,
        titleSeparator: String = " | ",
        stylesheetPaths: [Path] = ["/css/bootstrap.min.css"],
        rssFeedPath: Path? = .defaultForRSSFeed,
        rssFeedTitle: String? = nil
    ) -> Node {
        var title = location.title

        if title.isEmpty {
            title = site.name
        } else {
            title.append(titleSeparator + site.name)
        }

        var description = location.description

        if description.isEmpty {
            description = site.description
        }

        return .head(
            .encoding(.utf8),
            .siteName(site.name),
            .group([
                .link(.rel(.canonical), .href(site.url(for: location))),
//                .meta(.name("twitter:url"), .content(url)),
                .meta(.name("og:url"), .content(site.url(for: location).absoluteString))
            ]),
//            .url(site.url(for: location)),
            .group([
                .element(named: "title", text: title),
//                .meta(.name("twitter:title"), .content(title)),
                .meta(.name("og:title"), .content(title))
            ]),
            .group([
                .meta(.name("description"), .content(description)),
//                .meta(.name("twitter:description"), .content(description)),
                .meta(.name("og:description"), .content(description))
            ]),
//            .twitterCardType(location.imagePath == nil ? .summary : .summaryLargeImage),
            .forEach(stylesheetPaths, { .stylesheet($0) }),
            .group([
                .script(
                    .defer(),
                    .src("/js/bootstrap.bundle.min.js")
                )
            ]),
            .viewport(.accordingToDevice),
            .unwrap(site.favicon, { .favicon($0) })
//            .unwrap(rssFeedPath, { path in
//                let title = rssFeedTitle ?? "Subscribe to \(site.name)"
//                return .rssFeedLink(path.absoluteString, title: title)
//            }),
//            .unwrap(location.imagePath ?? site.imagePath, { path in
//                let url = site.url(for: path)
//                return .socialImageLink(url)
//            })
        )
    }
}


private struct LNDFactory<Site: Website>: HTMLFactory {
    public func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        
         return HTML(
            .lang(context.site.language),
            .head(for: index, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .container(
                    .id("cont"),
                    .h1(
                        .class("visually-hidden-focusable"),
                        .text((context.pages["main"]?.content.description)!)
                    ),
                    .contentBody(context.pages["main"]!.content.body)
                ),
                .footer(for: context.site)
            )
        )
    }

    public func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site),
            .body(
                .header(for: context, selectedSection: section.id),
                .container(
                    .id("cont"),
                    .h1(.text(section.title)),
                    .itemList(for: section.items, on: context.site)
                ),
                .footer(for: context.site)
            )
        )
    }

    public func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site),
            .body(
                .class("item-page"),
                .header(for: context, selectedSection: item.sectionID),
                .main(
                    
                   
                        .container(
                            .id("cont"),
                            .h1(.text(item.title)),
                            .contentBody(item.body)
                        )
//                        .span("Tagged with: "),
//                        .tagList(for: item, on: context.site)
                    
                ),
                .footer(for: context.site)
            )
        )
    }

    public func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        if page.path == "404" {
            return HTML(
                 .lang(context.site.language),
                 .head(for: page, on: context.site),
                 .body(
                     .header(for: context, selectedSection: nil),
                     .container(
                      .id("cont"),
                      .contentBody("<p>Hi.<p>")),
                     .footer(for: context.site)
                     )
                 )
        } else {
        
       return HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .container(
                  .id("cont"),
                  .contentBody(page.body)),
                .footer(for: context.site)
                )
            )
            
        }
    }

    public func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .container(
                  .id("cont"),
                    .h1("Browse all tags"),
                    .ul(
                        .class("all-tags"),
                        .forEach(page.tags.sorted()) { tag in
                            .li(
                                .class("tag"),
                                .a(
                                    .href(context.site.path(for: tag)),
                                    .text(tag.string)
                                )
                            )
                        }
                    )
                ),
                .footer(for: context.site)
            )
        )
    }

    public func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .container(
                  .id("cont"),
                    .h1(
                        "Tagged with ",
                        .span(.class("tag"), .text(page.tag.string))
                    ),
                    .a(
                        .class("browse-all"),
                        .text("Browse all tags"),
                        .href(context.site.tagListPath)
                    ),
                    .itemList(
                        for: context.items(
                            taggedWith: page.tag,
                            sortedBy: \.date,
                            order: .descending
                        ),
                        on: context.site
                    )
                ),
                .footer(for: context.site)
            )
        )
    }
  
}

private extension Node where Context == HTML.BodyContext {
    static func wrapper(_ nodes: Node...) -> Node {
        .div(.class("wrapper"), .group(nodes))
    }
    
    static func container(_ nodes: Node...) -> Node {
        .div(.class("container"), .group(nodes))
    }
    
    static func header<T: Website>(
        for context: PublishingContext<T>,
        selectedSection: T.SectionID?
    ) -> Node {
//        let sectionIDs = T.SectionID.allCases

        return .header(
            .wrapper(
                .skipList(),
                container(
                    .div(
                        .class("d-flex flex-row"),
                        .div(
                            .class("d-inline-flex px-2 order-0"),
                            .attribute(named: "tabindex", value: "-1"),
                            .a(.class("float-left"), .href("/"),
                               .img(
                                    .class("img-fluid"),
                                .attribute(named: "style", value: "max-height: 60px;height: 60px;width: 60px;"),
                                    .src("/lacnotredame-logo.png"),
                                    .alt("Lac Notre-Dame and Usher Lake Association logo"))
                                   )
                        ),
                        .div(
                            .class("d-inline-flex px-2 order-1 order-md-1"),
                            .p(
                                .class("h4 text-left"),
                                .text(context.site.name)
                            )
                        )
//                        .div(
//                            .class("d-inline-flex px-2 order-2 order-md-2"),
//                            .section(
//                                .id("srch"),
//                                .h2(
//                                    .class("visually-hidden-focusable"),
//                                     .text("Search this site input")
//                                 ),
//                                .iframe(
//                                    .src("https://duckduckgo.com/search.html?width=200&site=lacnotredame.org&prefill=search%20lacnotredame.org"),
//                                    .attribute(named: "style", value: "overflow:hidden;margin:0;padding:0;max-width:258px;height:40px;border:0;")
//                                )
//
//                            )
//                        )
                    )
                )
            )
        )
    }
    
    static func skipList() -> Node {
        return .ul(
            .class("visually-hidden"),
            .id("skip-list"),
            .group(
                .li(    // .class("visually-hidden"),
                        .a(.class("visually-hidden-focusable"),
                            .href("#cont"),
                            .text("Skip to main content")
                        )
                    ),
                .li(    // .class("visually-hidden"),
                        .a(.class("visually-hidden-focusable"),
                            .href("#info"),
                            .text("Skip to About this Site")
                        )
                    )
                )
            )
    }

    static func itemList<T: Website>(for items: [Item<T>], on site: T) -> Node {
        return .ul(
            .class("item-list"),
            .forEach(items) { item in
                .li(.article(
                    .h1(.a(
                        .href(item.path),
                        .text(item.title)
                    )),
                    .tagList(for: item, on: site),
                    .p(.text(item.description))
                ))
            }
        )
    }

    static func tagList<T: Website>(for item: Item<T>, on site: T) -> Node {
        return .ul(.class("tag-list"), .forEach(item.tags) { tag in
            .li(.a(
                .href(site.path(for: tag)),
                .text(tag.string)
            ))
        })
    }

    static func footer<T: Website>(for site: T) -> Node {
        return
            .container(
            .footer(
            .id("info"),
            .container(
                .form(
// nginx handles the search redirect to duckduckgo.com
//                    location ^~ /do/search {
//                        return 302 https://duckduckgo.com/?q=site%3Alacnotredame.org+$arg_q;
//                    }
                    .action("/do/search"),
                    .method(.get),
                    .fieldset(
                        .div(
                            .class("row justify-content-start"),
                            .div(
                                .class("col-6"),
                                .input(
                                    .class("form-control form-control-lg"),
                                    .autocomplete(false),
                                    .autofocus(false),
                                    .name("q"),
                                    .placeholder("search lacnotredame.org"),
                                    .type(HTMLInputType.text)
                                    )
                                
                                ),
                        .div(
                            .class("col-3"),
                            .input(
                                .class("btn btn-primary mb-3"),
                                .type(HTMLInputType.submit),
                                .value("Search")
                            )
                            )
                        )
                    )
                )
            ),
            .p(
                .text("Contact us at: info [at] lacnotredame [dot] org")
            ),
            .p(.a(
                .text("Back to site home page"),
                .href("/")
            ))
            )
            
        )
    }
}
