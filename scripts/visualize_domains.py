from subprocess import call
import sys, inspect
import csv
import math
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as ptl
from pylab import figure, axes, pie, title, show, pcolor, subplot, savefig, colorbar, yticks, arange, pcolormesh
from numpy.random import rand,randint
from numpy import linspace, empty
from matplotlib.patches import Rectangle
import matplotlib.patches as patches

#Query file, database name, e-value, output file
##TODO figure out how to scale font (need to hold off on plotting until number of sequences with identified protein domains are identified)
##Determine what to
if(len(sys.argv)<3):
	print 'Usage: python visualize_domains.py -q <query_file> -d <db name> -e <evalue> -o <output image file> -- At least Query file and Database name must be specified'
	sys.exit(0)
cnt = 0
query_file=""
db_name = ""
eval = "0.000000000000000000000000000001"
domains = []
with open("viral_cdd_domains.txt", 'r') as myfile:
	for data in myfile:
		domains.append(data.replace('\n',''))
output_name = "Sequence.pdf"
for i in range(0,len(sys.argv)):
	if(sys.argv[i]=="-q"):
		query_file = sys.argv[i+1]
	elif(sys.argv[i]=="-d"):
		db_name = sys.argv[i+1]
	elif(sys.argv[i]=="-e"):
		eval = sys.argv[i+1]
	elif(sys.argv[i]=="-o"):
		output_name = sys.argv[i+1]
if(db_name==""):
	print "No database specified... Exiting"
	sys.exit(0)
if(query_file==""):
	print "No query contigs specified... Exiting"
	sys.exit(0)
if(db_name=="Pfam"):
	protein = 1
else:
	protein = 0
numSequences = 0
constantFont = 18
constantWidth = 0.005
temp = ""
figure(1,figsize = (6,11))
title('Visualization of Query Sequence and Hits')
if(protein==1):
	call(["rpsblast","-query",query_file,"-db",db_name,"-evalue",eval,"-out","temp.txt","-outfmt","6"])
else:
	call(["rpstblastn","-query",query_file,"-db",db_name,"-evalue",eval,"-out","temp.txt","-outfmt","6"])
thisCount = 0
currStr = ""
notFirst = 0
yHigh = 0.8
yLow = 0.2
yLowLow = 0.05
yLowHigh = 0.4
yHighHigh = 0.95
yHighLow = 0.6

output_file = 'temp.txt'

count = 0
q_start = []
q_end = []
s_start = []
s_end = []
evalue = []
name = []
type = []
contig = []
orientation = []
	##query start, query end
with open(output_file,'rb') as tsvin:
	tsvin = csv.reader(tsvin,delimiter='\t')
	for row in tsvin:
		count = count + 1
		if(int(row[6]) > int(row[7])):
			orientation.append(1)
			q_start.append(int(row[7]))
			q_end.append(int(row[6]))
		else:
			orientation.append(0)
			q_start.append(int(row[6]))
			q_end.append(int(row[7]))
		s_start.append(int(row[8]))
		s_end.append(int(row[9]))
		evalue.append(float(row[10]))
		name.append(row[1].split(":")[1])
		contig.append(row[0])
		if row[1].split(":")[1] in domains:
			type.append(1)
		else:
			type.append(0)
if(count==0):
	print 'No domains found'
	sys.exit(0)
lengths = {}
with open(query_file, 'r') as myfile:
	for data in myfile:
		#print data
		if(data[0]==">"):
			nam = data.split(" ")[0].replace('>','')
		else:
			lengths.update({nam:len(data)})
			
numSequences = len(set(contig))
fontsize = constantFont*1/(math.log(numSequences,2))
namCount = 1
if count>0:
	for n in set(contig):
		ax1 = subplot(numSequences,2,2*namCount)
		ax2 = subplot(numSequences,2,2*namCount-1)
		for i in range(0,count):
			if(contig[i]==n):
				line = linspace(0,lengths[contig[i]],1000)
				y = linspace(yHigh + 0.05,yHigh +0.05,1000)
				y2 = linspace(yLow+0.05,yLow+0.05,1000)
				if type[i]==0: ##Non-viral
					if(orientation[i]==1): 
						ax2.add_patch(patches.Rectangle((q_start[i],yLow),q_end[i]-q_start[i],0.1,fill=False))
						ax2.text(q_start[i],yLowHigh,name[i],fontsize=fontsize)
					else:
						ax2.add_patch(patches.Rectangle((q_start[i],yHigh),q_end[i]-q_start[i],0.1,fill=False))
						ax2.text(q_start[i],yHighHigh,name[i],fontsize=fontsize)
				else:
					if(orientation[i]==1): 
						ax2.add_patch(patches.Rectangle((q_start[i],yLow),q_end[i]-q_start[i],0.1))
						ax2.text(q_start[i],yLowLow,name[i],fontsize=fontsize)
					else:
						ax2.add_patch(patches.Rectangle((q_start[i],yHigh),q_end[i]-q_start[i],0.1))
						ax2.text(q_start[i],yHighLow,name[i],fontsize=fontsize)
								#temp2 = ptl.plot(line,y,color = 'red',linestyle='solid')
		temp2 = ptl.plot(line,y,color='purple',linewidth=constantWidth*numSequences)
		temp2 = ptl.plot(line,y2,color='purple',linewidth=constantWidth*numSequences)
		ax2.set_xlim([0, lengths[n]])
		ax2.set_ylim([0, 1])
		ax2.axis('off')
		#ax1.text(0.5,0.5,str(thisCount+1))
		ax1.text(0.5,0.5,n)
		ax1.set_xlim([0,1])
		ax1.set_ylim([0,1])
		ax1.axis('off')
		namCount = namCount + 1

show()
savefig(output_name)
print 'Saved Figure'
