from subprocess import call
import sys, inspect
import csv
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as ptl
from pylab import figure, axes, pie, title, show, pcolor, subplot, savefig, colorbar, yticks, arange, pcolormesh
from numpy.random import rand,randint
from numpy import linspace, empty
from matplotlib.patches import Rectangle
import matplotlib.patches as patches


#c = pcolor(Z)
#title('default: no edges')

#subplot(2, 1, 2)
#c = pcolor(Z, edgecolors='k', linewidths=4)
#title('thick edges')

#show()
#savefig('foo.png')
##Fill in blank with getting variables from the user

##Visualize output of rpsblast query, need full length of query, then for each target, label its place 
## on the "timeline" of the query 

##First need the length of the input query
#query_file = 'GCF_000006765.1_ASM676v1_genomic.fna'
#query_file = 'example.faa'
numSequences = 0
constantFont = 0.08
constantWidth = 0.005
query_file = 'rpod.faa'
with open(query_file, 'r') as myfile:
	for data in myfile:
		if(data[0]==">"):
			numSequences = numSequences + 1
arrOne = [None]*numSequences
temp = ""
figure(1,figsize = (6,11))
title('Visualization of Query Sequence and Hits')
thisCount = 0
currStr = ""
notFirst = 0
with open(query_file, 'r') as myfile:
	for data in myfile:
		if(data[0]==">" and notFirst!=0):
			thisCount = thisCount+1
			currStr = currStr.replace(' ','')
			currStr = currStr.replace('\n','')
			currStr = currStr.replace('>','')
			currStr = currStr.replace('\r','')
			print currStr
			arrOne[thisCount-1] = currStr
			currStr = ""
		elif(data[0]==">"):
			notFirst = 1
		currStr = currStr + data
currStr = currStr.replace(' ','')
currStr = currStr.replace('\n','')
currStr = currStr.replace('>','')
currStr = currStr.replace('\r','')
arrOne[thisCount] = currStr
arrOne[thisCount].replace(' ','')
arrOne[thisCount].replace('\n','')
arrOne[thisCount].replace('>','')
for j in range(1,numSequences+1):
	temp = arrOne[j-1]
	text_file = open("tmp.txt", "w")
	text_file.write("%s" % temp)
	text_file.close()
	output_file = 'temp.txt'
	call(["rpsblast","-query","tmp.txt","-db","Pfam","-evalue","0.0001","-out","temp.txt","-outfmt","6"])






	maxCount = 10
	count = 0
	q_start = []
	q_end = []
	s_start = []
	s_end = []
	evalue = []
	name = []
	type = []
	##query start, query end
	with open(output_file,'rb') as tsvin:
		tsvin = csv.reader(tsvin,delimiter='\t')
		for row in tsvin:
			count = count + 1
			q_start.append(int(row[6]))
			q_end.append(int(row[7]))
			s_start.append(int(row[8]))
			s_end.append(int(row[9]))
			evalue.append(float(row[10]))
			name.append(row[1].split(":")[1])
			
			#type = getKingdom(row[1])
			type.append(randint(0,2))
			print type

	if count==0:
		print "No protein domains identified in this database"
	else:
		print 'Added title'
		ax1 = subplot(numSequences,2,2*j)
		ax2 = subplot(numSequences,2,2*j-1)
		for i in range(0,count):
			##Plot a line from query start to query end, colored by Viral and Non-viral
			##Add in the name of the protein domain above the line
			## remove all figure outlines and axes 
			#ax2 = subplot(gs[i+1])
			
			line = linspace(0,len(arrOne[j-1]),1000)
			y = linspace(0.55,0.55,1000)
			
			if type[i]==0: ##Non-viral
				#temp2 = ptl.plot(line,y,color='black',linestyle='dashed')
				ax2.add_patch(patches.Rectangle((q_start[i],0.5),q_end[i]-q_start[i],0.1,fill=False))
			else:
				#temp2 = ptl.plot(line,y,color = 'red',linestyle='solid')
				ax2.add_patch(patches.Rectangle((q_start[i],0.5),q_end[i]-q_start[i],0.1))
			temp2 = ptl.plot(line,y,color='purple',linewidth=constantWidth*numSequences)
			fontsize = constantFont*numSequences
			ax2.text(q_start[i],0.75,name[i],fontsize=fontsize)
		ax2.set_xlim([0, len(arrOne[j-1])])
		ax2.set_ylim([0, 1])
		ax2.axis('off')
		ax1.text(0.5,0.5,str(j))
		ax1.set_xlim([0,1])
		ax1.set_ylim([0,1])
		ax1.axis('off')
			
			##TODO Need to figure out how to change height ratio of subplots without using gridpsec
			##Need to figure out how to write text above the line
			## maybe sort based off of query_start instead of based off of evalue

show()
savefig('Sequence.pdf')
print 'Saved Figure'

		# height_ratios=[4]
		# for i in range(0,count):
			# height_ratios.append(1)
		# #gs = gridspec.GridSpec(count,1,height_ratios=height_ratios)

		# print count
		# #ax1 = subplot(gs[0])
		# ax1 = subplot(numSequences,1,j)
		# #nrows, ncols, plot number
		# c = pcolormesh(arr)
		# print 'Plotted sequence'
		# ax1.set_xlim([0, len(temp)])
		# ax1.set_ylim([0, 1])
		# for tick in ax1.xaxis.get_major_ticks():
			# tick.label.set_fontsize(10) 
		# print 'Set axis limit'
			# arr = empty([1,len(temp)])
	# for i in range(0,len(temp)):
		# if data[i]=="A":
			# arr[0,i] = 0.2
		# elif data[i]=="T":
			# arr[0,i] = 0.4
		# elif data[i]=="C":
			# arr[0,i] = 0.6
		# else:
			# arr[0,i] = 0.8


