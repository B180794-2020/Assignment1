#!/bin/bash
#TODO:
#1. Quality check using fastqc
#Constructing index genome
#Pathing to list of sequence files  & looping rows containing each pair 
fqDir="/localdisk/data/BPSM/Assignment1/fastq"
fqTable="/localdisk/data/BPSM/Assignment1/fastq/fqfiles"

#building index
gunzip -c /localdisk/data/BPSM/Assignment1/Tbb_genome/Tb927_genome.fasta.gz > ~/Assignment1/TbbGenome.fasta
bowtie2-build --threads 2 TbbGenome.fasta T_brucei

while IFS= read -r  line; do
#extracting file names of each pair in pair-sequence alignment & running quality check using fastqc
	file_1=$(echo $line | cut -d" " -f3 | cut -d "." -f1)
	file_2=$(echo $line | cut -d" " -f4 | cut -d "." -f1)
	fastqc --extract  -t 2  $fqDir/$file_1.fq.gz $fqDir/$file_2.fq.gz -o ~/Assignment1
	 
#2. Assessing quality of the two files	
	echo "-----------------------------------------------------------------------"
#Pass Check: Per Base Sequence quality, per sequence quality score, per Ncontent and Adapter content	
	qualityChecks[0]=$( head -2 ${file_1}_fastqc/summary.txt | tail -1 | cut -f1) 
	qualityChecks[1]=$( head -4 ${file_1}_fastqc/summary.txt | tail -1 | cut -f1) 
	qualityChecks[2]=$( head -7 ${file_1}_fastqc/summary.txt | tail -1 | cut -f1)
	qualityChecks[3]=$( head -11 ${file_1}_fastqc/summary.txt | tail -1  | cut -f1)
 	qualityChecks[4]=$( head -2 ${file_2}_fastqc/summary.txt | tail -1 | cut -f1)
        qualityChecks[5]=$( head -4 ${file_2}_fastqc/summary.txt | tail -1 | cut -f1)
        qualityChecks[6]=$( head -7 ${file_2}_fastqc/summary.txt | tail -1 | cut -f1)
        qualityChecks[7]=$( head -11 ${file_2}_fastqc/summary.txt | tail -1  | cut -f1)
	
	quality_fail=false
	for i in "${qualityChecks[@]}"; do
    		if [[ "PASS" != "$i" ]]
			 then quality_fail=true
        		      break
    		fi	
	done
	
	if [[ "$quality_fail" == false ]]
		 then  echo "Quality Check Passed!"
	else
		echo "Quality check fail in on of the pairs!"
		cat ${file_1}_fastqc/summary.txt
		cat ${file_2}_fastqc/summary.txt
	f
	echo "-----------------------------------------------------------------------"
#3. Bowtie2 alignment
	 bowtie2 --threads 2 -x T_brucei -1 $fqDir/$file_1.fq.gz -2 $fqDir/$file_2.fq.gz -S $file_1.sam

done < "$fqTable"

#4. Generate counts data 
#5. Output table
