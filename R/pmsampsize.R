#' pmsampsize  
#' - Calculates the minimum sample size required for developing a multivariable prediction model
#' 
#' \code{pmsampsize} computes the minimum sample size required for the development of a new
#' multivariable prediction model using the criteria proposed by Riley \emph{et al}. 2018. \code{pmsampsize}
#' can be used to calculate the minimum sample size for the development of models with
#' continuous, binary or survival (time-to-event) outcomes. Riley \emph{et al}. lay out a series of
#' criteria the sample size should meet. These aim to minimise the overfitting and to ensure 
#' precise estimation of key parameters in the prediction model. \cr \cr
#' For continuous outcomes, there are four criteria: \cr
#' i) small overfitting defined by an expected shrinkage of predictor effects by 10\% or less, \cr
#' ii) small absolute difference of 0.05 in the model's apparent and adjusted R-squared value, \cr 
#' iii) precise estimation of the residual standard deviation, and \cr
#' iv) precise estimation of the average outcome value. \cr \cr
#' The sample size calculation requires the user to pre-specify (e.g. based on previous evidence)
#' the anticipated R-squared of the model, and the average outcome value and standard deviation 
#' of outcome values in the population of interest. \cr \cr
#' For binary or survival (time-to-event) outcomes, there are three criteria: \cr
#' i) small overfitting defined by an expected shrinkage of predictor effects by 10\% or less, \cr
#' ii) small absolute difference of 0.05 in the model's apparent and adjusted Nagelkerke's R-squared
#' value, and \cr 
#' iii) precise estimation (within +/- 0.05) of the average outcome risk in the
#' population for a key timepoint of interest for prediction.
#'
#' 
#' @author Joie Ensor (Keele University, j.ensor@keele.ac.uk), 
#' @author Emma C. Martin (University of Leicester, emma.martin@le.ac.uk),
#' @author Richard D. Riley (Keele University, r.riley@keele.ac.uk)
#'  
#' @param type specifies the type of analysis for which sample size is being calculated 
#'      \itemize{
#'          \item \code{"c"} specifies sample size calculation for a prediction model with a continuous outcome
#'          \item \code{"b"} specifies sample size calculation for a prediction model with a binary outcome
#'          \item \code{"s"} specifies sample size calculation for a prediction model with a survival (time-to-event) outcome
#'      }
#' @param rsquared specifies the expected value of the (Cox-Snell) R-squared of the new model, 
#' where R-squared is the percentage of variation in outcome values explained by the model. 
#' For example, the user may input the value of the (Cox-Snell) R-squared reported for a 
#' previous prediction model study in the same field.  If taking a value from a previous 
#' prediction model development study, users should input the model's adjusted R-squared 
#' value, not the apparent R-squared value, as the latter is optimistic (biased).  However, 
#' if taking the R-squared value from an external validation of a previous model, the 
#' apparent R-squared can be used (as the validation data was not used for development, and 
#' so R-squared apparent is then unbiased).  Note that for binary and survival outcome 
#' models, the Cox-Snell R-squared value is required; this is the generalised version of 
#' the well-known R-squared for continuous outcomes, based on the likelihood.  The papers 
#' by Riley et al. (see references) outline how to obtain the Cox-Snell R-squared value 
#' from published studies if they are not reported, using other information (such as the 
#' C-statistic or Nagelkerke's R-squared).  Users should be conservative with their chosen 
#' R-squared value; for example, by taking the R-squared value from a previous model, even 
#' if they hope their new model will improve performance.
#' 
#' @param parameters specifies the number of candidate predictor parameters for potential 
#' inclusion in the new prediction model.  Note that this may be larger than the number of 
#' candidate predictors, as categorical and continuous predictors often require two or more 
#' parameters to be estimated.
#' 
#' @param shrinkage specifies the level of shrinkage desired at internal validation after 
#' developing the new model. Shrinkage is a measure of overfitting, and can range from 0 to 1, 
#' with higher values denoting less overfitting. We recommend a shrinkage = 0.9 (the 
#' default in \code{pmsampsize}), which indicates that the predictor effect (beta coefficients) in
#' the model would need to be shrunk by 10\% to adjust for overfitting. See references
#' below for further information.
#' 
#' @param prevalence (binary outcome option) specifies the overall outcome proportion 
#' (for a prognostic model) or
#' overall prevalence (for a diagnostic model) expected within the model development
#' dataset. This should be derived based on previous studies in the same population.
#' 
#' @param rate (survival outcome option) specifies the overall event rate in the population of interest,
#' for example as obtained from a previous study, for the survival outcome of interest.
#' 
#' @param timepoint (survival outcome option) specifies the timepoint of interest for prediction.
#' 
#' @param meanfup (survival outcome option) specifies the average (mean) follow-up time 
#' anticipated for individuals in the model development dataset, 
#' for example as taken from a previous study in the population of interest.
#' 
#' @param  intercept (continuous outcome options) specifies the average outcome value in the population of
#' interest e.g. the average blood pressure, or average pain score. 
#' This could be based on a previous study, or on clinical knowledge.
#' 
#' @param sd (continuous outcome options) specifies the standard deviation (SD) of 
#' outcome values in the population e.g.
#' the SD for blood pressure in patients with all other predictors set to the average.
#' This could again be based on a previous study, or on clinical knowledge.
#' 
#' @param mmoe (continuous outcome options) multiplicative margin of error (MMOE) 
#' acceptable for calculation of the
#' intercept. The default is a MMOE of 10\%. Confidence interval for the intercept will be
#' displayed in the output for reference. See references below for further information.
#'
#' @import stats 
#'    
#' @examples
#' ## Examples based on those included in two papers by Riley et al. 
#' ## published in Statistics in Medicine (2018).
#' 
#' ## Binary outcomes (Logistic prediction models)
#' # Use pmsampsize to calculate the minimum sample size required to develop a
#' # multivariable prediction model for a binary outcome using 24 candidate
#' # predictor parameters. Based on previous evidence, the outcome prevalence is
#' # anticipated to be 0.174 (17.4%) and a lower bound (taken from the adjusted
#' # Cox-Snell R-squared of an existing prediction model) for the new model's
#' # R-squared value is 0.288
#' 
#' pmsampsize(type = "b", rsquared = 0.288, parameters = 24, prevalence = 0.174)
#' 
#' ## Survial outcomes (Cox prediction models)
#' # Use pmsampsize to calculate the minimum sample size required for developing
#' # a multivariable prediction model with a survival outcome using 25 candidate
#' # predictors. We know an existing prediction model in the same field has an
#' # R-squared adjusted of 0.051. Further, in the previous study the mean
#' # follow-up was 2.07 years, and overall event rate was 0.065. We select a
#' # timepoint of interest for prediction using the newly developed model of 2
#' # years
#' 
#' pmsampsize(type = "s", rsquared = 0.051, parameters = 25, rate = 0.065, 
#'            timepoint = 2, meanfup = 2.07)
#' 
#' ## Continuous outcomes (Linear prediction models)
#' # Use pmsampsize to calculate the minimum sample size required for developing
#' # a multivariable prediction model for a continuous outcome (here, FEV1 say),
#' # using 25 candidate predictors.  We know an existing prediction model in the
#' # same field has an R-squared adjusted of 0.2, and that FEV1 values in the
#' # population have a mean of 1.9 and SD of 0.6
#' 
#' pmsampsize(type = "c", rsquared = 0.2, parameters = 25, intercept = 1.9, sd = 0.6)
#'
#' @references  Riley RD, Snell KIE, Ensor J, Burke DL, Harrell FE, Jr., Moons KG, Collins GS.  
#' Minimum sample size required for developing a multivariable prediction model: Part I continuous outcomes. 
#' \emph{Statistics in Medicine}. 2018 (in-press). doi: 10.1002/sim.7993
#' 
#' @references Riley RD, Snell KIE, Ensor J, Burke DL, Harrell FE, Jr., Moons KG, Collins GS.  
#' Minimum sample size required for developing a multivariable prediction model: 
#' Part II binary and time-to-event outcomes.
#' \emph{Statistics in Medicine}. 2018 (in-press). doi: 10.1002/sim.7992


#' @export
pmsampsize <- function(type,
                       rsquared,
                       parameters,
                       shrinkage = 0.9,
                       prevalence = NA,
                       rate = NA,
                       timepoint = NA,
                       meanfup = NA,
                       intercept = NA,
                       sd = NA,
                       mmoe=1.1) {
  
  # error checking 
  pmsampsize_errorcheck(type=type,rsquared=rsquared,parameters=parameters,shrinkage=shrinkage,prevalence=prevalence,
             rate=rate,timepoint=timepoint,meanfup=meanfup,intercept=intercept,sd=sd,mmoe=mmoe)
  
  # choose function based on analysis type 
  if (type == "c") out <- pmsampsize_cont(rsquared=rsquared,parameters=parameters,intercept=intercept,
                                   sd=sd,shrinkage=shrinkage,mmoe=mmoe)
  if (type == "b") out <- pmsampsize_bin(rsquared=rsquared,parameters=parameters,prevalence=prevalence,
                                         shrinkage=shrinkage)
  if (type == "s") out <- pmsampsize_surv(rsquared=rsquared,parameters=parameters,rate=rate,
                                          timepoint=timepoint,meanfup=meanfup,shrinkage=shrinkage,mmoe=mmoe)
  
  
  est <- out
  class(est) <- "pmsampsize"
  est
  

}


#' @export
print.pmsampsize <- function(x, ...) {
  
  if (x$type == "continuous") {
    cat("NB: Assuming 0.05 acceptable difference in apparent & adjusted R-squared \n")
    cat("NB: Assuming MMOE <= 1.1 in estimation of intercept & residual standard deviation \n")
    cat("SPP - Subjects per Predictor Parameter \n \n")
    
  }
  if (x$type == "survival") {
    cat("NB: Assuming 0.05 acceptable difference in apparent & adjusted R-squared \n")
    cat("NB: Assuming 0.05 margin of error in estimation of overall risk at time point =", x$timepoint, " \n")
    cat("NB: Events per Predictor Parameter (EPP) assumes overall event rate =", x$rate, " \n \n")
  }
  if (x$type == "binary") {
    cat("NB: Assuming 0.05 acceptable difference in apparent & adjusted R-squared \n")
    cat("NB: Assuming 0.05 margin of error in estimation of intercept \n")
    cat("NB: Events per Predictor Parameter (EPP) assumes prevalence =", x$prevalence, " \n \n")
  }
  print(x$results_table)

  if (x$type == "continuous") {
    cat(" \n Minimum sample size required for new model development based on user inputs =", x$sample_size, " \n \n ")
    cat("* 95% CI for intercept = (",x$int_lci,", ", x$int_uci, "), for sample size n = ",x$sample_size,sep = "")
  }
  if (x$type == "survival") {
    cat(" \n Minimum sample size required for new model development based on user inputs = ", x$sample_size, ", \n ",sep = "")
    cat("corresponding to", x$tot_per_yrs_final, "person-years of follow-up, with", ceiling(x$events), "outcome events \n ")
    cat("assuming an overall event rate =", x$rate, "and therefore an EPP =", x$EPP, " \n \n ")
    cat("* 95% CI for overall risk = (",x$int_lci,", ", x$int_uci, "), for true value of ", x$int_cuminc, " and sample size n = ",x$sample_size,sep = "")
  }
  if (x$type == "binary") {
    cat(" \n Minimum sample size required for new model development based on user inputs = ", x$sample_size, ", \n ",sep = "")
    cat("with ", ceiling(x$events), " events (assuming an outcome prevalence = ", x$prevalence, ") and an EPP = ", x$EPP, " \n \n ",sep = "")
   
  }
}

#' @export
summary.pmsampsize <- function(object, ...) {
  
  if (object$type == "continuous") {
    cat("NB: Assuming 0.05 acceptable difference in apparent & adjusted R-squared \n")
    cat("NB: Assuming MMOE <= 1.1 in estimation of intercept & residual standard deviation \n")
    cat("SPP - Subjects per Predictor Parameter \n \n")
    
  }
  if (object$type == "survival") {
    cat("NB: Assuming 0.05 acceptable difference in apparent & adjusted R-squared \n")
    cat("NB: Assuming 0.05 margin of error in estimation of overall risk at time point =", object$timepoint, " \n")
    cat("NB: Events per Predictor Parameter (EPP) assumes overall event rate =", object$rate, " \n \n")
  }
  if (object$type == "binary") {
    cat("NB: Assuming 0.05 acceptable difference in apparent & adjusted R-squared \n")
    cat("NB: Assuming 0.05 margin of error in estimation of intercept \n")
    cat("NB: Events per Predictor Parameter (EPP) assumes prevalence =", object$prevalence, " \n \n")
  }
  print(object$results_table)
  
  if (object$type == "continuous") {
    cat(" \n Minimum sample size required for new model development based on user inputs =", object$sample_size, " \n \n ")
    cat("* 95% CI for intercept = (",object$int_lci,", ", object$int_uci, "), for sample size n = ",object$sample_size,sep = "")
  }
  if (object$type == "survival") {
    cat(" \n Minimum sample size required for new model development based on user inputs = ", object$sample_size, ", \n ",sep = "")
    cat("corresponding to", object$tot_per_yrs_final, "person-years of follow-up, with", ceiling(object$events), "outcome events \n ")
    cat("assuming an overall event rate =", object$rate, "and therefore an EPP =", object$EPP, " \n \n ")
    cat("* 95% CI for overall risk = (",object$int_lci,", ", object$int_uci, "), for true value of ", object$int_cuminc, " and sample size n = ",object$sample_size,sep = "")
  }
  if (object$type == "binary") {
    cat(" \n Minimum sample size required for new model development based on user inputs = ", object$sample_size, ", \n ",sep = "")
    cat("with", ceiling(object$events), "events (assuming an outcome prevalence =", object$prevalence, ") and an EPP =", object$EPP, " \n \n ")

  }
}
  