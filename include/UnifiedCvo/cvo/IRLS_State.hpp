#pragma once
#include "utils/data_type.hpp"
#include <Eigen/Dense>
#include <ceres/ceres.h>
#include <memory>
//#include <ceres/local_parameterization.h>

namespace cvo {
  class BinaryState {
  public:
    using Mat34d_row = Eigen::Matrix<double, 3, 4, Eigen::RowMajor>;
    using Mat4d_row = Eigen::Matrix<double, 4, 4, Eigen::RowMajor>;

    typedef std::shared_ptr<BinaryState> Ptr;
    
    virtual int update_inner_product() { return 0; }

    virtual void add_residual_to_problem(ceres::Problem & problem) {}
                                         // ceres::LocalParameterization * parameterization);

    
  };



  
}
