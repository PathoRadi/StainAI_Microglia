# StainAI Microglia

## Introduction
StainAI is a sophisticated software package designed for analyzing stained microglia using deep learning, transforming immunohistochemistry images into quantitative maps. It generates maps of morphological phenotypes and morphometric parameters, enabling detailed analysis by drawing regions of interest. The core StainAI program is developed in MATLAB to facilitate the image processing, analysis, and reconstruction pipeline. It integrates YOLOv5 for object detection (Python), U-Net segmentation (MATLAB Deep Learning Toolbox), and the C50 classifier (R). The software outputs morphotype maps in JPG format and saves metrics in xls and JSON files adhering to the COCO format. StainAI is compatible with both Windows and Linux platforms, provided all dependencies are installed.

View the [Analysis Results](https://PathoRadi.github.io/StainAI_Microglia/) generated from our MATLAB Live Editor script.

## Prerequisites
- MATLAB (>=2022b)
- Python (>=3.8.0) with a Conda environment setup
- R (>=R-4.2.1) with necessary libraries installed

## Dependencies
Ensure the following dependencies are installed and configured:

- **COCOAPI**: download and installed from the [COCOAPI GitHub repository](https://github.com/cocodataset/cocoapi) for Matlab.
  - Configure paths in `main__001.m` or `main_001.mlx`:
    env.coco_path='F:\stainAIgithub\Dependencies\cocoapi-master\';
    or put 'cocoapi-master' under matlab path.

- **YOLOv5**: Follow installation instructions and download from the [YOLOv5 GitHub repository](https://github.com/ultralytics/yolov5).
  - Configure paths in `main__001.m` or `main_001.mlx`:
    env.path_yolo=[your_path_to_yolov5 filesep 'yolov5-master'];
    env.path_conda_yolo='C:\Users\xxxx\anaconda3\envs\pytyolov5\';
        
- **R**: Download R from [The R Project website](https://www.r-project.org/). Install the packages `caret`, `C50`, `jsonlite`, and `limma` via [Bioconductor](https://bioconductor.org/packages/release/bioc/html/limma.html).
  - Configure paths in `main__001.m` or `main_001.mlx`:
    env.path_R='F:\R\R-4.2.1\bin';

## Installation
1. Clone this repository to your local machine.
2. Install all required dependencies as listed above.
3. Update environment paths in `main__001.m` or `main_001.mlx` to match your system configurations.

## Usage
Navigate to `main__001.m` or `main_001.mlx` and perform the following configurations:
1. **Set MATLAB Path**:
   env.matlab_path='F:\stainAIgithub\StainAIMicroglia_v1\';
2. **Data Setup**:
   env.data_path0='F:\stainAIgithub\StainAIMicroglia_v1\data\';  
   DataSetInfo.sample_ID{1}='CR1'; 
3. **Image Adjustments**:
   For RGB images with a white background:
       opts.imadj_function='reverse_bw'; 
       DataSetInfo.im_reverse=1;
   For RGB image with large black space, also create mask for cell exist region
       opts.imadj_function='remove_large_block__v01'; 
       DataSetInfo.im_reverse=1;
   For grayscale images with a black background:
       opts.imadj_function='none'; 
       DataSetInfo.im_reverse=0;
4. **Image Resolution**:
    DataSetInfo.im_pixel_size = 0.464;
5. **Run Detection**:
    Execute the script to process images and save results in the specified directory.    

## Third-Party Code and Libraries
This project utilizes code and libraries from several third-party sources, detailed below. We acknowledge the authors and provide these details for informational purposes.

### External Components
1. **condalab** by Srinivas Gorur-Shandilya
   - **Source**: https://github.com/sg-s/condalab
   - **License**: GPL v3

2. **Focus Measure** by Said Pertuz
   **Source**: https://www.mathworks.com/matlabcentral/fileexchange/27314-focus-measure
   - **License**: Copyright (c) 2017, Said Pertuz

3. **A suite of minimal bounding objects**  by Srinivas John D'Errico 
   - **Source**: https://www.mathworks.com/matlabcentral/fileexchange/34767-a-suite-of-minimal-bounding-objects
   - **License**: Copyright (c) 2012, John D'Errico

4. **RunRcode** by Wei-Rong Chen
   **Source**: https://www.mathworks.com/matlabcentral/fileexchange/50071-runrcode-rscriptfilename-rpath
   - **License**: Copyright (c) 2017, Wei-Rong Chen

5. **RLE de/encoding** condalab by Stefan Eireiner
   **Source**: https://www.mathworks.com/matlabcentral/fileexchange/4955-rle-de-encoding
   - **License**: No License

### Licensing
The third-party codes included in this project are used in compliance with their respective licenses. For detailed licensing information of each component, please refer to the source links provided above.

## License
Our project is licensed under the Apache License 2.0. However, some dependencies and third-party components contained within may be licensed differently. Please refer to individual components for further details.

