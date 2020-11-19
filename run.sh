#!/bin/sh

for i in {1..22}; do
    sbatch --job-name="SAIGE-chr$i" slurm_submit_nov20_newpheno_perC.sh $i
done
