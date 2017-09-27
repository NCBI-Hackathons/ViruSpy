import pickle

input_file = 'cdd_map.txt'
cdd_to_domain_id = {}
with open(input_file, 'r') as f:
	for line in f.readlines():
		line = line.split()
		domain_id = line[0].split('.')[0]
		if domain_id.startswith('pfam'):
			domain_id = 'PF%s'%(domain_id[4:])
		cdd_to_domain_id[line[3]] = domain_id

with open('cdd_to_domain_id.dict', 'wb') as f:
	pickle.dump(cdd_to_domain_id, f)
