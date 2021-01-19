#!/bin/sh

race=$1
gender=$2
file_prefix=110720_mnt.sinai_binary_$(echo $race)_$(echo $gender)_112020
have_all=1
all_paths=""
last_good=""
for chr in {1..22}; do
    file=$(echo $file_prefix)_chr$(echo $chr).SAIGE.results.txt
    realpath=""
    if [ -f /fs0/fauconab/Saige_results/Fibromyalgia_results_1120/$race/$gender/$file ]; then
        realpath=/fs0/fauconab/Saige_results/Fibromyalgia_results_1120/$race/$gender/$file
    elif [ -f $HOME/singularity/SAIGE/Fibro_112020/output/$file ]; then
        realpath=$HOME/singularity/SAIGE/Fibro_112020/output/$file
    elif [ -f $HOME/singularity/SAIGE/Fibro_112020/output/$race/$file ]; then
        realpath=$HOME/singularity/SAIGE/Fibro_112020/output/$race/$file
    else
        echo "Error: Chromosome $chr not found"
        have_all=0
    fi
    if [ -n "$realpath" ]; then
        if [ $(stat -c "%s" $realpath) -gt 1000000 ]; then
            echo "Found chromosome $chr at $realpath"
            all_paths+="$realpath "
            last_good=$realpath
        else
            echo "Error: Chromosome $chr too small at $realpath"
            have_all=0
        fi
    fi
done
if [ $have_all = "1" ]; then
    set -x
    file=$(echo $file_prefix).SAIGE.results.txt
    output_file=/fs0/fauconab/Saige_results/Fibromyalgia_results_1120/final_results/$file
    head -n1 $last_good > $output_file
    cat $all_paths | grep -v SNPID >> $output_file
fi
