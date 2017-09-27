import pickle
from Bio import SeqIO
from ete3 import Tree, AttrFace, SeqMotifFace, TreeStyle, add_face_to_node, NodeStyle, TextFace


orf_file = 'amazon.out.predict'
domain_file = 'amazon_contigs.rpstblastn'
map_file = 'cdd_to_domain_id.dict'
viral_file = 'viral_cdd_domains.txt'
contig_file = 'amazon_contigs.fa'
name = 'amazon_contigs'
cutoff = 1e-20

### Make output gff file

# store everything in dictionary, key - contig, 
# value - list of lists of len 9 (gff columns)
gff_output = {}

# collect all ORFs from Glimmer output
with open(orf_file, 'r') as f:
	contig_name = 'unknown'
	for line in f.readlines():
		if line.startswith('>'):
			contig_name = line.split()[0][1:]
		elif line.startswith('orf'):
			line = line.split()
			start = min(int(line[1]), int(line[2]))
			end = max(int(line[1]), int(line[2]))
			gff_entry = [contig_name, 'Glimmer', 'ORF', start, end+1, line[4], line[3][0], line[3][-1], 'ID=%s;Parent=%s'%(line[0],contig_name)]
			gff_output.setdefault(contig_name,[]).append(gff_entry)


# load CDD id to domain id dictionary 
with open(map_file, 'rb') as f:
	cdd_to_domain_id = pickle.load(f)

# load list of viral domains
viral_domains = []
with open(viral_file, 'r') as f:
	for line in f.readlines():
		try:
			viral_domains.append(cdd_to_domain_id[line.strip()])
		except:
			pass

# collect all domain annotations from rpstblastn output
with open(domain_file, 'r') as f:
	for line in f.readlines():
		if not line.startswith('#'):
			l = line.split()
			if float(l[5]) < cutoff:
				contig_name = l[0]
				this_domain = l[2].split('|')[2]
				this_domain = cdd_to_domain_id[this_domain]
				if this_domain in viral_domains:
					is_viral = 'True'
				else:
					is_viral = 'False'
				start = min(int(l[21]), int(l[22]))
				end = max(int(l[21]), int(l[22]))
				gff_entry = [contig_name, 'rpstblastn', 'CDD_domain_prediction', start, end+1, float(l[5]), l[16][0], l[16][-1], 'Name=%s;Parent=%s;viral_domain=%s'%(this_domain,contig_name,is_viral)]
				gff_output.setdefault(contig_name,[]).append(gff_entry)

# write gff file ordering by start position for each contig
gff_file = '#ViruSpy output\n'

for k,v in gff_output.items():
	features = v
	features.sort(key=lambda x: x[3])
	for feature in features:
		gff_file += '%s\n'%('\t'.join([str(x) for x in feature]))

with open('amazon_contigs.gff', 'w') as f:
	f.write(gff_file)

### Make plot

# find out length of each contig
contig_len = {}
record_dict = SeqIO.index(contig_file, 'fasta')
for k,v in record_dict.items():
	contig_len[k] = len(v.seq)


# create 'tree' of contigs
contig_list = list(gff_output.keys())
contig_tree = '(%s);'%(','.join(contig_list))
contig_tree = Tree(contig_tree)

# select colours
colours = {'ORF':'grey','viral':'darkgreen','nonviral':'lightgreen'}

# add faces to 'tree' leaves
for leaf in contig_tree.iter_leaves():
	motifs = []
	for entry in gff_output[leaf.name]:
		if entry[2] == 'ORF':
			this_colour = colours['ORF']
		elif 'viral_domain=True' in entry[8]:
			this_colour = colours['viral']
		else:
			this_colour = colours['nonviral']
		# seq.start, seq.end, shape, width, height, fgcolor, bgcolor
		motifs.append([entry[3], entry[4], '()', None, 10, this_colour, this_colour, ''])
	(contig_tree & leaf.name).add_face(SeqMotifFace(seq='x'*contig_len[leaf.name], motifs=motifs, seq_format='-', gap_format='blank'), 0, 'aligned')

# remove node marks
nstyle = NodeStyle()
nstyle["size"] = 0
for n in contig_tree.traverse():
	n.set_style(nstyle)

# choose tree style
ts = TreeStyle()
ts.show_scale = False
ts.branch_vertical_margin = 12

# render the tree
contig_tree.render('%s.pdf' %(name), tree_style=ts)
