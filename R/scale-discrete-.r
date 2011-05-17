#' Discrete position.
#'
#' You can use continuous positions even with a discrete position scale - 
#' this allows you (e.g.) to place labels between bars in a bar chart.
#' Continuous positions are numeric values starting at one for the first
#' level, and increasing by one for each level (i.e. the labels are placed
#' at integer positions).  This is what allows jittering to work.
#'
#' @export scale_x_discrete scale_y_discrete
#' @examples
#' qplot(cut, data=diamonds, stat="bin")
#' qplot(cut, data=diamonds, geom="bar")
#' 
#' # The discrete position scale is added automatically whenever you
#' # have a discrete position.
#' 
#' (d <- qplot(cut, clarity, data=subset(diamonds, carat > 1), geom="jitter"))
#' 
#' d + scale_x_discrete("Cut")
#' d + scale_x_discrete("Cut", labels = c("Fair" = "F","Good" = "G",
#'   "Very Good" = "VG","Perfect" = "P","Ideal" = "I"))
#' 
#' d + scale_y_discrete("Clarity")
#' d + scale_x_discrete("Cut") + scale_y_discrete("Clarity")
#' 
#' # Use limits to adjust the which levels (and in what order)
#' # are displayed
#' d + scale_x_discrete(limits=c("Fair","Ideal"))
#' 
#' # you can also use the short hand functions xlim and ylim
#' d + xlim("Fair","Ideal", "Good")
#' d + ylim("I1", "IF")
#' 
#' # See ?reorder to reorder based on the values of another variable
#' qplot(manufacturer, cty, data=mpg)
#' qplot(reorder(manufacturer, cty), cty, data=mpg)
#' qplot(reorder(manufacturer, displ), cty, data=mpg)
#' 
#' # Use abbreviate as a formatter to reduce long names
#' qplot(reorder(manufacturer, cty), cty, data=mpg) +  
#'   scale_x_discrete(labels = abbreviate)
scale_x_discrete <- function(..., expand = c(0, 0.5)) {
  sc <- discrete_scale(c("x", "xmin", "xmax", "xend"), "position_d", identity, ..., 
    expand = expand, legend = FALSE)
    
  sc$range_c <- ContinuousRange$new()
  sc
}
scale_y_discrete <- function(..., expand = c(0, 0.5)) {
  sc <- discrete_scale(c("y", "ymin", "ymax", "yend"), "position_d", identity, ..., 
    expand = expand, legend = FALSE)
  sc$range_c <- ContinuousRange$new()
  sc  
}

# The discrete position scale maintains two separate ranges - one for
# continuous data and one for discrete data.  This complicates training and
# mapping, but makes it possible to place objects at non-integer positions,
# as is necessary for jittering etc.

#' @S3method scale_train position_d
scale_train.position_d <- function(scale, x) {
  if (is.discrete(x)) {
    scale$range$train(x, drop = scale$drop)
  } else {
    scale$range_c$train(x)
  }
}

#' @S3method scale_map position_d
scale_map.position_d <- function(scale, x) {
  if (is.discrete(x)) {
    limits <- scale_limits(scale)
    seq_along(limits)[match(as.character(x), limits)]
  } else {
    x
  }
}

#' @S3method scale_dimension position_d
scale_dimension.position_d <- function(scale, expand = scale$expand) {
  disc_range <- c(1, length(scale_limits(scale)))
  disc <- expand_range(disc_range, 0, expand[2], expand[2])
  cont <- expand_range(scale$range_c$range, expand[1], 0, expand[2])
  
  range(disc, cont)
}

scale_clone.position_d <- function(scale) {
  new <- scale
  new$range <- DiscreteRange$new()  
  new$range_c <- ContinuousRange$new()  
  
  new
}
