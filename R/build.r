#' Build pkgdown website
#'
#' @description
#' `build_site()` is a convenient wrapper around six functions:
#'
#' * `init_site()`
#' * [build_articles()]
#' * [build_home()]
#' * [build_reference()]
#' * [build_news()]
#' * [build_search_index()]
#'
#' See the documentation for the each function to learn how to control
#' that aspect of the site.
#'
#' Note if names of generated files were changed, you will need to use [clean_site] first to clean up orphan files.
#'
#' @section Custom CSS/JS:
#' If you want to do minor customisation of your pkgdown site, the easiest
#' way is to add `pkgdown/extra.css` and `pkgdown/extra.js`. These
#' will be automatically copied to `docs/` and inserted into the
#' `<HEAD>` after the default pkgdown CSS and JSS.
#'
#' @section Favicon:
#' If you include you package logo in the standard location of
#' `man/figures/logo.png`, a favicon will be automatically created for
#' you.
#'
#' @section YAML config:
#' There are four top-level YAML settings that affect the entire site:
#' `destination`, `url`, `title`, `template`, and `navbar`.
#'
#' `destination` controls where the site will be generated. It defaults to
#' `docs/` (for GitHub pages), but you can override if desired. Relative
#' paths will be taken relative to the package root.
#'
#' `url` optionally specifies the url where the site will be published.
#' If you supply this, other pkgdown sites will link to your site when needed,
#' rather than using generic links to \url{rdocumentation.org}.
#'
#' `title` overrides the default site title, which is the package name.
#' It's used in the page title and default navbar.
#'
#' You can also provided information to override the default display of
#' the authors. Provided a list named with the name of each author,
#' including `href` to add a link, or `html` to override the
#' text:
#'
#' \preformatted{
#' authors:
#'   Hadley Wickham:
#'     href: http://hadley.nz
#'   RStudio:
#'     href: https://www.rstudio.com
#'     html: <img src="http://tidyverse.org/rstudio-logo.svg" height="24" />
#' }
#'
#' @section YAML config - navbar:
#' `navbar` controls the navbar at the top of the page. It uses the same
#' syntax as \href{http://rmarkdown.rstudio.com/rmarkdown_websites.html#site_navigation}{RMarkdown}.
#' The following YAML snippet illustrates some of the most important features.
#'
#' \preformatted{
#' navbar:
#'   type: inverse
#'   left:
#'     - text: "Home"
#'       href: index.html
#'     - text: "Reference"
#'       href: reference/index.html
#'     - text: "Articles"
#'       menu:
#'         - text: "Heading 1"
#'         - text: "Article A"
#'           href: articles/page_a.html
#'         - text: "Article B"
#'           href: articles/page_b.html
#'         - text: "---------"
#'         - text: "Heading 2"
#'         - text: "Article C"
#'           href: articles/page_c.html
#'         - text: "Article D"
#'           href: articles/page_d.html
#'   right:
#'     - icon: fa-github fa-lg
#'       href: https://example.com
#' }
#'
#' Use `type` to choose between "default" and "inverse" themes.
#'
#' You position elements by placing under either `left` or `right`.
#' Components can contain sub-`menu`s with headings (indicated by missing
#' `href`) and separators. Currently pkgdown only supports fontawesome
#' icons. You can see a full list of options at
#' \url{http://fontawesome.io/icons/}.
#'
#' Any missing components (`type`, `left`, or `right`)
#' will be automatically filled in from the default navbar: you can see
#' those values by running [template_navbar()].
#'
#' @section YAML config - template:
#' You can get complete control over the appearance of the site using the
#' `template` component. There are two components to the template:
#' the HTML templates used to layout each page, and the css/js assets
#' used to render the page in the browser.
#'
#' The easiest way to tweak the default style is to use a bootswatch template,
#' by passing on the `bootswatch` template parameter to the built-in
#' template:
#'
#' \preformatted{
#' template:
#'   params:
#'     bootswatch: cerulean
#' }
#'
#' See a complete list of themes and preview how they look at
#' \url{https://gallery.shinyapps.io/117-shinythemes/}:
#'
#' Optionally provide the `ganalytics` template parameter to enable
#' [Google Analytics](https://www.google.com/analytics/). It should
#' correspond to your
#' [tracking id](https://support.google.com/analytics/answer/1032385).
#'
#' \preformatted{
#' template:
#'   params:
#'     ganalytics: UA-000000-01
#' }
#'
#' You can also override the default templates and provide additional
#' assets. You can do so by either storing in a `package` with
#' directories `inst/pkgdown/assets` and `inst/pkgdown/templates`,
#' or by supplying `path` and `asset_path`. To suppress inclusion
#' of the default assets, set `default_assets` to false.
#'
#' \preformatted{
#' template:
#'   package: mycustompackage
#'
#' # OR:
#'
#' template:
#'   path: path/to/templates
#'   assets: path/to/assets
#'   default_assets: false
#' }
#'
#' These settings are currently recommended for advanced users only. There
#' is little documentation, and you'll need to read the existing source
#' for pkgdown templates to ensure that you use the correct components.
#'
#' @inheritParams build_articles
#' @inheritParams build_reference
#' @param lazy If `TRUE`, will only rebuild articles and reference pages
#'   if the source is newer than the destination.
#' @export
#' @examples
#' \dontrun{
#' build_site()
#' }
build_site <- function(pkg = ".",
                       examples = TRUE,
                       run_dont_run = FALSE,
                       mathjax = TRUE,
                       lazy = FALSE,
                       preview = interactive(),
                       seed = 1014
                       ) {

  pkg <- section_init(pkg, depth = 0)

  rule("Create pkgdown site", right = pkg$dst_path, line = 2)
  init_site(pkg)

  build_home(pkg, preview = FALSE)
  build_reference(pkg,
    lazy = lazy,
    examples = examples,
    run_dont_run = run_dont_run,
    mathjax = mathjax,
    seed = seed,
    preview = FALSE
  )
  build_articles(pkg, lazy = lazy, preview = FALSE)
  build_news(pkg, preview = FALSE)

  section_fin(pkg, "", preview = preview)
  rule("DONE", line = 2)
}

build_site_rstudio <- function() {
  devtools::document()
  callr::r(function() pkgdown::build_site(preview = TRUE), show = TRUE)
  invisible()
}

#' @export
#' @rdname build_site
init_site <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  rule("Initialising site")
  dir_create(pkg$dst_path)

  file_copy_to(pkg, data_assets(pkg))
  file_copy_to(pkg, data_extras(pkg))

  build_site_meta(pkg)
  build_logo(pkg)

  invisible()
}

data_assets <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  template <- pkg$meta[["template"]]

  if (!is.null(template$assets)) {
    path <- path_rel(pkg$src_path, template$assets)
    if (!file_exists(path))
      stop("Can not find asset path ", src_path(path), call. = FALSE)

  } else if (!is.null(template$package)) {
    path <- path_package_pkgdown(template$package, "assets")
  } else {
    path <- character()
  }

  if (!identical(template$default_assets, FALSE)) {
    path <- c(path, path_pkgdown("assets"))
  }

  dir(path, full.names = TRUE)
}

data_extras <- function(pkg = ".") {
  pkg <- as_pkgdown(pkg)

  path_extras <- path(pkg$src_path, "pkgdown")
  if (!dir_exists(path_extras)) {
    return(character())
  }

  dir_ls(path_extras, regexp = "^extra")
}

# Generate site meta data file (available to website viewers)
build_site_meta <- function(pkg = ".") {
  meta <- list(
    pandoc = as.character(rmarkdown::pandoc_version()),
    pkgdown = as.character(utils::packageVersion("pkgdown")),
    pkgdown_sha = utils::packageDescription("pkgdown")$GithubSHA1,
    articles = as.list(pkg$article_index)
  )

  if (!is.null(pkg$meta$url)) {
    meta$urls <- list(
      reference = paste0(pkg$meta$url, "/reference"),
      article = paste0(pkg$meta$url, "/articles")
    )
  }

  path_meta <- path(pkg$dst_path, "pkgdown.yml")
  write_yaml(meta, path_meta)
  invisible()
}
