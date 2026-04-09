# 🏡 Ames Housing Price Prediction

> What actually drives house prices? A regression analysis across 2,930 property sales in Ames, Iowa (2006–2010).

---

## 📌 Overview

Built and refined a multiple linear regression model to predict residential sale prices using the open-source Ames Housing dataset. The analysis follows a full modelling pipeline — from exploratory analysis and preprocessing through to outlier handling, multicollinearity correction, log transformation, and stepwise variable selection.
 
**Tools:** R, corrplot, MASS, car, RColorBrewer

---

## 📊 Results

| Model | R² | Adjusted R² | AIC |
|---|---|---|---|
| Original (5 predictors) | 78.06% | 78.03% | 70,032.93 |
| Refined (log + outlier removal) | 82.85% | 82.82% | -2,094.16 |
| Stepwise (automated selection) | — | — | **-3,692.09** |

> The refined model explains **82.82% of sale price variability** using 4 interpretable predictors, with a dramatically lower AIC after log transformation.

---

## 🔍 Key Findings

- **Overall Quality** is the strongest single predictor of sale price (r = 0.799) — perception of quality matters as much as physical size
- **Above-ground living area**, **garage capacity**, and **basement size** round out the top predictors — all statistically significant across model specifications
- Log transformation of SalePrice substantially improved normality and model fit, reducing AIC from 70,032 to -2,094
- Garage.Cars and Garage.Area exhibited high multicollinearity (VIF > 5) — Garage.Cars was dropped to improve model stability
- Three influential outliers (observations 1499, 2181, 2182) identified via Cook's Distance were removed to prevent coefficient distortion
- Bidirectional stepwise regression achieved the lowest AIC (-3,692) but introduced multicollinearity across 27 predictors, reducing interpretability

---

## 🗂️ Repository Structure

```
ames-housing-price-prediction/
│
├── realEstate.R      # Full analysis script
├── report.pdf        # Written analysis with visualisations
└── README.md         # Project overview
```

---

## ⚙️ How to Run

1. Clone the repository
2. Download the Ames Housing dataset from [kaggle](https://www.kaggle.com/datasets/prevek18/ames-housing-dataset) or the [Journal of Statistics Education](http://jse.amstat.org/v19n3/decock/AmesHousing.xls)
3. Open `realEstate.R` in RStudio
4. Install required packages if needed:

```r
install.packages(c("dplyr", "psych", "knitr", "kableExtra",
                   "corrplot", "RColorBrewer", "MASS", "car"))
```

5. Run the script sequentially — tasks are clearly numbered in the comments

---

## ⚠️ Limitations

- Residuals exhibited **heteroscedasticity and non-normality** even after log transformation, violating key linear regression assumptions
- The stepwise model, while achieving the best AIC, includes **significant multicollinearity** that complicates practical interpretation
- The dataset is geographically limited to Ames, Iowa — findings may not generalise to other housing markets
- Non-linear methods (e.g. Random Forest, Gradient Boosting) would likely outperform linear regression on this data and are a natural next step

---

## 👤 Author

**Akheem Amisi**  
MPS Analytics — Northeastern University  
[LinkedIn](https://linkedin.com/in/akheem-amisi)
