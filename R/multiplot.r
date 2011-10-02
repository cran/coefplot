### Functions for plotting multiple coefplots at once
#' Plot multiple coefplots
#'
#' Plot the coeffcients from multiple models
#'
#' Plots a graph similar to \code{\link{coefplot}} but for multiple plots at once
#'
#' @export multiplot
#' @seealso \code{link{coefplot}}
#' @param \dots Models to be plotted
#' @param title  The name of the plot, if NULL then no name is given
#' @param xlab The x label
#' @param ylab The y label
#' @param innerCI How wide the inner confidence interval should be, normally 1 standard deviation.  If 0, then there will be no inner confidence interval.
#' @param outerCI How wide the outer confidence interval should be, normally 2 standard deviations.  If 0, then there will be no outer confidence interval.
#' @param lwdInner The thickness of the inner confidence interval
#' @param lwdOuter The thickness of the outer confidence interval
#' @param color The color of the points and lines
#' @param cex The text size multiplier, currently not used
#' @param textAngle The angle for the coefficient labels, 0 is horizontal
#' @param numberAngle The angle for the value labels, 0 is horizontal
#' @param zeroColor The color of the line indicating 0
#' @param zeroLWD The thickness of the 0 line
#' @param zeroType The type of 0 line, 0 will mean no line
## @param facet logical; If the coefficients should be faceted by the variables, numeric coefficients (including the intercept) will be one facet
#' @param scales The way the axes should be treated in a faceted plot.  Can be c("fixed", "free", "free_x", "free_y")
#' @param ncol The number of columns that the models should be plotted in
#' @param sort Determines the sort order of the coefficients.  Possible values are c("natural", "normal", "magnitude", "size", "alphabetical")
#' @param decreasing logical; Whether the coefficients should be ascending or descending
#' @param numeric logical; If true and factors has exactly one value, then it is displayed in a horizontal graph with constinuous confidence bounds.
#' @param fillColor The color of the confidence bounds for a numeric factor
#' @param alpha The transparency level of the numeric factor's confidence bound
#' @param horizontal logical; If the plot should be displayed horizontally
#' @param intercept logical; Whether the Intercept coefficient should be plotted
#' @param plot logical; If the plot should be drawn, if false then a data.frame of the values will be returned
#' @param factors Vector of factor variables that will be the only ones shown
#' @param only logical; If factors has a value this determines how interactions are treated.  True means just that variable will be shown and not its interactions.  False means interactions will be included.
#' @param shorten logical or character; If \code{FALSE} then coefficients for factor levels will include their variable name.  If \code{TRUE} coefficients for factor levels will be stripped of their variable names.  If a character vector of variables only coefficients for factor levels associated with those variables will the variable names stripped.
#' @param drop logical; if TRUE then models without valid coeffiecients to show will not be plotted
#' @return A ggplot object
#' @examples
#'
#' data(diamonds)
#' model1 <- lm(price ~ carat + cut, data=diamonds)
#' model2 <- lm(price ~ carat + cut + color, data=diamonds)
#' model3 <- lm(price ~ carat + color, data=diamonds)
#' multiplot(model1, model2, model3)
#' multiplot(model1, model2, model3, factors="color")
#' multiplot(model1, model2, model3, factors="color", drop=TRUE)
#' multiplot(model1, model2, model3, plot=FALSE)
#'
multiplot <- function(..., title="Coefficient Plot", xlab="Value", ylab="Coefficient", 
    					innerCI=1, outerCI=2, lwdInner=1, lwdOuter=0,  color="blue",
						cex=.8, textAngle=0, numberAngle=90,
						zeroColor="grey", zeroLWD=1, zeroType=2,
						#facet=FALSE, 
                        scales="fixed", ncol=length(unique(modelCI$Call)),
						sort="natural", decreasing=FALSE,
						numeric=FALSE, fillColor="grey", alpha=1/2,
						horizontal=FALSE, factors=NULL, only=NULL, shorten=TRUE,
						intercept=TRUE, plot=TRUE, drop=FALSE)
{
    # grab the models
    theDots <- list(...)
    
    # need to add arguments for buildModelCI
    # functionize modelMelt
    # need to change getModelInfo and buildModelCI and coefplot.lm so that shorten, factors and only are normal arguments and not part of ..., that way it will work better for this
    # get the modelCI for each model and make one big data.frame
    modelCI <- ldply(theDots, .fun=buildModelCI, outerCI=outerCI, innerCI=innerCI, intercept=intercept, numeric=numeric, sort=sort, decreasing=decreasing, factors=factors, only=only, shorten=shorten)
    
    # Turn the Call into a unique identifier for each model
    modelCI$Call <- as.numeric(factor(modelCI$Call, levels=unique(modelCI$Call)))
    
    ## if we are not plotting return modelCI right away
    if(!plot)
    {
        return(modelCI)
    }
    
    ## if drop is true get rid of models without valid coefficients
    if(drop)
    {
        notNA <- daply(modelCI, .variables="Call", function(x) { !all(is.na(x$Coef)) })
        #return(notNA)
        modelCI <- modelCI[modelCI$Call %in% which(notNA == TRUE), ]
    }
    
    # which columns will be kept in the melted data.frame
    keepCols <- c("LowOuter", "HighOuter", "LowInner", "HighInner", "Coef", "Checkers", "CoefShort", "Call")
    
    modelMelting <- meltModelCI(modelCI=modelCI, keepCols=keepCols, 
                        id.vars=c("CoefShort", "Checkers", "Call"), variable_name="Type", outerCols=c("LowOuter", "HighOuter"), 
                        innerCols=c("LowInner", "HighInner"))
    #modelMelt <- modelMelting$modelMelt
    #return(modelMelting)
    modelMeltInner <- modelMelting$modelMeltInner
    modelMeltOuter <- modelMelting$modelMeltOuter
    #return(modelMelting)
    rm(modelMelting); gc()      # housekeeping
    
    if(plot)
    {
        p <- buildPlotting(modelCI=modelCI, modelMeltInner=modelMeltInner, modelMeltOuter=modelMeltOuter,
                           title=title, xlab=xlab, ylab=ylab,
                           lwdInner=lwdInner, lwdOuter=lwdOuter, color=color, cex=cex, textAngle=textAngle, 
                           numberAngle=numberAngle, zeroColor=zeroColor, zeroLWD=zeroLWD, outerCI=outerCI, innerCI=innerCI,
                           zeroType=zeroType, numeric=numeric, fillColor=fillColor, alpha=alpha, 
                           horizontal=horizontal, facet=FALSE, scales="fixed")
    
        p + facet_wrap(~Call, scales=scales, ncol=ncol)
    }else
    {
        return(modelCI)
    }
    
    #return(modelCI)
}
