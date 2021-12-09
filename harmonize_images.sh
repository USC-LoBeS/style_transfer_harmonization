#!/bin/sh

if [ $# -lt 2 ]
then
        echo "Usage: $0 <TARGET_DIR> <PREFIX> <CASE> <COPYTO_DIR>"
        exit 1
fi

REF_IMG=$1
INP_PATH=$2
SAVEPATH=$3
MODELPATH=$4


ref_id=$(basename $REF_IMG .nii.gz)

echo
echo "-------------Reference image is-----------------"
echo "$REF_IMG"
echo "------------------------------------------------"
echo

python convert_nii_to_slices_test.py --input_img $REF_IMG --save_path $SAVEPATH --is_ref True
REFPATH=${SAVEPATH}/ref/${ref_id}/

for INP_IMG in ${INP_PATH}/*.nii.gz;do

    inp_id=$(basename $INP_IMG .nii.gz)
    
    echo
    echo "-------------source image now is-----------------"
    echo "$INP_IMG"
    echo "------------------------------------------------"
    echo

    python convert_nii_to_slices_test.py --input_img $INP_IMG --save_path $SAVEPATH

    SRCPATH=${SAVEPATH}/${inp_id}
    TMPPATH=${SRCPATH}/npy
    mkdir ${TMPPATH}



    for subf in $SRCPATH/*; do

        echo
        echo "--------------------------------------------------------------------------------"
        echo "--------------------------------------------------------------------------------"
        echo "Now the harmonization on................."
        echo "$subf"
        echo "--------------------------------------------------------------------------------"
        echo "--------------------------------------------------------------------------------"
        echo

        orient=$(basename $subf)
        echo $orient

        python main.py --mode sample --resume_iter 200000 \
               --checkpoint_dir ${MODELPATH}/checkpoints/ \
               --result_dir ${TMPPATH} \
               --src_dir ${subf} \
               --ref_dir ${REFPATH}/$orient \
               --val_batch_size 254

    done

    python make_nii_from_3_orientations.py --input_img ${INP_IMG} --load_path ${TMPPATH} --save_path ${SRCPATH}
    python make_nii_from_3_orientations.py --input_img ${INP_IMG} --load_path ${TMPPATH} --save_path ${SRCPATH} --is_src True

done



