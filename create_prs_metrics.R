#!/usr/bin/env Rscript

###################################################################
####calculate PRS accuracy metrics for disease traits          ####
####Ying Wang (yiwang@broadinstitute.org) in June-2021         ####
###################################################################

########load packages needed########
library(data.table)
library(pROC) #for calculating AUC & its 95% CIs
library(boot) #for calculating CIs for NKr2 & h2l_NKr2
library(optparse) #for parsing arguments

#########parsing argument options########
option_list <- list(
  make_option(c("--pop"), type = "character", default = NULL, help = "Target ancestry"),
  make_option(c("--pheno"), type = "character", default = NULL, help = "Phenotype name in the phenotype file"),
  make_option(c("--K"), type = "character", default = NULL, help = "Disease prevalence"),
  make_option(c("--covs"), type = "character", default = NULL, help = "Covariates included in the prediction model, separated by comma"),
  make_option(c("--pc_numbers"), type = "character", default = "PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10", help = "PCs included in the prediction model, separated by comma"),
  make_option(c("--phenofile"), type = "character", default = NULL, help = "Full path and file name to phenotype files (including FID, IID, phenotypes etc.)"),
  make_option(c("--popfile"), type = "character", default = NULL, help = "Full path and file name to the file listing IDs for unrelated individuals in the target population (in the format of FID, IID as the first two columns)"),
  make_option(c("--prsfile"), type = "character", default = NULL, help = "Full path and file name to a *.profile generated by Plink1.* or *.sscore by Plink2.*, note using --sum to get the SCORESUM for Plink 1.* or cols=+scoresums to get SCORE1_SUM for Plink 2.* used in this script"),
  make_option(c("--covfile"), type = "character", default = NULL, help = "Full path and file name to the file including covariates (with headers including FID, IID and covariates)"),
  make_option(c("--pcfile"), type = "character", default = NULL, help = "Full path and file name to the file including PCs (e.g., headers including FID, IID, PC1, PC2, PC3...)"),
  make_option(c("--cohort_name"), type = "character", default = NULL, help = "Your specific Biobanks name"),
  make_option(c("--ldref"), type = "character", default = NULL, help = "The LD reference panel used (e.g., 1KG or UKB)"),
  make_option(c("--out"), type = "character", default = NULL, help = "Full path and file name for the output file of the prs accuracy metrics")
)

opt = parse_args(OptionParser(option_list=option_list))

prsfile <- opt$prsfile
popfile <- opt$popfile
phenofile <- opt$phenofile
pheno <- opt$pheno
covfile <- opt$covfile
covs <- opt$covs
pcfile <- opt$pcfile
pc_numbers <- opt$pc_numbers
K <- opt$K
out <- opt$out
pop <- opt$pop
cohort <- opt$cohort_name
ldref <- opt$ldref

#################reading input files#################
if(!is.null(prsfile)){
  prs_all <- fread(prsfile)
  fn <- tail(strsplit(prsfile, "/")[[1]], 1)
  prefix <- gsub(paste(c(".profile", ".sscore"), collapse = "|"), "",  fn) 
} else{
  print("Error: No PRS score files for input!")
}

if(!is.null(popfile)){
  ids <- fread(popfile, header = F) ##read target population ids
  prs <- prs_all[IID %in% ids$V2,]
} else{
  prs <- prs_all
}

if(!is.null(phenofile)){
  phen <- fread(phenofile) ##including fields FID, IID, ...phenotypes...
  prs[,PHENO := phen[prs, on = "IID"][,get(..pheno)]]
  prs <- prs[PHENO %in% c(0, 1, 2)] ##remove PHENO as -9 or other NA

  if(max(prs[,PHENO], na.rm = T) == 2){
    prs[,PHENO := PHENO - 1 ]# change disease phenotype from 1/2 control case to 0/1
  }
} else{
  print("No phenotype files for input")
}

##get SCORESUM based on plink version
scores <- c("SCORESUM", "SCORE1_SUM")
prs[,SCORESUM := get(grep(paste(scores, collapse = "|"), names(prs), value = T))]
prs[,ZSCORE := (SCORESUM - mean(SCORESUM[PHENO == 0]))/sd(SCORESUM[PHENO==0])] # z-score of the profile score


if(length(covs) > 0 & !is.null(covfile) & !is.null(covs)){
  covf <- fread(covfile)
  if(grepl(",", covs)){
    mycovs <- gsub("\\s+","",covs)
    mycovs <- strsplit(mycovs, ",")[[1]]
  } else{
    mycovs <- covs
  }
  prs <- cbind(prs, covf[prs, on = "IID",][, mycovs, with = FALSE])
} else{
  print("No covariates files for input")
}

if(!is.null(pcfile)){
  pcvecs <- strsplit(pc_numbers, ",")[[1]]
  pcs <- fread(pcfile, select = c("FID", "IID", pcvecs))
  prs <- cbind(prs, pcs[prs, on = "IID",][, ..pcvecs])
} else{
  print("No PC files for input")
}

prs <- na.omit(prs)
N <-  prs[PHENO %in% c(0,1), .N]


#################expression for models#################
if(!is.null(covfile) & !is.null(covs)){
  exp0 <- paste0( paste0(mycovs, collapse = " + "), paste0(" + ", pcvecs, collapse = "")) # base model with covariates only
  exp1 <- paste0("ZSCORE + ", paste0(mycovs, collapse = " + "), paste0(" + ", pcvecs, collapse = "")) # full model with PRS
} else{
  exp0 <- "1"
  exp1 <- paste0("ZSCORE")
}

#################logistic models#################
cal_NKr2_auc <- function(dat){
  ##base model with covariates only: Age + Sex + 10PCs
  glm0 <- glm(as.formula(paste("PHENO ~ ", exp0)), data = dat, family = binomial(logit)) 
  
  # logistic full model with PRS
  glm1 <- glm(as.formula(paste("PHENO ~ ", exp1)), data = dat, family = binomial(logit)) 
  
  # Calculate Cox & Snell R2 using log Likelihoods 
  LL1 <-  logLik(glm1)
  LL0 <-  logLik(glm0)
  CSr2 <-  round(1 - exp((2 / N) * (LL0[1] - LL1[1])), 6)
  
  # Calculate Nagelkerke's R2
  NKr2 <- round(CSr2 / (1 - exp((2 / N) * LL0[1])), 6)  
  # Test whether NKr2 is significantly different from 0
  devdiff <- round(glm0$deviance - glm1$deviance, 1) #Difference in deviance attributable to PRS
  df <- glm0$df.residual - glm1$df.residual #1 degree of freedom for single variable PRS
  NKr2_pval <- pchisq(devdiff, df, lower.tail = F)
  
  ## Calculate AUC using full model (PRS+covariates)
  auc1 <- round(auc(dat$PHENO, glm1$linear.predictors), 3)
  
  # Calculate AUC using only PRS
  glm3 <- glm(PHENO ~ ZSCORE, data = dat, family = binomial(logit))
  auc2 <- round(auc(dat$PHENO, glm3$linear.predictors), 3)
  
  auc1_2.5 <- round(ci.auc(dat$PHENO, glm1$linear.predictors)[1], 3)
  auc1_97.5 <- round(ci.auc(dat$PHENO, glm1$linear.predictors)[3], 3)
  
  auc2_2.5 <- round(ci.auc(dat$PHENO, glm3$linear.predictors)[1], 3)
  auc2_97.5 <- round(ci.auc(dat$PHENO, glm3$linear.predictors)[3], 3)
  
  return(data.frame(NKr2, NKr2_pval, 
                    auc1, auc1_2.5, auc1_97.5, 
                    auc2, auc2_2.5, auc2_97.5))
}  


tmp <- cal_NKr2_auc(prs)
NKr2 <- tmp$NKr2
NKr2_pval <- tmp$NKr2_pval

#################calculate proportion of variance explained on the liability scale#################
# Ref: Lee et al., Genet Epidemiol. 2012 Apr;36(3):214-24.
h2l_R2s <- function(k, r2, p) {
  # k baseline disease risk
  # r2 from a linear regression model of genomic profile risk score (R2v/NKr2)
  # p proportion of cases
  x <- qnorm(1 - k)
  z <- dnorm(x)
  i <- z / k
  C <- k * (1 - k) * k * (1 - k) / (z^2 * p * (1 - p))
  theta <- i * ((p - k) / (1 - k)) * (i * ((p - k) / (1 - k)) - x)
  e <- 1 - p^(2 * p) * (1 - p)^(2 * (1 - p))
  h2l_NKr2 <- C * e * r2 / (1 + C * e * theta * r2)
  h2l_NKr2 <- round(h2l_NKr2, 6)
  return(h2l_NKr2)
} 

P <- prs[PHENO == 1, .N] / N ##proportion of cases
if(K == "NULL" | is.null(K)){
  K  <- P
} else {
  K <- as.numeric(K)
}

# calculate liability scale using NKr2 

h2l_NKr2 <- h2l_R2s(K, NKr2, P)

# Calculate 95% CI for Nagelkerke's R2 & h2l_NKr2
boot_function <- function(data, indices){
  d <- data[indices,]
  NKr2 <- cal_NKr2_auc(d)$NKr2
  h2l_NKr2 <- h2l_R2s(K, NKr2, P)
  return(c(NKr2, h2l_NKr2))
}

results <- boot(prs, boot_function, R = 1000)

NKr2_2.5 <- round(boot.ci(results, type ="perc", index = 1)[[4]][1,][4], 6)
NKr2_97.5 <- round(boot.ci(results, type ="perc", index = 1)[[4]][1,][5], 6)
h2l_NKr2_2.5 <- round(boot.ci(results, type ="perc", index = 2)[[4]][1,][4], 6)
h2l_NKr2_97.5 <- round(boot.ci(results, type ="perc", index = 2)[[4]][1,][5], 6)

###########################################################
### all of the output summarised in a single data frame ###
###########################################################
# cohort - specific Biobank name
# ldref - LD reference panel
#prefix - prefix for PRS score filename
# N - total sample size with non-NA phenotypes
# K - base population risk of disease/disease prevalence used for calculating variance explained in liability scale
# P - proportion of sample that are cases
# NKr2 (NKr2_2.5, NKr2_97.5) - Nagelkerke's R2 (& its 95% CIs)
# NKr2_pval - p value of the NKr2 
# h2l_NKr2 &(h2l_NKr2_2.5, h2l_NKr2_97.5) - proportion of variance explained by the score on the liability scale (& its 95% CIs)
# auc1 (acu1_2.5, auc1_97.5) - AUC using full model (& its 95% CIs)
# auc2 (acu2_2.5, auc2_97.5) - AUC using PRS only (& its 95% CIs)

res <- data.frame(cohort, ldref, prefix, pheno, pop, N, K, P, 
                  NKr2, NKr2_pval, NKr2_2.5, NKr2_97.5,
                  h2l_NKr2, h2l_NKr2_2.5, h2l_NKr2_97.5,
                  tmp[,3:ncol(tmp)])

names(res) <- c("Cohort", "LDref", "prsFile", "Phenotype", "Pop", "N", "K", "P", 
                "NKr2","NKr2_pval", "NKr2_2.5", "NKr2_97.5", 
                "h2l_NKr2", "h2l_NKr2_2.5", "h2l_NKr2_97.5", 
                "auc1", "auc1_2.5", "auc1_97.5", 
                "auc2", "auc2_2.5", "auc2_97.5")

#print(res)

fwrite(res, file = out, sep = "\t")



