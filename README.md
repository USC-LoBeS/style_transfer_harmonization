# Style Transfer Harmonization

![image](https://github.com/bigting84/style_transfer_harmonization/blob/main/represent_pictures/video_ref1.gif)

Paper: [Style Transfer Using Generative Adversarial Networks for Multi-site MRI Harmonization](https://link.springer.com/chapter/10.1007/978-3-030-87199-4_30)

Multi-site MRI data often exhibits variations in image appearance due to differences in imaging protocols, scanner hardware, and acquisition parameters. The paper presents a novel approach leveraging Generative Adversarial Networks (GANs) for MRI harmonization. By adapting the style of MRI images from one site to match the style of another, we aim to reduce inter-site variability and improve the generalizability of MRI-based models.

## Table of Contents

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Environment Setup](#environment-setup)
- [Usage](#usage)
  - [Pretrained Model](#pretrained-model)
  - [Training Networks](#training-networks)

## Getting Started  

To begin, proceed with cloning this repository. Within this repository, you will find both the source code and the pre-trained model, as detailed within the paper.

The pre-trained model is stored within the `/expr_256/checkpoints/` directory. However, due to GitHub's file size limitations, we have included only a partial version of the model. To obtain the complete set of model files, please refer to the following external link: [Complete Model Files](https://www.dropbox.com/sh/d60gvw7h21748d2/AADCVfKjCOONG2AodL7Lv5Bca?dl=0).

After accessing the files, replace the existing files in the `/expr_256/checkpoints/` directory with the newly downloaded files. 

### Prerequisites

Clone this repository:

```
git clone https://github.com/USCLoBeS/style_transfer_harmonization.git
cd style_transfer_harmonization/
```
The model is trained on skull-stripped images, registered to MNI152 template and resized to dimensions of `256 x 256 x 256`. In order to use the model, process the data to the following requirements.

The `pre_process.sh` script processes the images to the following requirements. However, it requires **skull-stripped** images to function correctly. 

**Note: The script uses `flirt` to process the data, please make sure to have it [installed](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation).**

To registered and resize image, pass the input directory containing the images and the output directory to save images as arguments. 

An Illustrative example is stored in `nii_MNI/`
```
sh pre_process.sh ./nii_MNI/raw ./nii_MNI/resampled 
```

### Environment Setup

To begin using the model please install the required dependencies. Use the provided `ENV.yml` script to create and install the dependencies. Activate the environment once its created

```
conda env create -n style-harmonization --file ENV.yml
conda activate style-harmonization
```

## Usage
You can use the pretrained model or train the model on your own data. Please refer to the following sections as per your requirements.

### Pretrained Model

To use the pretrained model, run the `harmonize_images.sh` file with the following paths:

> - Single Reference Image
> - Input Images Directory
> - Output Directory
> - The Model checkpoints

**Note: The Input and Reference images must be pre-processed prior to using the model**

```
harmonize_images.sh demo/ref/00210_t1_final_mask_ds.nii.gz demo/input_nii/ demo/output/ expr_256/
```

### Training Networks 

In order to train the model, please convert the images into slices. Create an input and a validation directory and use the following commands to convert slices. 

| Flags         | Description                                   |
| ------------- | --------------------------------------------- |
| load_path     | The path to the input images                  |
| save_path     | The path to store output slices               |

```
# Prepare Training slices
python ./processing/convert_nii_to_slices_train.py --load_path demo/train_nii --save_path demo/train_slices

# Prepare Validation slices
python ./processing/convert_nii_to_slices_train.py --load_path demo/val_nii --save_path demo/val_slices
```


To train the model from scratch, run the following commands. Generated images and network checkpoints will be stored in the `expr/samples` and `expr/checkpoints` directories, respectively.

```
export CUDA_VISIBLE_DEVICES=3

python main.py --mode train --lambda_reg 1 -lambda_sty 1 \
            --lambda_ds 1 --lambda_cyc 100 --ds_iter 200000 --total_iters 200000 \
            --eval_every 200000 --train_img_dir demo/train_slices \
            --val_img_dir demo/val_slices --sample_every 5000 \
            --sample_dir expr_customer/samples --checkpoint_dir expr_customer/checkpoints \
            --batch_size 4
```

    
