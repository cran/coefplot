% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/coefplot.r
\name{coefplot.model_fit}
\alias{coefplot.model_fit}
\title{coefplot.model_fit}
\usage{
\method{coefplot}{model_fit}(model, ...)
}
\arguments{
\item{model}{A parsnip object}

\item{\dots}{All arguments are passed on to \code{\link{coefplot.default}}.  Please see that function for argument information.}
}
\description{
Coefplot method for parsnip objects
}
\details{
Pulls model element out of parsnip object then calls \code{coefplot}.
}
\author{
Jared P. Lander
}
