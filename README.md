# crispr-analysis
Case study on analysis of CRISPR/Cas9 NGS data


## Objective

In this case study your goal is to analyse Next-Generation Sequencing data to characterize the effectiveness and specificity of a guide RNA.
A key aspect of this challenge is to determine whether genomic variations seen in the sequencing data can be attributed to the CRISPR/Cas9 activity,
sequencing noise, or pre-existing genomic variation.

For each guide, data was gather for three samples:

1. Ctr -A negative control without the guide RNA. This sample shows background mutation in the underlying genome.
2. NT - A positive control where a standard CRISPR experiment was performed.
3. SLiCES - A variant case where a CRISPR experiment suspected to have enhanced specificity was performed.

Guide RNAs targeting three genes were analyzed: ZSCAN22, VEGFA, EMX1

All sequencing run metadata is summarized on [SeqReadArchive](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=SRP103075)

For each sample, targeted deep sequencing was performed on the genomic DNA extracted from treated cells at cut sites identified through a specialized assay.
This assay yields single-ended reads.
Both the original reads (from SeqReadArchive) and a basic Bowtie2 alignment of these reads are provided.
The pre-aligned data is provided as a convenience and you may realign the reads if you wish.

You should analyze the data and prepare a 30 minute presentation covering the following points:

- Your methodology,
- The Extent to which observed Indels or other genomic variations can be attributed to CRISPR,
- The frequency and distribution of CRISPR-attributable Indels in each samples at the target site,
- The frequency and distribution of CRISPR-attributable Indels at other "off-target" sites.

Note, there are 3 different guides (target loci) in the original paper. For now we will only consider one of them.

The original data comes from:
Petris et al. 2017 "Hit and go CAS9 delivered through a lentiviral based self-limiting circuit". Nature Communications, 8 2017.
doi:10.1038/ncomms15334

Files were downloaded from SeqReadArchive Bioproject: PRJNA381704.

BAM files were produced by alignment to GRCH38.81 with Bowtie2 with "very sensitive" single read alignment parameters.
The resulting alignment was then sorted and stored using samtools/htslib.


## Data Files

The data files have been made available on a google cloud storage bucket.
They can be accessed remotely using their tabix indices via samtools or downloaded locally.

 https://storage.googleapis.com/crispr-analysis-hw/SRR5417067_DeepSeq_ZSCAN_Ctr_1.bam
 https://storage.googleapis.com/crispr-analysis-hw/SRR5417066_DeepSeq_ZSCAN_SLiCES.sorted.bam
 https://storage.googleapis.com/crispr-analysis-hw/SRR5417068_DeepSeq_ZSCAN_NT.bam
