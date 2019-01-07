#  chrRound
#'
#' Round a number to a character, preserving extra 0's
#'
#' @param x Number to round.
#'
#' @param digits Number of digits past the decimal point to keep.
#'
#' @details
#' Uses \code{\link[base]{sprintf}} to round a number, keeping extra 0's. Useful
#' for displaying values. Based on \code{\link[broman]{myround}}.
#'
#' @export
#'
#' @return
#' A vector of character strings.
#'
#' @examples
#' chrRound(51.01, 3)
#' chrRound(0.199, 2)
#'
#' @seealso
#' \code{\link[base]{round}}, \code{\link[base]{sprintf}}
#'
#' @keywords
#' utilities
chrRound <- function(x, digits = 1) {

    if(digits < 1) {
        stop("This is intended for the case digits >= 1.")
    }

    if(length(digits) > 1) {
        digits <- digits[1]
        warning("Digits should be a single integer. Only using digits[1].")
    }

    rounded <- sprintf(paste("%.", digits, "f", sep = ""), x)

    # Convert "-0.00" to "0.00"
    zero <- paste0("0.", paste(rep("0", digits), collapse = ""))
    rounded[rounded == paste0("-", zero)] <- zero

    return(rounded)
}
