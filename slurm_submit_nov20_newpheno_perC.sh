#!/bin/bash
#SBATCH --mail-user=annika.b.faucon@vanderbilt.edu
#SBATCH --mail-type=ALL
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=60:00:00
#SBATCH --mem=80G
#SBATCH --output=saige_slurm.out
#SBATCH --job-name="SAIGE"
#SBATCH --account="davis_lab"

#{ea,aa}
i=$1
PATH=$(dirname $0)
for race in {ea,aa}; do
if [ $race = "ea" ]; then
    PLINKFILE="PruneFile_MEGA_batches1-15.12182018_202002.prune.out"
else
    PLINKFILE="BedFile_MEGA_batches1-15.12182018_0619.prune.out"
fi
for gender in {women,men,coed}; do
singularity exec /accre/common/singularity/saige_0.42.1.simg Rscript /usr/local/bin/step1_fitNULLGLMM.R \
    --plinkFile=$PATH/Fibro_112020/input/$PLINKFILE \
    --phenoFile=$PATH/Fibro_112020/input/gwas_file_$race.$gender.txt \
    --phenoCol=Fibromyalgia \
    --covarColList=PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,max_ICD_age$([ "$gender" = "coed" ] && printf ",is.male") \
    --sampleIDColinphenoFile=GRID \
    --traitType=binary \
    --numRandomMarkerforSparseKin=1000 \
    --outputPrefix=$PATH/Fibro_112020/output/110720_mnt.sinai_binary_$(echo $race)_$(echo $gender)_112020_chr$i \
    --outputPrefix_varRatio=$PATH/Fibro_112020/output/110720_mnt.sinai_binary_$(echo $race)_$(echo $gender)_112020_chr$i \
    --IsOverwriteVarianceRatioFile=TRUE \
    --nThreads=4 \
    --LOCO=TRUE >$PATH/Fibro_112020/output/110720_mnt.sinai_binary_$(echo $race)_$(echo $gender)_112020_chr$i.step1.log 2>&1


singularity exec /accre/common/singularity/saige_0.42.1.simg Rscript /usr/local/bin/step2_SPAtests.R \
        --vcfFile=/data/davis_lab/faucona/SAIGE_vcf_files2020/chr$i.combined.head.tab.vcf.gz \
        --vcfFileIndex=/data/davis_lab/faucona/SAIGE_vcf_files2020/chr$i.combined.head.tab.vcf.gz.tbi \
        --vcfField=DS \
        --chrom=$i \
        --sampleFile=$PATH/Fibro_112020/input/samples.txt \
        --GMMATmodelFile=$PATH/Fibro_112020/output/110720_mnt.sinai_binary_$(echo $race)_$(echo $gender)_112020_chr$i.rda \
        --varianceRatioFile=$PATH/Fibro_112020/output/110720_mnt.sinai_binary_$(echo $race)_$(echo $gender)_112020_chr$i.varianceRatio.txt \
        --SAIGEOutputFile=$PATH/Fibro_112020/output/110720_mnt.sinai_binary_$(echo $race)_$(echo $gender)_112020_chr$i.SAIGE.results.txt \
        --IsOutputAFinCaseCtrl=TRUE >$PATH/Fibro_112020/output/110720_mnt.sinai_binary_$(echo $race)_$(echo $gender)_112020_chr$i.step2.log 2>&1
done # gender
done # race
