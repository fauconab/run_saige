#!/bin/bash
#SBATCH --mail-user=annika.b.faucon@vanderbilt.edu
#SBATCH --mail-type=ALL
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --time=50:00:00
#SBATCH --mem=80G
#SBATCH --output=saige_slurm_EU.out
#SBATCH --job-name="80EUSAIGE"
#SBATCH --account="coxlab"

#{ea,aa}
i=$1
gender=$2
OUTPUT_PATH=/data/davis_lab/shared/TOPMed_imputed
for race in {ea,}; do
#PLINKFILE="/data/davis_lab/shared/genotype_data/biovu/processed/imputed/best_guess/MEGA/MEGA_recalled/20200518_biallelic_mega_recalled.chr1-22.grid.EU.filt1"
#for gender in {Male,Female,Coed}; do
singularity exec /accre/common/singularity/saige_0.42.1.simg Rscript /usr/local/bin/step1_fitNULLGLMM.R \
    --plinkFile=/home/fauconab/singularity/SAIGE/Fibro_112020/input/BedFile_MEGA_recalled.20200518 \
    --phenoFile=$OUTPUT_PATH/input/15Dec2020_EU_pheno3_covar_pheno_mi_$gender.csv \
    --phenoCol=Pheno3 \
    --covarColList=PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,PC11,PC12,PC13,PC14,PC15,PC16,PC17,PC18,PC19,PC20,AGE,AGE2$([[ "$gender" = *"Coed" ]]  && printf ",male1_f2,m1f2_times_age") \
    --sampleIDColinphenoFile=GRID \
    --traitType=binary \
    --numRandomMarkerforSparseKin=2000 \
    --outputPrefix=$OUTPUT_PATH/output/COVID_831_$(echo $race)_$(echo $gender)_122020_chr$i \
    --outputPrefix_varRatio=$OUTPUT_PATH/output/COVID_831_$(echo $race)_$(echo $gender)_122020_chr$i \
    --IsOverwriteVarianceRatioFile=TRUE \
    --nThreads=4 \
    --LOCO=TRUE >$OUTPUT_PATH/output/COVID_831_$(echo $race)_$(echo $gender)_122020_chr$i.step1.log 2>&1


singularity exec /accre/common/singularity/saige_0.42.1.simg Rscript /usr/local/bin/step2_SPAtests.R \
        --vcfFile=/data/davis_lab/faucona/SAIGE_vcf_files2020/chr$i.combined.head.tab.vcf.gz \
        --vcfFileIndex=/data/davis_lab/faucona/SAIGE_vcf_files2020/chr$i.combined.head.tab.vcf.gz.tbi \
        --vcfField=DS \
        --minMAF=0.0001 \
        --minMAC=1 \
        --chrom=$i \
        --sampleFile=/data/davis_lab/faucona/SAIGE_vcf_files2020/samples.txt \
        --GMMATmodelFile=$OUTPUT_PATH/output/COVID_831_$(echo $race)_$(echo $gender)_122020_chr$i.rda \
        --varianceRatioFile=$OUTPUT_PATH/output/COVID_831_$(echo $race)_$(echo $gender)_122020_chr$i.varianceRatio.txt \
        --SAIGEOutputFile=$OUTPUT_PATH/output/COVID_831_$(echo $race)_$(echo $gender)_122020_chr$i.SAIGE.results.txt \
        --IsOutputNinCaseCtrl=TRUE \
        --IsOutputHetHomCountsinCaseCtrl=TRUE \
        --IsOutputAFinCaseCtrl=TRUE >$OUTPUT_PATH/output/COVID_831_$(echo $race)_$(echo $gender)_122020_chr$i.step2.log 2>&1
#done # gender
done # race
#    --covarColList=PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,PC11,PC12,PC13,PC14,PC15,PC16,PC17,PC18,PC19,PC20,AGE,AGE2$([ "$gender" = "Coed" ] && printf ",male1_f2,m1f2_times_age") \
