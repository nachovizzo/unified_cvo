# Unified CVO (Continuous Visual Odometry)

This repository is an implementation for CVO (Continuous Visual Odometry).  It can perform pure geometric point cloud registration, color-based registration, and semantic-based registration. It is tested in KITTI stereo and Tum RGB-D dataset. Details are in the [A New Framework for Registration of Semantic Point Clouds from Stereo and RGB-D Cameras](https://arxiv.org/abs/2012.03683) and [Nonparametric Continuous Sensor Registration](https://arxiv.org/abs/2001.04286). 

Specifically, this repository provides:
* GPU implentation of goemetric, color, and semantic based registration
* CPU and GPU implementation of `cos` function angle computation that measures the overlap of two point clouds
* Soft data association between any two pairs of points in the two point clouds



Stacked point clouds based on the resulting frame-to-frame trajectory:
![The stacked pointcloud based on CVO's trajectory](https://github.com/UMich-CURLY/unified_cvo/raw/multiframe/results/stacked_pointcloud.png "Stacked Point Cloud after registration")

[Video](https://drive.google.com/file/d/1GA-2eS9ZE28c4t0BafaiTUJT93WHbFvt/view?usp=sharing) on test results of KITTI and TUM:
[![Test results of KITTI and TUM](https://github.com/UMich-CURLY/unified_cvo/raw/multiframe/results/TUM_featureless.png)](https://drive.google.com/file/d/1GA-2eS9ZE28c4t0BafaiTUJT93WHbFvt/view?usp=sharing)

---

### Dependencies
We recommend using this [Dockerfile](https://github.com/UMich-CURLY/docker_images/tree/master/cvo_gpu) to get a prebuilt environment with all the following dependencies. 

*  `cuda 10 or 11`  (already in docker)
*  `gcc7` (already in docker)
*  `SuiteParse` (already in docker)
* `Sophus 1.0.0 release` (already in docker)
* `Eigen 3.3.7` (already in docker)
* `TBB` (already in docker)
* `Boost 1.65` (already in docker)
* `pcl 1.9.1` (already in docker)
* `OpenCV3` or `OpenCV4` (already in docker)
* `Ceres` (already in docker)
* `Openmp` (already in docker)
* `yaml-cpp 0.7.0` (already in docker)

Note: As specified in the above [Dockerfile](https://github.com/UMich-CURLY/docker_images/tree/master/cvo_gpu) , 'pcl-1.9.1' need to be changed and compiled to get it working with cuda. 
* `pcl/io/boost.h`: add `#include <boost/numeric/conversion/cast.hpp>` at the end of the file before `#endif`
* `pcl/point_cloud.h`: Some meet the error 
```
pcl/point_cloud.h:586100 error: template-id ‘getMapping’ used as a declarator
friend boost::shared_ptr& detail::getMapping(pcl::PointCloud &p);
```
Please see [this doc](https://github.com/autowarefoundation/autoware/issues/2094) for reference

### Compile
```
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${YOUR_INSTALL_DIR} 
make -j4
```

---

### Demo
#### Frame-to-Frame Registration Demo on Kitti
* GeometricCVO: `bash scripts/kitti_geometric_stereo.bash`
* ColorCvo:     `bash scripts/kitti_intensity_stereo.bash`
* SemanticCvo:  `bash scripts/cvo_semantic_img_oct26_gpu0.bash`

#### Multi-Frame Registration Demo on TUM
* ColorCvo: `bash scripts/cvo_irls_tum.bash`

---

### Install this library and import from cmake when using it in another repository
* Install this library: `make install`
* In your own repository's `CMakeLists.txt`:
 ```
 find_package(UnifiedCvo REQUIRED ) 
 target_link_libraries(${YOUR_LIBRARY_NAME}                                                                                                                                                                              
 PUBLIC                                                                                                                                     ${YOUR_OTHER_LINKED_LIBRARIES}                                                                                             
 UnifiedCvo::cvo_utils_lib
 UnifiedCvo::lie_group_utils
 UnifiedCvo::cvo_gpu_img_lib 
 UnifiedCvo::cvo_irls_lib
 UnifiedCvo::elas
 UnifiedCvo::tum
 UnifiedCvo::kitti
 ) 
 ```

---

### How to use the library?

Compile the CvoGPU library for a customized stereo point cloud with 5 dimension color channels (r,g,b, gradient_x, gradient_y) and 19 semantic classes:

#### CMakeLists.txt

```
add_library(cvo_gpu_img_lib ${CVO_GPU_SOURCE})                                                               
target_link_libraries(cvo_gpu_img_lib PRIVATE lie_group_utils cvo_utils_lib  )                               
target_compile_definitions(cvo_gpu_img_lib PRIVATE -DNUM_CLASSES=19 -DFEATURE_DIMENSIONS=5)                  
set_target_properties(cvo_gpu_img_lib PROPERTIES                                                               
POSITION_INDEPENDENT_CODE ON                                                                                 
CUDA_SEPERABLE_COMPILATION ON                                                                                 
COMPILE_OPTIONS "$<$<NOT:$<COMPILE_LANGUAGE:CUDA>>:-fPIC>") 
```

#### Example [experiment code for KITTI stereo](https://github.com/UMich-CURLY/unified_cvo/blob/release/src/experiments/main_cvo_gpu_align_raw_image.cpp) 

```
add_executable(cvo_align_gpu_img ${PROJECT_SOURCE_DIR}/src/experiments/main_cvo_gpu_align_raw_image.cpp)     
target_compile_definitions(cvo_align_gpu_img PRIVATE -DNUM_CLASSES=19 -DFEATURE_DIMENSIONS=5)                 
target_link_libraries(cvo_align_gpu_img cvo_gpu_img_lib cvo_utils_lib kitti  boost_filesystem boost_system) 
```

#### Example calibration file (cvo_calib.txt)     
Calibration files are required for each data sequence. Note that for different sequences, the calibrations could be different. We assume the input images are already rectified. 

* Stereo camera format: `fx fy cx cy  baseline  image_width image_height`. Then you `cvo_calib.txt` file in the sequence's folder should contain  `707.0912 707.0912 601.8873 183.1104 0.54 1226 370`
  
* RGB-D camera format:  `fx fy cx cy  depthscale image_width image_height`. Then you `cvo_calib.txt` file in the sequence's folder should contain `517.3 516.5 318.6 255.3 5000.0 640 480`



#### Example [parameter file for geometry registration](https://github.com/UMich-CURLY/unified_cvo/blob/release/cvo_params/cvo_geometric_params_img_gpu0.yaml): 

```%YAML:1.0                                                                                                                                
---                                                                                                                                   
ell_init_first_frame: 0.95   # The lengthscale for the first frame if initialization is unknow                                                                                                                     
ell_init: 0.25               # Initial Lengthscale                                                                                                                        
ell_min: 0.05                # Minimum Lengthscale                                                                                                                            
ell_max: 0.9                                                                                                                              
dl: 0.0                                                                                                                                 
dl_step: 0.3                                                                                                                              
sigma: 0.1                                                                                                                               
sp_thres: 0.007                                                                                                                             
c: 7.0                                                                                                                                 
d: 7.0                                                                                                                                 
c_ell: 0.05                    # lengthscale for color/intensity if used                                                                                                                          
c_sigma: 1.0                                                                                                                                
s_ell: 0.1                     # lengthscale for semantics if used                                                                                                                            
s_sigma: 1.0                                                                                                                            
MAX_ITER: 10000                # max number of iterations to run in the optimization                                                                                                                          
min_step: 0.000001             # minimum step size                                                                                                                         
max_step: 0.01                 # maximum step size                                                                                                                            
eps: 0.00005                                                                                                                              
eps_2: 0.000012                                                                                                                             
ell_decay_rate: 0.98 #0.98                                                                                                                       
ell_decay_rate_first_frame: 0.99                                                                                                                    
ell_decay_start: 60                                                                                                                           
ell_decay_start_first_frame: 600  #2000                                                                                                                 
indicator_window_size: 50                                                                                                                        
indicator_stable_threshold: 0.001 #0.002                                                                                                                
is_ell_adaptive: 0                                                                                                                           
is_dense_kernel: 0                                                                                                                           
is_full_ip_matrix: 0                                                                                                                          
is_using_geometry: 1            # if geoemtric kernel is computed k(x,z)                                                                                                                       
is_using_intensity: 0           # if color kernel is computed <l_x, l_z>. Enable it if using color info                                                                                                              
is_using_semantics: 0           # if semantic kernel is computed. Enable it if using semantics                                                                                                                        
is_using_range_ell: 0
is_using_kdtree: 0
is_exporting_association: 0
multiframe_using_cpu: 1
nearest_neighbors_max: 512

```


#### Headers 

Core Library: `include/unified_cvo/cvo/CvoGPU.hpp`. This header file is the main interfacing of using the library. The `align` functions perform the registration. The `function_angle` functions measure the overlap of the two point clouds. 

Customized PCL PointCloud: `include/unified_cvo/utils/PointSegmentedDistribution.hpp`.  This customized point definition takes number of classes and number of intensity channels as template arguments. These two are specified as target compiler definitions in the `CMakeLists.txt`

Point Selector and Cvo PointCloud constructor: `include/unified_cvo/utils/CvoPointCloud.hpp` . Ways of contructing it are available 


---
 
 ### Citations
 If you find this repository useful, please cite 
 ```
 @INPROCEEDINGS{9561929,
  author={Zhang, Ray and Lin, Tzu-Yuan and Lin, Chien Erh and Parkison, Steven A. and Clark, William and Grizzle, Jessy W. and Eustice, Ryan M. and Ghaffari, Maani},
  booktitle={2021 IEEE International Conference on Robotics and Automation (ICRA)}, 
  title={A New Framework for Registration of Semantic Point Clouds from Stereo and RGB-D Cameras}, 
  year={2021},
  volume={},
  number={},
  pages={12214-12221},
  doi={10.1109/ICRA48506.2021.9561929}}

 ```
 and 
 
```
@article{clark2020nonparametric,
  title={Nonparametric Continuous Sensor Registration},
  author={Clark, William and Ghaffari, Maani and Bloch, Anthony},
  journal={arXiv preprint arXiv:2001.04286},
  year={2020}
}
```
