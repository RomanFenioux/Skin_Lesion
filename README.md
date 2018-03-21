This project is a comparison of segmentation methods for skin lesions in dermoscopy images.

Three segmentation algorithms are implemented :
- Adaptative thresholding with Otsu's optimal threshold selection
- Statistical Region Merging 
- Distance Regularized Level Set Evolution

For test, you only need OneImageSegt.m (to have a direct feedback on one image) or segtEvaluation.m (to compute dice and jaccard index on the entire dataset).
Just press F5 and read the console when inputs are required (sometimes graphic input).
For parameter tweaking, stick to these two scripts, you should find everything. 

Preprocessing avvailable : Hair removal, Black frame removal, color channel selection from RGB and CIE-XYZ colorspaces and contrast enhancement.

Postprocessing available : morphological filling, denoising by CCA (connected component analysis).

Data used for this project are available in data/ and are a sample of the dataset from the ISIC challenge "Skin Lesion Analysis Toward Melanoma Detection", 2017.

