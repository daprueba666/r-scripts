#setwd("E:/Git/github/r-scripts/analysis/") # please update path
setwd("/Users/sebastian/git/github/r-scripts/analysis/")

library(data.table)
library(effsize)

# use defined colors
source("../colors.R")

# length of all text block lifespans
textblock_lifespan_length <- fread("data/textblock_lifespan_length.csv", header=FALSE, sep=",", quote="\"", strip.white=TRUE, showProgress=TRUE, encoding="UTF-8", na.strings=c("", "null"), stringsAsFactors=FALSE)
names(textblock_lifespan_length) <- c("PostId", "PostTypeId", "RootPostBlockId", "LifespanLength")

# length of all code block lifespans
codeblock_lifespan_length <- fread("data/codeblock_lifespan_length.csv", header=FALSE, sep=",", quote="\"", strip.white=TRUE, showProgress=TRUE, encoding="UTF-8", na.strings=c("", "null"), stringsAsFactors=FALSE)
names(codeblock_lifespan_length) <- c("PostId", "PostTypeId", "RootPostBlockId", "LifespanLength")


##########
# text
##########
summary(textblock_lifespan_length$LifespanLength)
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 1.00     1.00     1.00     2.69     3.00 80655.00 

n <- nrow(textblock_lifespan_length)
n_1 <- length(textblock_lifespan_length$LifespanLength[textblock_lifespan_length$LifespanLength==1])
n
# 71,755,618
n_1
# 39,781,224
n_1/n*100
# 55.43987

n_revised <- length(textblock_lifespan_length$LifespanLength[textblock_lifespan_length$LifespanLength>1])
n_revised
# 31,974,394
n_revised/n*100
# 44.56013

TextLifespanLength <- ifelse(textblock_lifespan_length$LifespanLength>10, 10, textblock_lifespan_length$LifespanLength)
TextLifespanLengthTable <- table(TextLifespanLength)


##########
# code
##########
summary(codeblock_lifespan_length$LifespanLength)
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 1.0      1.0      1.0      2.5      3.0 562484.0

n <- nrow(codeblock_lifespan_length)
n_1 <- length(codeblock_lifespan_length$LifespanLength[codeblock_lifespan_length$LifespanLength==1])
n
# 43,729,000
n_1
# 21,925,668
n_1/n*100
# 50.13988

n_revised <- length(codeblock_lifespan_length$LifespanLength[codeblock_lifespan_length$LifespanLength>1])
n_revised
# 21,803,332
n_revised/n*100
# 49.86012

CodeLifespanLength <- ifelse(codeblock_lifespan_length$LifespanLength>10, 10, codeblock_lifespan_length$LifespanLength)
CodeLifespanLengthTable <- table(CodeLifespanLength)


##########
# differences
##########

revised_textblocks <- textblock_lifespan_length[textblock_lifespan_length$LifespanLength>1,]
revised_codeblocks <- codeblock_lifespan_length[codeblock_lifespan_length$LifespanLength>1,]

summary(revised_textblocks$LifespanLength)
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 2.00     2.00     4.00     4.78     4.00 80655.00 

sd(revised_textblocks$LifespanLength)
# 17.27118

summary(revised_codeblocks$LifespanLength)
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 2.0      2.0      3.0      4.1      4.0 562484.0

sd(revised_codeblocks$LifespanLength)
# 169.7564

wilcox.test(revised_codeblocks$LifespanLength,
            revised_textblocks$LifespanLength,
            alternative="two.sided",
            paired=F, correct=T)
# W = 3.0348e+14, p-value < 2.2e-16
# alternative hypothesis: true location shift is not equal to 0

#cliff.delta(revised_textblocks$LifespanLength, revised_codeblocks$LifespanLength)
# too slow...

cohen.d(revised_codeblocks$LifespanLength, # "treatment"
        revised_textblocks$LifespanLength, # "control"
        paired=FALSE)
# d estimate: -0.006360512 (negligible)
# 95 percent confidence interval:
#   inf sup 
# NA  NA 


##########
# plot
##########

# plot histogram (only code)
quartz(type="pdf", file="figures/postblocklifespan_length_code.pdf", width=8, height=6) # prevents unicode issues in pdf
#pdf("figures/postblocklifespan_length.pdf", width=8, height=6)
par(
  bg="white",
  #mar = c(3, 3, 3, 1)+0.1, # subplot margins (bottom, left, top, right)
  #  omi = c(0.0, 0.0, 0.0, 0.0),  # outer margins in inches (bottom, left, top, right)
  mfrow = c(1, 1),
  #pin = (width, height)
  #mfcol # draw in columns
  # increase font size
  cex=1.3,
  cex.main=1.3,
  cex.sub=1,
  cex.lab=1,
  cex.axis=1
)

# code
hist(CodeLifespanLength, 
     main="Code block version count (n=43,728,155)", 
     freq=TRUE,
     xlab="",
     ylab="",
     border="white",
     col="white",
     #labels=c(rep("", 10), "Selected"),
     xlim=c(0, 10),
     ylim=c(0, 25000000),
     breaks=0:10,
     xaxt="n",
     yaxt="n"
)
for (y in seq(0, 25000000, by=5000000)) {
  segments(x0=-0.5, y0=y, x1=10, y1=y, lty=1, lwd=1, col=gray_lighter)
}
hist(CodeLifespanLength,
     add=TRUE,
     main="", 
     freq=TRUE,
     xlab="x",
     ylab="y",
     border=gray_dark,
     col=c(gray_lighter, rep(gray_selected, 9)),
     #labels=c(rep("", 10), "Selected"),
     xlim=c(0, 10),
     ylim=c(0, 25000000),
     breaks=0:10,
     xaxt="n",
     yaxt="n"
)
boxplot(CodeLifespanLength-0.5,
        add=TRUE,
        outline=FALSE,
        horizontal=TRUE,
        ylim=c(0, 10),
        log="",
        col=gray_dark,
        # https://stackoverflow.com/a/28890111
        lwd=2,
        medlwd=2,
        #staplelty=0,
        whisklty=1,
        #staplelty=0,
        whiskcol="black",
        medcol="black",
        boxcol="black",
        staplecol="black",
        boxwex=2600000,
        axes=FALSE
        #xaxt="n"
        #yaxt="n"
)
# median
abline(v=0.5, lty=1, lwd=2, col=gray_darker)
# labels
text(5.0, 7500000, "Edited code blocks (49.9%)", font=3, col="black", cex=1.0)
# axes
axis(1, at=seq(-0.5, 9.5, by=1), labels=c(seq(0, 9, by=1), "\u2265 10"))
axis(2, at=seq(0, 25000000, by=5000000), labels=c("0", "5m", "10m", "15m", "20m", "25m"), las=2)

dev.off()


# plot histogram (text and code)
quartz(type="pdf", file="figures/postblocklifespan_length.pdf", width=18, height=6) # prevents unicode issues in pdf
#pdf("figures/postblocklifespan_length.pdf", width=18, height=6)
par(
  bg="white",
  #mar = c(3, 3, 3, 1)+0.1, # subplot margins (bottom, left, top, right)
  #  omi = c(0.0, 0.0, 0.0, 0.0),  # outer margins in inches (bottom, left, top, right)
  mfrow = c(1, 2),
  #pin = (width, height)
  #mfcol # draw in columns
  # increase font size
  cex=1.3,
  cex.main=1.3,
  cex.sub=1,
  cex.lab=1,
  cex.axis=1
)

# text
hist(TextLifespanLength, 
     main="Text block version count (n=71,756,580)", 
     freq=TRUE,
     xlab="",
     ylab="",
     border="white",
     col="white",
     #labels=c(rep("", 10), "Selected"),
     xlim=c(0, 10),
     ylim=c(0, 40000000),
     breaks=0:10,
     xaxt="n",
     yaxt="n"
)
for (y in seq(0, 40000000, by=10000000)) {
  segments(x0=-0.5, y0=y, x1=10, y1=y, lty=1, lwd=1, col=gray_lighter)
}
hist(TextLifespanLength,
     add=TRUE,
     main="", 
     freq=TRUE,
     xlab="x",
     ylab="y",
     border=gray_dark,
     col=c(gray_lighter, rep(gray_selected, 9)),
     #labels=c(rep("", 10), "Selected"),
     xlim=c(0, 10),
     ylim=c(0, 40000000),
     breaks=0:10,
     xaxt="n",
     yaxt="n"
)
boxplot(TextLifespanLength-0.5,
        add=TRUE,
        outline=FALSE,
        horizontal=TRUE,
        ylim=c(0, 10),
        log="",
        col="white",
        # https://stackoverflow.com/a/28890111
        lwd=2,
        medlwd=2,
        #staplelty=0,
        whisklty=1,
        #staplelty=0,
        whiskcol=gray_darker,
        medcol=gray_darker,
        boxcol=gray_darker,
        staplecol=gray_darker,
        boxwex=3200000,
        axes=FALSE
        #xaxt="n"
        #yaxt="n"
)
# median
abline(v=0.5, lty=1, lwd=2, col=gray_darker)
# labels
text(3.1, 14000000, "Edited Blocks (44.6%)", font=4, col=gray_darker, cex=1.1)
# axes
axis(1, at=seq(-0.5, 9.5, by=1), labels=c(seq(0, 9, by=1), "\u2265 10"))
axis(2, at=seq(0, 40000000, by=10000000), labels=c("0", "10m", "20m", "30m", "40m"), las=2)


# code
hist(CodeLifespanLength, 
     main="Code block version count (n=43,728,155)", 
     freq=TRUE,
     xlab="",
     ylab="",
     border="white",
     col="white",
     #labels=c(rep("", 10), "Selected"),
     xlim=c(0, 10),
     ylim=c(0, 40000000),
     breaks=0:10,
     xaxt="n",
     yaxt="n"
)
for (y in seq(0, 40000000, by=10000000)) {
  segments(x0=-0.5, y0=y, x1=10, y1=y, lty=1, lwd=1, col=gray_lighter)
}
hist(CodeLifespanLength,
     add=TRUE,
     main="", 
     freq=TRUE,
     xlab="x",
     ylab="y",
     border=gray_dark,
     col=c(gray_lighter, rep(gray_selected, 9)),
     #labels=c(rep("", 10), "Selected"),
     xlim=c(0, 10),
     ylim=c(0, 40000000),
     breaks=0:10,
     xaxt="n",
     yaxt="n"
)
boxplot(CodeLifespanLength-0.5,
        add=TRUE,
        outline=FALSE,
        horizontal=TRUE,
        ylim=c(0, 10),
        log="",
        col="white",
        # https://stackoverflow.com/a/28890111
        lwd=2,
        medlwd=2,
        #staplelty=0,
        whisklty=1,
        #staplelty=0,
        whiskcol=gray_darker,
        medcol=gray_darker,
        boxcol=gray_darker,
        staplecol=gray_darker,
        boxwex=3200000,
        axes=FALSE
        #xaxt="n"
        #yaxt="n"
)
# median
abline(v=0.5, lty=1, lwd=2, col=gray_darker)
# labels
text(3.1, 14000000, "Edited Blocks (49.9%)", font=4, col=gray_darker, cex=1.1)
# axes
axis(1, at=seq(-0.5, 9.5, by=1), labels=c(seq(0, 9, by=1), "\u2265 10"))
axis(2, at=seq(0, 40000000, by=10000000), labels=c("0", "10m", "20m", "30m", "40m"), las=2)

dev.off()

##########
# text and code in one plot
##########
PostBlockLifespanLength <- c(TextLifespanLength, CodeLifespanLength)
n <- length(PostBlockLifespanLength)
n
# 115,484,618

summary(PostBlockLifespanLength)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.000   1.000   1.000   2.373   3.000  10.000 

sd(PostBlockLifespanLength)
# 2.190244

n_not_revised <- length(which(PostBlockLifespanLength==1))
n_not_revised
# 61,706,892
n_not_revised/n*100
# 53.433

n_revised <- length(which(PostBlockLifespanLength>1))
n_revised
# 53,777,726
n_revised/n*100
# 46.567

PostBlockLifespanLengthTable <- table(PostBlockLifespanLength)


# plot histogram (text and code merged)
quartz(type="pdf", file="figures/postblocklifespan_length_merged.pdf", width=8, height=6) # prevents unicode issues in pdf
#pdf("figures/postblocklifespan_length.pdf", width=8, height=6)
par(
  bg="white",
  #mar = c(3, 3, 3, 1)+0.1, # subplot margins (bottom, left, top, right)
  #  omi = c(0.0, 0.0, 0.0, 0.0),  # outer margins in inches (bottom, left, top, right)
  mfrow = c(1, 1),
  #pin = (width, height)
  #mfcol # draw in columns
  # increase font size
  cex=1.3,
  cex.main=1.3,
  cex.sub=1,
  cex.lab=1,
  cex.axis=1
)

# text and code merged
hist(PostBlockLifespanLength, 
     main="Post block version count (n=115,484,618)", 
     freq=TRUE,
     xlab="",
     ylab="",
     border="white",
     col="white",
     #labels=c(rep("", 10), "Selected"),
     xlim=c(0, 10),
     ylim=c(0, 60000000),
     breaks=0:10,
     xaxt="n",
     yaxt="n"
)
for (y in seq(0, 60000000, by=10000000)) {
  segments(x0=-0.5, y0=y, x1=10, y1=y, lty=1, lwd=1, col=gray_lighter)
}
hist(PostBlockLifespanLength,
     add=TRUE,
     main="", 
     freq=TRUE,
     xlab="x",
     ylab="y",
     border=gray_dark,
     col=c(gray_lighter, rep(gray_selected, 9)),
     #labels=c(rep("", 10), "Selected"),
     xlim=c(0, 10),
     ylim=c(0, 60000000),
     breaks=0:10,
     xaxt="n",
     yaxt="n"
)
boxplot(PostBlockLifespanLength-0.5,
        add=TRUE,
        outline=FALSE,
        horizontal=TRUE,
        ylim=c(0, 10),
        log="",
        col=gray_dark,
        # https://stackoverflow.com/a/28890111
        lwd=2,
        medlwd=2,
        #staplelty=0,
        whisklty=1,
        #staplelty=0,
        whiskcol="black",
        medcol="black",
        boxcol="black",
        staplecol="black",
        boxwex=6000000,
        axes=FALSE
        #xaxt="n"
        #yaxt="n"
)
# median
abline(v=0.5, lty=1, lwd=2, col=gray_darker)
# labels
text(5.0, 23000000, "Edited post blocks (46.6%)", font=3, col="black", cex=1.0)
# axes
axis(1, at=seq(-0.5, 9.5, by=1), labels=c(seq(0, 9, by=1), "\u2265 10"))
axis(2, at=seq(0, 60000000, by=10000000), labels=c("0", "10m", "20m", "30m", "40m", "50m", "60m"), las=2)

dev.off()


##########
# questions vs. answers
##########

# text
textblock_lifespan_length_q <- textblock_lifespan_length[textblock_lifespan_length$PostTypeId == 1,]
textblock_lifespan_length_a <- textblock_lifespan_length[textblock_lifespan_length$PostTypeId == 2,]

summary(textblock_lifespan_length_q$LifespanLength)
# Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
# 1.000     1.000     2.000     2.986     4.000 15876.000 
sd(textblock_lifespan_length_q$LifespanLength)
# 6.212475

summary(textblock_lifespan_length_a$LifespanLength)
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 1.00     1.00     1.00     2.43     2.00 80655.00 
sd(textblock_lifespan_length_a$LifespanLength)
# 14.84347

wilcox.test(textblock_lifespan_length_a$LifespanLength,
            textblock_lifespan_length_q$LifespanLength,
            alternative="two.sided",
            paired=F, correct=T)
# W = 5.4771e+14, p-value < 2.2e-16
# alternative hypothesis: true location shift is not equal to 0

cohen.d(textblock_lifespan_length_a$LifespanLength, # "treatment"
        textblock_lifespan_length_q$LifespanLength, # "control"
        paired=FALSE)
# d estimate: -0.04778815 (negligible)
# 95 percent confidence interval:
#   inf sup 
# NA  NA 


# code
codeblock_lifespan_length_q <- codeblock_lifespan_length[codeblock_lifespan_length$PostTypeId == 1,]
codeblock_lifespan_length_a <- codeblock_lifespan_length[codeblock_lifespan_length$PostTypeId == 2,]

summary(codeblock_lifespan_length_q$LifespanLength)
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 1.000    1.000    2.000    2.656    3.000 1470.000
sd(codeblock_lifespan_length_q$LifespanLength)
# 3.40373

summary(codeblock_lifespan_length_a$LifespanLength)
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 1.0      1.0      1.0      2.4      2.0 562484.0
sd(codeblock_lifespan_length_a$LifespanLength)
# 166.0985

wilcox.test(codeblock_lifespan_length_a$LifespanLength,
            codeblock_lifespan_length_q$LifespanLength,
            alternative="two.sided",
            paired=F, correct=T)
# W = 2.0959e+14, p-value < 2.2e-16
# alternative hypothesis: true location shift is not equal to 0

cohen.d(codeblock_lifespan_length_a$LifespanLength, # "treatment"
        codeblock_lifespan_length_q$LifespanLength, # "control"
        paired=FALSE)
# d estimate: -0.001840913 (negligible)
# 95 percent confidence interval:
#   inf sup 
# NA  NA 


##########
# java vs. others
##########

# post ids of Java questions
java_questions <- fread("data/java_questions.csv", header=FALSE, sep=",", quote="\"", strip.white=TRUE, showProgress=TRUE, encoding="UTF-8", na.strings=c("", "null"), stringsAsFactors=FALSE)
names(java_questions) <- c("PostId", "PostTypeId")
# post ids of Java answers
java_answers <- fread("data/java_answers.csv", header=FALSE, sep=",", quote="\"", strip.white=TRUE, showProgress=TRUE, encoding="UTF-8", na.strings=c("", "null"), stringsAsFactors=FALSE)
names(java_answers) <- c("PostId", "PostTypeId")
# merge post ids
java_post_ids <- c(java_questions$PostId, java_answers$PostId)

codeblock_lifespan_length_java <- codeblock_lifespan_length[codeblock_lifespan_length$PostId %in% java_post_ids,]
codeblock_lifespan_length_others <- codeblock_lifespan_length[!(codeblock_lifespan_length$PostId %in% java_post_ids),]

textblock_lifespan_length_java <- textblock_lifespan_length[textblock_lifespan_length$PostId %in% java_post_ids,]
textblock_lifespan_length_others <- textblock_lifespan_length[!(textblock_lifespan_length$PostId %in% java_post_ids),]


# text
wilcox.test(textblock_lifespan_length_java$LifespanLength,
            textblock_lifespan_length_others$LifespanLength,
            alternative="two.sided",
            paired=F, correct=T)
# W = 2.2728e+14, p-value < 2.2e-16
# alternative hypothesis: true location shift is not equal to 0

cohen.d(textblock_lifespan_length_java$LifespanLength, # "treatment"
        textblock_lifespan_length_others$LifespanLength, # "control"
        paired=FALSE)
# d estimate: 0.01236462 (negligible)
# 95 percent confidence interval:
#  inf sup 
# NA  NA 


# code

wilcox.test(codeblock_lifespan_length_java$LifespanLength,
            codeblock_lifespan_length_others$LifespanLength,
            alternative="two.sided",
            paired=F, correct=T)
# W = 8.3692e+13, p-value < 2.2e-16
# alternative hypothesis: true location shift is not equal to 0

cohen.d(codeblock_lifespan_length_java$LifespanLength, # "treatment"
        codeblock_lifespan_length_others$LifespanLength, # "control"
        paired=FALSE)
# d estimate: 0.0007201488 (negligible)
# 95 percent confidence interval:
#   inf sup 
# NA  NA 
