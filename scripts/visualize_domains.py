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

#Query file, database name, e-value, output file
if(len(sys.argv)<3):
	print 'Usage: python visualize_domains.py -q <query_file> -d <db name> -e <evalue> -o <output image file> -- At least Query file and Database name must be specified'
	sys.exit(0)
cnt = 0
query_file=""
db_name = ""
eval = "0.0001"
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
constantFont = 0.3
constantWidth = 0.005
with open(query_file, 'r') as myfile:
	for data in myfile:
		if(data[0]==">"):
			numSequences = numSequences + 1
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
			currStr2 = currStr.replace(' ','')
			currStr2 = currStr2.replace('\n','')
			currStr2 = currStr2.replace('>','')
			currStr2 = currStr2.replace('\r','')
			
			temp = currStr
			text_file = open("tmp.txt", "w")
			text_file.write("%s" % temp)
			text_file.close()
			output_file = 'temp.txt'
			if(protein==1):
				call(["rpsblast","-query","tmp.txt","-db",db_name,"-evalue",eval,"-out","temp.txt","-outfmt","6"])
			else:
				call(["rpstblastn","-query","tmp.txt","-db",db_name,"-evalue",eval,"-out","temp.txt","-outfmt","6"])
			count = 0
			q_start = []
			q_end = []
			s_start = []
			s_end = []
			evalue = []
			name = []
			type = []
			with open(output_file,'rb') as tsvin:
				tsvin = csv.reader(tsvin,delimiter='\t')
				for row in tsvin:
					if row[0]==currStr.split(" ")[0].replace('>',''):
						count = count + 1
						if(int(row[6]) > int(row[7])):
							q_start.append(int(row[7]))
							q_end.append(int(row[6]))
						else:
							q_start.append(int(row[6]))
							q_end.append(int(row[7]))
						s_start.append(int(row[8]))
						s_end.append(int(row[9]))
						evalue.append(float(row[10]))
						name.append(row[1].split(":")[1])
						
						if row[1].split(":")[1] in domains:
							type.append(1)
						else:
							type.append(0)
			if count==0:
				print "No protein domains identified in this database"
			else:
				ax1 = subplot(numSequences,2,2*thisCount)
				ax2 = subplot(numSequences,2,2*thisCount-1)
				for i in range(0,count):
			##Plot a line from query start to query end, colored by Viral and Non-viral
			##Add in the name of the protein domain above the line
			## remove all figure outlines and axes 
			#ax2 = subplot(gs[i+1])
					fontsize = constantFont*numSequences
					line = linspace(0,len(currStr),1000)
					y = linspace(0.55,0.55,1000)
					if type[i]==0: ##Non-viral
						#temp2 = ptl.plot(line,y,color='black',linestyle='dashed')
						ax2.add_patch(patches.Rectangle((q_start[i],0.5),q_end[i]-q_start[i],0.1,fill=False))
						ax2.text(q_start[i],0.75,name[i],fontsize=fontsize)
					else:
						#temp2 = ptl.plot(line,y,color = 'red',linestyle='solid')
						ax2.add_patch(patches.Rectangle((q_start[i],0.5),q_end[i]-q_start[i],0.1))
						print 'viral:' + str(q_start[i]) + str(currStr.split(" ")[0].replace('>',''))
						ax2.text(q_start[i],0.35,name[i],fontsize=fontsize)
					temp2 = ptl.plot(line,y,color='purple',linewidth=constantWidth*numSequences)
							
							
					ax2.set_xlim([0, len(currStr2)])
					ax2.set_ylim([0, 1])
					ax2.axis('off')
					#ax1.text(0.5,0.5,str(thisCount))
					ax1.text(0.5,0.5,currStr.split(" ")[0].replace('>',''))
					ax1.set_xlim([0,1])
					ax1.set_ylim([0,1])
					ax1.axis('off')
			currStr = ""
		elif(data[0]==">"):
			notFirst = 1
		currStr = currStr + data
currStr2 = currStr.replace(' ','')
currStr2 = currStr2.replace('\n','')
currStr2 = currStr2.replace('>','')
currStr2 = currStr2.replace('\r','')
temp = currStr
text_file = open("tmp.txt", "w")
text_file.write("%s" % temp)
text_file.close()
output_file = 'temp.txt'
if(protein==1):
	call(["rpsblast","-query",query_file,"-db",db_name,"-evalue",eval,"-out","temp.txt","-outfmt","6"])
else:
	call(["rpstblastn","-query",query_file,"-db",db_name,"-evalue",eval,"-out","temp.txt","-outfmt","6"])

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
		if row[0]==currStr.split(" ")[0].replace('>',''):
			count = count + 1
			if(int(row[6]) > int(row[7])):
				q_start.append(int(row[7]))
				q_end.append(int(row[6]))
			else:
				q_start.append(int(row[6]))
				q_end.append(int(row[7]))
			s_start.append(int(row[8]))
			s_end.append(int(row[9]))
			evalue.append(float(row[10]))
			name.append(row[1].split(":")[1])
			
			if row[1].split(":")[1] in domains:
				type.append(1)
			else:
				type.append(0)

if count==0:
	print "No protein domains identified in this database"
else:
	print 'Added title'
	ax1 = subplot(numSequences,2,2*thisCount+2)
	ax2 = subplot(numSequences,2,2*thisCount+1)
	for i in range(0,count):
			##Plot a line from query start to query end, colored by Viral and Non-viral
			##Add in the name of the protein domain above the line
			## remove all figure outlines and axes 
			#ax2 = subplot(gs[i+1])
			
		line = linspace(0,len(currStr),1000)
		y = linspace(0.55,0.55,1000)
		if type[i]==0: ##Non-viral
				#temp2 = ptl.plot(line,y,color='black',linestyle='dashed')
			ax2.add_patch(patches.Rectangle((q_start[i],0.5),q_end[i]-q_start[i],0.1,fill=False))
			ax2.text(q_start[i],0.75,name[i],fontsize=fontsize)
		else:
				#temp2 = ptl.plot(line,y,color = 'red',linestyle='solid')
			ax2.add_patch(patches.Rectangle((q_start[i],0.5),q_end[i]-q_start[i],0.1))
			ax2.text(q_start[i],0.35,name[i],fontsize=fontsize)
			print 'viral:' + str(q_start[i]) + str(currStr.split(" ")[0].replace('>',''))
		temp2 = ptl.plot(line,y,color='purple',linewidth=constantWidth*numSequences)
		fontsize = constantFont*numSequences
	ax2.set_xlim([0, len(currStr2)])
	ax2.set_ylim([0, 1])
	ax2.axis('off')
	#ax1.text(0.5,0.5,str(thisCount+1))
	ax1.text(0.5,0.5,currStr.split(" ")[0].replace('>',''))
	ax1.set_xlim([0,1])
	ax1.set_ylim([0,1])
	ax1.axis('off')

show()
savefig(output_name)
print 'Saved Figure'
