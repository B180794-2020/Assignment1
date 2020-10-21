#!/bin/bash

#Assinging variables for easy pathing to list of sequence files  & looping rows containing each pair 
fqDir="/localdisk/data/BPSM/Assignment1/fastq"
fqTable="/localdisk/data/BPSM/Assignment1/fastq/fqfiles"

#Constructing indexed genome of Tryposoma bruncei bruncei for bowtie2 alignment and storing it in working directory
gunzip -c /localdisk/data/BPSM/Assignment1/Tbb_genome/Tb927_genome.fasta.gz > ~/Assignment1/TbbGenome.fasta
bowtie2-build --threads 2 TbbGenome.fasta T_brucei

#Main loop to conduct quality check alignment and output on each sample one at a time
while IFS= read -r  line; do

#identifying filenames from fqTable for each pair in the pair-sequence alignment & running quality check using fastqc
	file_1=$(echo $line | cut -d" " -f3 | cut -d "." -f1)
	file_2=$(echo $line | cut -d" " -f4 | cut -d "." -f1)
	fastqc --extract  -t 2  $fqDir/$file_1.fq.gz $fqDir/$file_2.fq.gz -o ~/Assignment1	

#Pass Check based on fastqc summary report: Per Base Sequence quality, per sequence quality score, per N content and Adapter content	
	qualityChecks[0]=$( head -2 ${file_1}_fastqc/summary.txt | tail -1 | cut -f1) 
	qualityChecks[1]=$( head -4 ${file_1}_fastqc/summary.txt | tail -1 | cut -f1) 
	qualityChecks[2]=$( head -7 ${file_1}_fastqc/summary.txt | tail -1 | cut -f1)
	qualityChecks[3]=$( head -11 ${file_1}_fastqc/summary.txt | tail -1  | cut -f1)
 	qualityChecks[4]=$( head -2 ${file_2}_fastqc/summary.txt | tail -1 | cut -f1)
        qualityChecks[5]=$( head -4 ${file_2}_fastqc/summary.txt | tail -1 | cut -f1)
        qualityChecks[6]=$( head -7 ${file_2}_fastqc/summary.txt | tail -1 | cut -f1)
        qualityChecks[7]=$( head -11 ${file_2}_fastqc/summary.txt | tail -1  | cut -f1)

#Check that all tests are passed	
	quality_fail=false
	for i in "${qualityChecks[@]}"; do
    		if [[ "PASS" != "$i" ]]
			 then quality_fail=true
        		      break
    		fi	
	done
#If the quality of BOTH files are good --> continue to bowtie alignment 
	if [[ "$quality_fail" == false ]]
		then
		echo "-----------------------"
		echo "Quality Check Passed!"
		echo "-----------------------"

#Bowtie alignment using previously indexed genome, converting bowtie sam output to bam using samtools, sorting and indexing output
		bowtie2 --threads 4 -x T_brucei -1 $fqDir/$file_1.fq.gz -2 $fqDir/$file_2.fq.gz | samtools view -bS - > $file_1.bam
        	samtools sort $file_1.bam -o $file_1.sorted.bam
        	samtools index $file_1.sorted.bam


	else
		echo "Quality check fail in on of the pairs!"
		cat ${file_1}_fastqc/summary.txt
		cat ${file_2}_fastqc/summary.txt
	fi
	echo "-----------------------------------------------------------------------"

done < "$fqTable"

#4. Generate counts data 
#5. Output table
