from subprocess import call
import sys
import csv
import matplotlib as mpl
mpl.use('Agg')
from pylab import figure, axes, pie, title, show, pcolor, figsize
from numpy.random import rand

Z = rand(6, 10)

figure(1,figsize(6,6))
subplot(2, 1, 1)
c = pcolor(Z)
title('default: no edges')

subplot(2, 1, 2)
c = pcolor(Z, edgecolors='k', linewidths=4)
title('thick edges')

show()
savefig('foo.png')
##Fill in blank with getting variables from the user
#call(["rpsblast","-query",filename,"-db",databaseName,"-evalue",evalue,"-out","temp.txt","-outfmt","6"])

##Visualize output of rpsblast query, need full length of query, then for each target, label its place 
## on the "timeline" of the query 

##First need the length of the input query
query_file = 'rpod.faa'
output_file = 'python.txt'

text1=open(query_file,'r+').read()
queryLength = len(text1)


with open(output_file,'rb') as tsvin:
	tsvin = csv.reader(tsvin,delimiter='\t')
	for row in tsvin:
		q_start = row[6]
		q_end = row[7]
		s_start = row[8]
		s_end = row[9]
		evalue = row[10]
		#type = getKingdom(row[1])
