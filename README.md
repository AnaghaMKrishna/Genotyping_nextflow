# nextflow_p2
Nextflow workflow for genotyping


The Nextflow script `genotyping.nf` takes two input FASTQ files corresponding to the PE reads: <br>
* --r1 for forward read file <br>
* --r2 for reverse read file <br>
 
 
Sample files to need to be downloaded from [here](https://gatech.box.com/s/izfb2cmhir3rhqz4hktq7y9buafwza4m) to the current working directory to test the Nextflow script. <br>

#### Example Usage:

`nextflow run genotyping.nf --r1 SRR3214715/SRR3214715_1.fastq --r2 SRR3214715/SRR3214715_2.fastq`


### Details:
The script has 2 parameters r1 and r2 which are taken as input from command-line. It has four processes: <br>
* **trimFiles** - trims the input files based on default parameters using `fastp` and produces 2 trimmed output files. <br>
* **Assembly** - takes the output files from trimFiles as input, assembles them using `skesa` and writes the result into output assembly file. <br>
* **QA** - uses `quast` to perform QA on the assembled file
* **MLST** - performs MLST using `mlst` on assembled file by scanning contig files against PubMLST typing schemes.


<br> Finally, there are two channels created, one for each input file. They are passed to trimFiles process whose output is piped to Assembly process for assembling the reads and then it runs QA and MLST parallely. <br>
