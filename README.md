# style_transfer_harmonization
![image](https://github.com/bigting84/style_transfer_harmonization/blob/main/represent_pictures/video_ref1.gif)

# Paper
MICCAI: https://link.springer.com/chapter/10.1007/978-3-030-87199-4_30

ABSTRACT:
Large data initiatives and high-powered brain imaging analyses require the pooling of MR images acquired across multiple scanners, often using different protocols. Prospective cross-site harmonization often involves the use of a phantom or traveling subjects. However, as more datasets are becoming publicly available, there is a growing need for retrospective harmonization, pooling data from sites not originally coordinated together. Several retrospective harmonization techniques have shown promise in removing cross-site image variation. However, most unsupervised methods cannot distinguish between image-acquisition based variability and cross-site population variability, so they require that datasets contain subjects or patient groups with similar clinical or demographic information. To overcome this limitation, we consider cross-site MRI image harmonization as a style transfer problem rather than a domain transfer problem. Using a fully unsupervised deep-learning framework based on a generative adversarial network (GAN), we show that MR images can be harmonized by inserting the style information encoded from a reference image directly, without knowing their site/scanner labels a priori. We trained our model using data from five large-scale multi-site datasets with varied demographics. Results demonstrated that our style-encoding model can harmonize MR images, and match intensity profiles, successfully, without relying on traveling subjects. This model also avoids the need to control for clinical, diagnostic, or demographic information. Moreover, we further demonstrated that if we included diverse enough images into the training set, our method successfully harmonized MR images collected from unseen scanners and protocols, suggesting a promising novel tool for ongoing collaborative studies.

# Environment installation
```
conda create -n style-harmonization python=3.6.7 
conda activate style-harmonization
conda install -y pytorch=1.4.0 torchvision=0.5.0 cudatoolkit=10.0 -c pytorch 
conda install x264=='1!152.20180717' ffmpeg=4.0.2 -c conda-forge 
conda install –c conda-forge nibabel
pip install opencv-python==4.1.2.30 ffmpeg-python==0.2.0 scikit-image==0.16.2 
pip install pillow==7.0.0 scipy==1.2.1 tqdm==4.43.0 munch==2.5.0
```
# Use the current model on your own images

The current model is saved in expr_256/checkpoints/. The existing model is trained on skull-stripped images sized of 256x256x256, which are resampled from MNI152 template (182x218x182). That is: all images were first registered to MNI152 templated, skull-stripped, and then resampled to 256x256x256. If users want to use the current model, please register and resize the images in the same way.

To resize the registered image, please use the script below, where ID_list.txt is the input nii images without .nii.gz extentions

```
resize_nii_256.sh path/to/input/nii path/to/resized/nii ID_list.txt
```

Put all resized nii images to be harmonized into a folder (say demo/input_nii here). Select a reference image (say demo/ref/00210_t1_final_mask_ds.nii.gz here). Run the script below to harmonize all images.

```
activate style-harmonization
harmonize_images.sh demo/ref/00210_t1_final_mask_ds.nii.gz demo/input_nii/ demo/output/ expr_256/
```


# Train a new model using your own images

First put all nii images for training in a folder (say demo/train_nii), and nii images for testing in another folder (say demo/val_nii). Then convert images to slices and prepare the training set and validation set using the scripts below.
```
python convert_nii_to_slices_train.py --load_path demo/train_nii --save_path demo/train_slices

python convert_nii_to_slices_train.py --load_path demo/val_nii --save_path demo/val_slices
```
Select GPU
```
export CUDA_VISIBLE_DEVICES=3
```

Train the model using the slices just created
```
python main.py --mode train --lambda_reg 1 --lambda_sty 1 --lambda_ds 1 --lambda_cyc 100 --ds_iter 200000 --total_iters 200000 --eval_every 200000 --train_img_dir demo/train_slices --val_img_dir demo/val_slices --sample_every 5000 --sample_dir expr_customer/samples --checkpoint_dir expr_customer/checkpoints --batch_size 4
```




