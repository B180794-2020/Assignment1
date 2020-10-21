#!/bin/bash
#TODO:
#1. Quality check using fastqc

#Pathing to list of sequence files  & looping rows containing each pair 
fqDir="/localdisk/data/BPSM/Assignment1/fastq"
fqTable="/localdisk/data/BPSM/Assignment1/fastq/fqfiles"
while IFS= read -r  line
	do
	seq_1=$(echo $line | cut -d" " -f3)
	seq_2=$(echo $line | cut -d" " -f4)
	fastqc -t 2  $fqDir/$seq_1 $fqDir/$seq_2 -o ~/Assignment1
	done < "$fqTable"
#2. Asses quality
#3. Alignment Using bowtie2
#4. Generate counts data 
#5. Output table
