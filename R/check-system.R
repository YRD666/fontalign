#' Check system for required font rendering libraries and fonts
#'
#' Reports whether Cairo (with Pango), fontconfig, HarfBuzz, and the
#' recommended Noto font families are installed. Intended to be run once
#' per Linux server to verify the environment is suitable for
#' [fontalign_save()].
#'
#' @details The function performs only read-only checks (`pkg-config`,
#' `fc-list`). It does not modify the system.
#'
#' For each check, the output is one of:
#' \itemize{
#'   \item \code{ok} — present and meets the recommended version.
#'   \item \code{warn} — present but may have reduced capability.
#'   \item \code{fail} — not present; complex-script fallback will not work.
#' }
#'
#' @return Invisibly returns a data frame with columns
#'   \code{component}, \code{status}, \code{version}. The function is called
#'   for its side-effect of printing a human-readable summary.
#'
#' @examples
#' \dontrun{
#' fontalign_check_system()
#' }
#'
#' @export
fontalign_check_system <- function() {
  rows <- list()

  rows[[length(rows) + 1]] <- check_cairo_pango()
  rows[[length(rows) + 1]] <- check_fontconfig()
  rows[[length(rows) + 1]] <- check_harfbuzz()
  rows[[length(rows) + 1]] <- check_noto_cjk()
  rows[[length(rows) + 1]] <- check_arabic_font()
  rows[[length(rows) + 1]] <- check_emoji_font()
  rows[[length(rows) + 1]] <- check_r_backend()

  out <- do.call(rbind, rows)

  # Pretty print
  for (i in seq_len(nrow(out))) {
    mark <- switch(out$status[i],
                   ok   = cli::col_green("ok"),
                   warn = cli::col_yellow("warn"),
                   fail = cli::col_red("FAIL"))
    cli::cli_alert_info("{mark} {out$component[i]}: {out$version[i]}")
  }

  invisible(out)
}

#' Internal: detect Cairo + Pango versions
#' @noRd
check_cairo_pango <- function() {
  ver <- sys_version("pkg-config --modversion pangocairo")
  if (is.na(ver)) {
    report("Cairo + Pango", "fail",
           "pangocairo.pc not on pkg-config search path")
  } else {
    status <- if (utils::compareVersion(ver, "1.16") < 0) "warn" else "ok"
    note <- if (status == "warn") {
      "Pango < 1.16: complex-script shaping may fail"
    } else NULL
    report("Cairo + Pango", status, paste(ver, note))
  }
}

#' Internal: detect fontconfig version and total family count
#' @noRd
check_fontconfig <- function() {
  if (!has_exec("fc-list")) {
    return(report("fontconfig", "fail", "fc-list not found"))
  }
  ver <- sys_version("fc-list --version")
  count <- tryCatch(length(system("fc-list : family | sort -u",
                                  intern = TRUE)),
                    error = function(e) NA_integer_)
  report("fontconfig", "ok",
         sprintf("%s; %d families", ver, count))
}

#' Internal: detect HarfBuzz version
#' @noRd
check_harfbuzz <- function() {
  ver <- sys_version("pkg-config --modversion harfbuzz")
  if (is.na(ver)) {
    report("HarfBuzz", "warn",
           "harfbuzz.pc not found; ragg/svglite will fall back to FreeType")
  } else {
    report("HarfBuzz", "ok", ver)
  }
}

#' Internal: detect Noto CJK families for CJK fallback
#' @noRd
check_noto_cjk <- function() {
  if (!has_exec("fc-list")) {
    return(report("Noto CJK", "fail", "fc-list unavailable"))
  }
  out <- tryCatch(system("fc-list family | sort -u", intern = TRUE),
                  error = function(e) character())
  has_cjk <- any(grepl("Noto Sans CJK", out, fixed = TRUE))
  status <- if (has_cjk) "ok" else "warn"
  report("Noto CJK family",
         status,
         if (has_cjk) "Noto Sans CJK available"
         else "install fonts-noto-cjk for CJK fallback")
}

#' Internal: detect any font providing Arabic glyphs
#' @noRd
check_arabic_font <- function() {
  if (!has_exec("fc-list")) {
    return(report("Arabic font", "fail", "fc-list unavailable"))
  }
  out <- tryCatch(system(
    "fc-list :lang=ar family file",
    intern = TRUE), error = function(e) character())
  if (length(out) == 0) {
    return(report("Arabic font", "fail",
                  "no font registered with fontconfig lang=ar"))
  }
  n_fonts <- length(unique(sub(":[^:]+$", "", out)))
  report("Arabic font", "ok",
         sprintf("%d Arabic-capable font(s)", n_fonts))
}

#' Internal: detect emoji-capable color font
#' @noRd
check_emoji_font <- function() {
  if (!has_exec("fc-list")) {
    return(report("Color emoji", "warn", "fc-list unavailable"))
  }
  out <- tryCatch(system(
    "fc-list 2>&1", intern = TRUE), error = function(e) character())
  out <- out[grepl("(?i)emoji", out)]  # crude emoji detector
  out <- if (length(out)) out[1] else ""
  if (length(out) == 0 || !nzchar(out[1])) {
    return(report("Color emoji", "warn",
                  "no color emoji font; emoji render as black squares"))
  }
  report("Color emoji", "ok", sub(":.*", "", out[1]))
}

#' Internal: report whether recommended R backend packages are installed
#' @noRd
check_r_backend <- function() {
  pkgs <- c("ragg" = "ragg",
            "svglite" = "svglite",
            "rsvg" = "rsvg",
            "systemfonts" = "systemfonts",
            "textshaping" = "textshaping")
  states <- vapply(names(pkgs),
                   function(p) {
                     if (requireNamespace(p, quietly = TRUE)) "ok"
                     else "warn"
                   }, character(1))
  missing <- names(states)[states == "warn"]
  if (length(missing) == 0) {
    report("R backends", "ok", "ragg, svglite, rsvg, systemfonts")
  } else {
    report("R backends", "warn",
           sprintf("missing: %s", paste(missing, collapse = ", ")))
  }
}

#' Internal: construct a status row
#' @noRd
report <- function(component, status, version) {
  data.frame(component = component,
             status    = status,
             version   = version,
             stringsAsFactors = FALSE)
}
