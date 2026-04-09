#1. Load dataset ----
dataset1 <- read.table(file.choose(), sep= ",", header= TRUE,
                          stringsAsFactors= FALSE)

library(dplyr) # data manipulation
# Un-comment to install package if needed
# Install.packages("knitr")
# Install.packages("kableExtra")
library(knitr) # table formatting 
library(kableExtra) # table styling 

#2. EDA: Descriptive Statistics   ----
amesHousing%>%
  select_if(is.numeric)%>% # return numerical variables only
  psych::describe()%>%     # compute descriptive statistics 
  knitr::kable(
    align= "c",
    caption= "Descriptive Statistics for Ames Housing",
    format= "html",
    digits= 2
  )%>%
  kableExtra::kable_classic_2(
    #bootstrap_options= c("hover", "stripped", "condensed"),
    html_font= "calibri",
    position= "center",
    font_size= 13  )
 
#3. Data cleaning: median imputation for NA values ----
amesHousing <- amesHousing%>%
  mutate(across(where(is.numeric), ~ifelse(is.na(.), median(., na.rm= TRUE), .)))
  
#4. Correlation matrix for numeric variables ----
corMatrix<- amesHousing %>%
  select_if(is.numeric)%>%
  cor(use= "pairwise")

##5. Correlation matrix plot ----
#install.packages("RColorBrewer")
#install.packages("corrplot")
library(corrplot)       # plotting the correlation matrix
library(RColorBrewer)   # color palettes 
corrplot(corMatrix, type= "upper", col=brewer.pal(n=8, name="RdYlBu"))

##6.  Extract correlations with SalePrice ----
saleCor <- corMatrix[, "SalePrice"]                 # get the SalePrice column
saleCor<- saleCor[names(saleCor) != "SalePrice"]   # remove self-correlation

## Find the three variables (highest, lowest, moderate correlation) ----
vars<- list(
  high = names(which.max(saleCor)),
  low = names(which.min(abs(saleCor))), # Use abs() to get the coefficient closest to 0
  mid = names(which.min(abs(saleCor-0.5)))
)

options(scipen= 999) # disable scientific notation

## Create scatter plots ----
par(mfrow=c(1, 3))    # set plot layout to 1 row, 3 columns
for (i in 1:3){
  varName<- vars[[i]]
  plot(amesHousing[[varName]], amesHousing$SalePrice,
       xlab= varName, ylab= "Sale Price",
       main= paste("r =", round(saleCor[varName], 3))
       )
}


#7. Fit a multiple linear regression model ----
fit<- lm(SalePrice ~ Overall.Qual + Gr.Liv.Area + Garage.Cars + 
           Garage.Area + Total.Bsmt.SF, data= amesHousing)
summary(fit)

#9. Model Diagnostic ----
par(mfrow=c(2,2))  # Set plot layout to 2 row, 2 columns
plot(fit) # regression diagnostics plots

##10. Check of multicollinearity  using VIF ----
#install.packages("car")
library(car)  # regression diagnostics
vif(fit)

##11. Check for outliers ----
outlierTest(model= fit)

dev.off() # clear plotting area
## High-Leverage observations
hat.plot <- function(fit){
  p<- length(coefficients(fit))
  n<- length(fitted(fit))
  plot(hatvalues(fit), main= "Index Plot for Hat Vals")
  abline(h= c(2,3)*p/n, col= "blue", lty= 2)  
  identify(1:n, hatvalues(fit), names(hatvalues(fit)))
}

hat.plot(fit)

## Influential Observation (Cook's Distance) ----
cutoff <- 4/(nrow(amesHousing) - length(fit$coefficients) - 2)
plot(fit, which= 4, cook.level= cutoff)
abline(h= cutoff, lty= 2, col= "blue")

##12. Remove influential outliers identified via Cook's Distance ----
outliers <- c(1499, 2181, 2182)     # define influential outliers
amesHousing <- amesHousing[-outliers, ]  # remove outliers to reduce undue leverage on the model

## Transformation check ----
summary(powerTransform(amesHousing$SalePrice))

## Apply log normal transformation to improve normality ----
amesHousing$LogSalePrice <- log(amesHousing$SalePrice)

## Fit the cleaned model with Garage.Car removed due to high VIF ---- 
fitLog<- lm(LogSalePrice ~ Overall.Qual + Gr.Liv.Area + Garage.Area 
           + Total.Bsmt.SF, data= amesHousing)  

## Review model summary to assess coefficient stability and fit ----
summary(fitLog)

## Recheck multicollonearity ----
vif(fitLog)

## Re-check regression diagnostic after cleaning ----
par(mfrow= c(2,2))
plot(fitLog)

## Model comparison using AIC ----
AIC(fit, fitLog)


#13. Stepwise regression ----
library(MASS) # stats functions
bestModel<- stepAIC(lm(LogSalePrice ~ .-SalePrice, data= amesHousing[, sapply(amesHousing, is.numeric)]),
                    direction= "both")


#14. Compare models ----
AIC(bestModel, fitLog)
## Multicollinearity comparison ----
vif(bestModel)
vif(fitLog)