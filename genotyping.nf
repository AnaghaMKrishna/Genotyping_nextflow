#!/usr/bin/env nextflow

//read PE file names from commandline
params.r1 = null
params.r2 = null

//process to trim files using fastp
process trimFiles {
    //takes input as files read from commandline
    input:
    file r1
    file r2
    
    //write trimmed reads to output files
    output:
    file 'r1_trimmed.fq.gz' 
    file 'r2_trimmed.fq.gz'

    //invoke fastp for read trimming
    """
    fastp -i $r1 -I $r2 -o r1_trimmed.fq.gz -O r2_trimmed.fq.gz
    """
}

//process to assemble trimmed files
process Assembly {
    //takes the output of trimFiles process as input
    input:
    file 'r1_trimmed.fq.gz' 
    file 'r2_trimmed.fq.gz' 

    //output assembled file
    output:
    file 'skesa_assembly.fna' 

    //invoke skesa for assembly
    """
    skesa --reads r1_trimmed.fq.gz r2_trimmed.fq.gz --contigs_out skesa_assembly.fna
    """
}

//process to perform QA on assembly file
process QA {
    //takes input as assembled file
    input:
    file 'skesa_assembly.fna'
    
    //write QA'd reads to output files
    output:
    file 'QA_report' 

    //perform QA
    script:
    """
    quast skesa_assembly.fna -t 6 -o QA_report
    """
}

process MLST {
    //takes assembled file as input
    input:
    file 'skesa_assembly.fna'
    //file ref
    
    //MLST output file 
    output:
    file 'MLST_Summary.tsv'

    //perform MLST
    script:
    """
    mlst skesa_assembly.fna > MLST_Summary.tsv
    """
}

workflow {
    //input channels
    def file1_ch = Channel.fromPath(params.r1)
    def file2_ch = Channel.fromPath(params.r2)

    //workflow to trim reads, assemble them, run QA and MLST parallely and then view the output files
    trimFiles(file1_ch, file2_ch) | Assembly | QA & MLST | mix | view
}



