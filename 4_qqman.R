library(qqman)
library("Cairo")

file="METAANALYSIS2.both_have.TBL.with_pos"
out_manhattan="manhattan.both_have.pdf"
out_qqplot="qqplot.both_have.pdf"

gwasResults = as.data.frame(read.table(file,header=T))

pdf(out_manhattan,width=10,height=7)
manhattan(gwasResults,chr="CHR",bp = "POS",p="P",main = "Manhattan Plot",col = c("blue4", "lightskyblue"), suggestiveline=FALSE)
dev.off()

pdf(out_qqplot,width=8,height=7)
qq(gwasResults$P,main = "Q-Q plot of GWAS p-values")
dev.off()

################## PNG format of output #####################
CairoPNG("manhattan.both_have.png", width = 2000, height = 1000)
manhattan(gwasResults,chr="CHR",bp = "POS",p="P",main = "Manhattan Plot",col = c("blue4", "lightskyblue"), suggestiveline=FALSE)
dev.off()

CairoPNG("qqplot.both_have.png", width = 1000, height = 1000)
qq(gwasResults$P,main = "Q-Q plot of GWAS p-values")
dev.off()

################## calculate the lambda ########################
p_value=gwasResults$P
z = qnorm(p_value/ 2)
lambda = round(median(z^2, na.rm = TRUE) / qchisq(0.5, 1), 3)

print("The lambda is:") 
lambda
