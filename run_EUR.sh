#!/bin/sh

for i in {1..22}; do
    for gender in {u61_Coed,61u_Coed}; do
        sbatch --job-name="SAIGE-chr$i" SAIGE_EUR_perC.sh $i $gender
    done
done
