#' Default bayesplot plotting theme
#'
#' The \code{\link{theme_default}} function returns the default ggplot
#' \link{theme} used by the \pkg{bayesplot} plotting functions. See
#' \code{\link{bayesplot_theme_set}} for details on setting and updating the
#' plotting theme.
#'
#' @export
#' @param base_size,base_family Base font size and family (passed to
#'   \code{\link[ggplot2]{theme_bw}}). It is possible to set
#'   \code{"bayesplot.base_size"} and \code{"bayesplot.base_family"} via
#'   \code{\link{options}} to change the defaults, which are \code{12} and
#'   \code{"serif"}, respectively.
#' @return A ggplot \link[ggplot2]{theme} object.
#'
#' @template seealso-helpers
#' @template seealso-colors
#'
#' @examples
#' class(theme_default())
#'
#' bayesplot_theme_set() # defaults to setting theme_default()
#' x <- example_mcmc_draws()
#' mcmc_hist(x)
#'
#' # change the default font size and family for bayesplots
#' bayesplot_theme_set(theme_default(base_size = 8, base_family = "sans"))
#' mcmc_hist(x)
#' mcmc_areas(x, regex_pars = "beta")
#'
#' # change back
#' bayesplot_theme_set()
#' mcmc_areas(x, regex_pars = "beta")
#'
theme_default <-
  function(base_size = getOption("bayesplot.base_size", 12),
           base_family = getOption("bayesplot.base_family", "serif")) {

    theme_bw(
      base_family = base_family,
      base_size = base_size
    ) +
      theme(
        plot.background = element_blank(),
        panel.grid = element_blank(),
        panel.background = element_blank(),
        panel.border = element_blank(),
        axis.line = element_line(size = 0.4),
        axis.ticks = element_line(size = 0.3),
        strip.background = element_blank(),
        strip.text = element_text(size = rel(0.9)),
        strip.placement = "outside",
        # strip.background = element_rect(fill = "gray95", color = NA),
        panel.spacing = unit(1.5, "lines"),
        legend.position = "right",
        legend.background = element_blank(),
        legend.text = element_text(size = 13),
        legend.text.align = 0,
        legend.key = element_blank()
      )
  }


#' Get, set, and modify the active bayesplot theme
#'
#' @description These functions are the \pkg{bayesplot} equivalent to
#'   \pkg{ggplot2}'s \code{\link[ggplot2]{theme_set}} and friends. They set,
#'   get, and update the active theme but only apply them to \code{bayesplots}.
#'   The current/active theme is automatically applied to every \code{bayesplot}
#'   you draw.
#'
#'   Use \code{bayesplot_theme_get} to get the current \pkg{bayesplot} theme,
#'   and \code{bayesplot_theme_set} to change it. \code{bayesplot_theme_update}
#'   and \code{bayesplot_theme_replace} are shorthands for changing individual
#'   elements.
#'
#' @details \code{bayesplot_theme_set} and friends only apply to
#'   \code{bayesplots}. However, \code{ggplot2::theme_set} can also be used to
#'   change the \pkg{bayesplot} theme. Currently, setting a theme with
#'   \code{ggplot2::theme_set} (other than the \pkg{ggplot2} default
#'   \code{\link[ggplot2]{theme_grey}}) will override the \pkg{bayesplot} theme.
#'
#' @export
#' @param new The new theme (list of theme elements) to use. This is analogous
#'   to the \code{new} argument to \code{\link[ggplot2]{theme_set}}.
#' @param ... A named list of theme settings.
#'
#' @return \code{bayesplot_theme_get} returns the current theme. The other three
#'   functions (set, update, replace) invisibly return the \emph{previous} theme
#'   so it can be saved and easily restored later. This is the same behavior as
#'   the \pkg{ggplot2} versions of these functions.
#'
#' @seealso \code{\link{theme_default}} for the default \pkg{bayesplot} theme.
#' @template seealso-helpers
#' @template seealso-colors
#'
#' @examples
#' library(ggplot2)
#'
#' # plot using the current value of bayesplot_theme_get()
#' # (the default is bayesplot::theme_default())
#' x <- example_mcmc_draws()
#' mcmc_hist(x)
#'
#' # change the bayesplot theme to theme_minimal and save the old theme
#' old <- bayesplot_theme_set(theme_minimal())
#' mcmc_hist(x)
#'
#' # change back to the previous theme
#' bayesplot_theme_set(old)
#' mcmc_hist(x)
#'
#' # change the default font size and family for bayesplots
#' bayesplot_theme_update(text = element_text(size = 16, family = "sans"))
#' mcmc_hist(x)
#'
#' # change back to the default
#' bayesplot_theme_set() # same as bayesplot_theme_set(theme_default())
#' mcmc_hist(x)
#'
#' # updating theme elements
#' color_scheme_set("brightblue")
#' bayesplot_theme_set(theme_dark())
#' mcmc_hist(x)
#'
#' bayesplot_theme_update(panel.background = element_rect(fill = "black"))
#' mcmc_hist(x)
#'
#' # to get the same plot without updating the theme we could also have
#' # used the bayeplot convenience function panel_bg()
#' bayesplot_theme_set(theme_dark())
#' mcmc_hist(x) + panel_bg(fill = "black")
#'
bayesplot_theme_get <- function() {
  if (!identical(.bayesplot_theme_env$gg_current, ggplot2::theme_get())) {
    .bayesplot_theme_env$current <- ggplot2::theme_get()
    .bayesplot_theme_env$gg_current <- ggplot2::theme_get()
    thm <- .bayesplot_theme_env$gg_current
  } else {
    thm <- .bayesplot_theme_env$current
  }
   thm
}

#' @rdname bayesplot_theme_get
#' @export
bayesplot_theme_set <- function(new = theme_default()) {
  missing <- setdiff(names(ggplot2::theme_gray()), names(new))
  if (length(missing)) {
    warning("New theme missing the following elements: ",
            paste(missing, collapse = ", "), call. = FALSE)
  }

  old <- .bayesplot_theme_env$current
  .bayesplot_theme_env$current <- new
  .bayesplot_theme_env$gg_current <- ggplot2::theme_get()
  invisible(old)
}

#' @rdname bayesplot_theme_get
#' @export
bayesplot_theme_update <- function(...) {
  bayesplot_theme_set(bayesplot_theme_get() + ggplot2::theme(...))
}

#' @rdname bayesplot_theme_get
#' @export
#' @importFrom ggplot2 %+replace%
bayesplot_theme_replace <- function(...) {
  bayesplot_theme_set(bayesplot_theme_get() %+replace% ggplot2::theme(...))
}



# internal ----------------------------------------------------------------

.bayesplot_theme_env <- new.env(parent = emptyenv())
.bayesplot_theme_env$current <- theme_default()
.bayesplot_theme_env$gg_current <- ggplot2::theme_grey()

