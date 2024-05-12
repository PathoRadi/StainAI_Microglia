# StainAI Microglia V1

## Introduction
StainAI Microglia V1 is an advanced MATLAB software designed to analyze optical microscopy images stained with IBA for identifying six microglia morphotypes: ramified, hypertrophic, bushy, amoeboid, rod, and hyper-rod. Leveraging YOLOv5 object detection (Python), U-net segmentation (MATLAB Deep Learning Toolbox), and a C50 classifier (R), it delivers precise location and segmentation of microglia. The software outputs morphotype maps in JPG format and stores metrics in xls and JSON files adhering to the COCO format. StainAI Microglia V1 is compatible with both Windows and Linux platforms, provided all dependencies are installed.

## Prerequisites
- MATLAB
- Python with a Conda environment setup
- R with necessary libraries installed

## Dependencies
Ensure the following dependencies are installed and configured:

- **COCOAPI**: download and installed from the [COCOAPI GitHub repository](https://github.com/cocodataset/cocoapi).
  - set 'cocoapi-master' under matlab path
- **YOLOv5**: Follow installation instructions and download from the [YOLOv5 GitHub repository](https://github.com/ultralytics/yolov5).
  - Download and save yolo_0504_yolov5m.pt in ~\yolov5pt
  - Configure paths in `main_001.m` or `main_001.mlx`:
    env.path_yolo=[your_path_to_yolov5 filesep 'yolov5-master'];
    env.path_conda_yolo='C:\\Users\\xxxx\\anaconda3\\envs\\pytyolov5\\';
        
- **R**: Download R from [The R Project website](https://www.r-project.org/). Install the packages `caret`, `C50`, and `limma` via [Bioconductor](https://bioconductor.org/packages/release/bioc/html/limma.html).
  - Set R paths:
    env.path_R='D:\\R\\R-4.3.2\\bin';

## Installation
1. Clone this repository to your local machine.
2. Install all required dependencies as listed above.
3. Update environment paths in `main_001.m` or `main_001.mlx` to match your system configurations.

## Usage
Navigate to `main_001.m` or `main_001.mlx` and perform the following configurations:

1. **Set MATLAB Path**:
   env.matlab_path='F:\\stainAIMicroglia_v1\\';
2. **Data Setup**:
   env.data_path0='F:\\data\\';  
   DataSetInfo.sample_ID{1}='UN1'; 
3. **Image Adjustments**:
   For RGB images with a white background:
       opts.imadj_function='reverse_bw'; 
       DataSetInfo.im_reverse=1;
   For grayscale images with a black background:
       opts.imadj_function='none'; 
       DataSetInfo.im_reverse=0;
4. **Image Resolution**:
    DataSetInfo.im_pixel_size = 0.464;
5. **Run Detection**:
    Execute the script to process images and save results in the specified directory.

## 

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

