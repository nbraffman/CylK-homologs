# CylK-homologs
constructs and analyzes individual muscle alignments to characterize candidate CylK homologs, because a blast search is too general

you must have muscle installed: https://drive5.com/muscle5/

your input files (input_all_homologs.fasta) can include as many sequences as you'd like to analyze against a reference sequence (licheniforme.fasta)

script_Nterm.sh is a bash script that will parse through your input protein sequence(s) and construct individual muscle alignments against a reference protein sequence to look for the presence or absence of a defined number of N-terminal residues (135) before a set point in the protein sequence (Lys240). This was designed with the CylK enzyme family in mind because it has a relatively rare N-teminal domain and a common C-terminal domain (beta propeller), such that blast results would return a mixture of true homologs and some only containing the C-terminal domain. The output will be a fasta file (out_homologs.fasta) of protein sequences with N-terminal domains, and are thus more likely to be CylK homologs.

the output of script_Nterm.sh (out_homologs.fasta) was deduplicated with Geneious (out_homologs_unique.fasta) and used as the input file below:

script_R105.sh and script_Y473.sh similarly parse through input protein sequences (in this case, out_homologs_unique.fasta) and construct individual muscle alignments against a reference protein sequence (licheniforme.fasta), but they look for the presence or absence of key catalytic residues, R105 or Y473, respectively. The output will be a fasta file (out_homologs_unique_with_R105.fasta, or out_homologs_unique_with_Y473.fasta) of protein sequences with the key catalytic residue.
