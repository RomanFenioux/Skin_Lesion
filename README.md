This project is a comparison of segmentation methods for skin lesions in dermoscopy images.

Three segmentation algorithms are implemented :
- Adaptative thresholding with Otsu's optimal threshold selection
- Statistical Region Merging 
- Distance Regularized Level Set Evolution

Hair removal, color channel selection from RGB and CIE-XYZ colorspaces and contrast enhancement are used as preprocessing.

Postprocessing depends on the method. For Otsu : morphological filling, denoising (filtering small regions).

Data used for this project are available in data/

