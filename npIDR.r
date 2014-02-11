# This is a translation of Alex Dobin's npIDR script (see funIDRnpFile.m) from matlab to R
# Done on Jun 7, 2013 by Dmitri Pervouchine (dp@crg.eu)
#
# Generally, I tried to preserve command line arguments and even the notation. I prefer to safely operate with integers with plyr's 'count' function
# rather than to be affected by unknown conventions in the histogram routine of R. Because of that, the binSize is treated as a scaling factor since
# the offset in the Alex Dobin's npIDR script is always equal to zero. I kept the poolType option (although I don't know when one might want to use 
# max vs. sum) but skipped the reporting step (lines 30-34 of funIDRnpFile.m)
#
# To run this script from commandline you call 
# R --slave --args fIn fOut binSize poolType < npIDR.r
# There are also custom versions which do the job for splice junctions and other types of count data (see in this directory)
#
# NOTE : fIn has to be tab, not space delimited !!!!

library(plyr)

cmd_args = commandArgs();

fIn  = cmd_args[4]
fOut = cmd_args[5] 
binSize  = as.numeric(cmd_args[6])
poolType = as.numeric(cmd_args[7])

data = read.delim(fIn, header=F)	# read two-column data file
data = round(data/binSize,digits=0)	# scale data according to binSize

# compute absolute distribution of data values in replicates 1 and 2
colnames(data) = c('V1','V2')

merge(count(data,'V1'),count(data,'V2'),by=1,all=T) -> absolute
absolute[is.na(absolute)] <- 0
absolute$sum = absolute$freq.x + absolute$freq.y

# compute conditional distribution of data values in replicates 1 and 2 given that the value in the other replicate is exactly zero
merge(count(subset(data,V2==0),'V1'), count(subset(data,V1==0),'V2'), by=1,all=T) -> conditional
conditional[is.na(conditional)] <- 0
conditional$sum = conditional$freq.x + conditional$freq.y

subset(merge(absolute, conditional, by=1, all=T), V1>0) -> matr
matr[is.na(matr)] <- 0
npIDR=matr$sum.y/matr$sum.x
names(npIDR) = matr$V1

if(poolType==1) {
    sPool = apply(data, 1, sum)
} else {
    sPool = apply(data, 1, max)
}

output = npIDR[as.character(sPool)]
output[is.na(output)]<-0

write.table(as.data.frame(output), file=fOut, col.names=F, row.names=F, quote=F, sep="\t")
