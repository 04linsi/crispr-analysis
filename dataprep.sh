#!/usr/bin/bash
$BIOPROJECT='https://www.ncbi.nlm.nih.gov/bioproject/PRJNA381704/'
$RUNS=(
  'SRR5417066'  # DeepSeq_ZSCAN_SLiCES
  'SRR5417067'  # DeepSeq_ZSCAN_Ctr
  'SRR5417068'  # DeepSeq_ZSCAN_NT
  'SRR5417069'  # DeepSeq_EMX_SLiCES
  'SRR5417070'  # DeepSeq_EMX_Ctr
  'SRR5417071'  # DeepSeq_EMX_NT
  'SRR5417072'  # DeepSeq_VEGFA_SLiCES
  'SRR5417073'  # DeepSeq_VEGFA_Ctr
  'SRR5417074'  # DeepSeq_VEGFA_NT
)
# Notebook script for preparing NGS homework 
sudo apt-get update
sudo apt-get upgrade

#Install NGS Toolkit
cd src
sudo apt-get install sra-toolkit sra-toolkit-libs-dev
which ascp
which bcftools
which cargo
which fastq-dump
which prefetch
which python
which samtools
which sratoolkit
which tabix
which vdb-config
# Check versions >1.4
openssl version
bcftools --version
samtools --version


# Install Aspera Connect for Downloading SRA data
mkdir -p ~/src
cd ~/src
#requires updated openssl
wget wget https://www.openssl.org/source/openssl-1.0.2g.tar.gz
tar -xzvf openssl-1.0.2g.tar.gz
cd openssl-1.0.2g/
sudo ./config
make depend
sudo make install
sudo ln -sf /usr/local/ssl/bin/openssl `which openssl`
cd ~/src
wget http://download.asperasoft.com/download/sw/connect/3.7.1/aspera-connect-3.7.1.139846-linux-64.tar.gz
tar -xvzf aspera-connect-3.7.1.139846-linux-64.tar.gz 
source ./aspera-connect-3.7.1.139846-linux-64.sh 
./aspera-connect-3.7.1.139846-linux-64.sh 

# Install the current HTSlib and Samtools
cd ~/src
git clone https://github.com/samtools/htslib.git
git clone https://github.com/samtools/samtools.git

cd htslib
git fetch
git reset --hard HEAD
git checkout 1.7
autoheader
autoconf
sudo apt-get install liblzma-dev
./configure
make
sudo make install

cd ../samtools/
git fetch
git reset --hard HEAD
git checkout 1.7
autoconf -Wno-syntax
source ./configure
make
sudo make install

# Alternatively import indices locally
mkdir -p /opt/biodata/human/GRCh38.81/formatted/bowtie2
gsutil cp gs://dtg_genomes/reference/human/GRCh38.81/formatted/bowtie2/GRCh38.81.1.bt2 /opt/biodata/human/GRCh38.81/formatted/bowtie2/GRCh38.81.1.bt2
gsutil cp gs://dtg_genomes/reference/human/GRCh38.81/formatted/bowtie2/GRCh38.81.2.bt2 /opt/biodata/human/GRCh38.81/formatted/bowtie2/GRCh38.81.2.bt2
gsutil cp gs://dtg_genomes/reference/human/GRCh38.81/formatted/bowtie2/GRCh38.81.3.bt2 /opt/biodata/human/GRCh38.81/formatted/bowtie2/GRCh38.81.3.bt2
gsutil cp gs://dtg_genomes/reference/human/GRCh38.81/formatted/bowtie2/GRCh38.81.4.bt2 /opt/biodata/human/GRCh38.81/formatted/bowtie2/GRCh38.81.4.bt2
gsutil cp gs://dtg_genomes/reference/human/GRCh38.81/formatted/bowtie2/GRCh38.81.rev.2.bt2 /opt/biodata/human/GRCh38.81/formatted/bowtie2/GRCh38.81.rev.2.bt2
gsutil cp gs://dtg_genomes/reference/human/GRCh38.81/formatted/bowtie2/GRCh38.81.rev.1.bt2 /opt/biodata/human/GRCh38.81/formatted/bowtie2/GRCh38.81.rev.1.bt2

# Begin actual pipeline
# gsutil mb gs://crispr-analysis-hw
mkdir -p ~/exps/ngs-hw
cd ~/exps/ngs-hw/
# Fetch data from SeqReadArchive
~/.aspera/connect/bin/ascp -i ~/.aspera/connect/etc/asperaweb_id_dsa.openssh -k 1 -T -l1200m anonftp@ftp.ncbi.nlm.nih.gov:/sra/sra-instant/reads/ByRun/sra/SRR/SRR541/SRR5417066/SRR5417066.sra ~/exps/ngs-hw/SRR5417066_DeepSeq_ZSCAN_SLiCES.sra
~/.aspera/connect/bin/ascp -i ~/.aspera/connect/etc/asperaweb_id_dsa.openssh -k 1 -T -l1200m anonftp@ftp.ncbi.nlm.nih.gov:/sra/sra-instant/reads/ByRun/sra/SRR/SRR541/SRR5417067/SRR5417067.sra ~/exps/ngs-hw/SRR5417067_DeepSeq_ZSCAN_Ctr.sra
~/.aspera/connect/bin/ascp -i ~/.aspera/connect/etc/asperaweb_id_dsa.openssh -k 1 -T -l1200m anonftp@ftp.ncbi.nlm.nih.gov:/sra/sra-instant/reads/ByRun/sra/SRR/SRR541/SRR5417068/SRR5417068.sra ~/exps/ngs-hw/SRR5417068_DeepSeq_ZSCAN_NT.sra

~/src/sratoolkit.2.8.2-ubuntu64/bin/fastq-dump -O . --gzip --split-files SRR5417066_DeepSeq_ZSCAN_SLiCES.sra &
~/src/sratoolkit.2.8.2-ubuntu64/bin/fastq-dump -O . --gzip --split-files SRR5417068_DeepSeq_ZSCAN_NT.sra &
~/src/sratoolkit.2.8.2-ubuntu64/bin/fastq-dump -O . --gzip --split-files SRR5417067_DeepSeq_ZSCAN_Ctr.sra &

gunzip *.gz

# Core alignment
bowtie2 --phred33 --very-sensitive --mm -x /opt/biodata/human/GRCh38.81/formatted/bowtie2/GRCh38.81 -U /home/rileyd/exps/ngs-hw/SRR5417066_DeepSeq_ZSCAN_SLiCES_1.fastq 2> /home/rileyd/exps/ngs-hw/SRR5417066_DeepSeq_ZSCAN_SLiCES_1.bam_alignlog.txt | samtools view -bS - > /home/rileyd/exps/ngs-hw/SRR5417066_DeepSeq_ZSCAN_SLiCES.fastq.bam &
bowtie2 --phred33 --very-sensitive --mm -x /opt/biodata/human/GRCh38.81/formatted/bowtie2/GRCh38.81 -U /home/rileyd/exps/ngs-hw/SRR5417067_DeepSeq_ZSCAN_Ctr_1.fastq 2> /home/rileyd/exps/ngs-hw/SRR5417067_DeepSeq_ZSCAN_Ctr_1.bam_alignlog.txt | samtools view -bS - > /home/rileyd/exps/ngs-hw/SRR5417067_DeepSeq_ZSCAN_Ctr_1.fastq.bam &
bowtie2 --phred33 --very-sensitive --mm -p 1 -x /opt/biodata/human/GRCh38.81/formatted/bowtie2/GRCh38.81 -U /home/rileyd/exps/ngs-hw/SRR5417068_DeepSeq_ZSCAN_NT_1.fastq 2> /home/rileyd/exps/ngs-hw/SRR5417068_DeepSeq_ZSCAN_NT_1.bam_alignlog.txt | samtools view -bS - > /home/rileyd/exps/ngs-hw/SRR5417068_DeepSeq_ZSCAN_NT_1.fastq.bam &

# Annotate, Sort, and Index the BAM files
samtools sort -l 0 -o SRR5417066_DeepSeq_ZSCAN_SLiCES.bam -O bam SRR5417066_DeepSeq_ZSCAN_SLiCES.fastq.bam
samtools sort -l 0 -o SRR5417067_DeepSeq_ZSCAN_Ctr_1.bam -O bam SRR5417067_DeepSeq_ZSCAN_Ctr_1.fastq.bam
samtools sort -l 0 -o SRR5417068_DeepSeq_ZSCAN_NT.bam -O bam SRR5417068_DeepSeq_ZSCAN_NT_1.fastq.bam

# Upload to GCS and Clean up
gsutil -o GSUtil:parallel_composite_upload_threshold=150M cp -Z SRR5120985.bam gs://rileyd-sxsw2017/SRR5120985.bam

samtools idxstats SRR5120985.bam | gsutil cp - gs://crispr-analysis-hw/alignment-stats.txt
samtools flagstat SRR5120985.bam |gsutil cp - gs://crispr-analysis-hw/alignment-stats.txt
samtools stats SRR5120985.bam | gsutil cp - gs://crispr-analysis-hw/alignment-stats.txt
samtools view -C -h -T /opt/biodata/human/GRCh38.81/formatted/fasta/GRCh38.81.fa SRR5120985.bam | gsutil cp - gs://crispr-analysis-hw/SRR5120985.cram &
