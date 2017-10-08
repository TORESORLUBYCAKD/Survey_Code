#ifndef GRADDESCDENSE_H
#define GRADDESCDENSE_H
#include "blackbox.hpp"

namespace grad_desc_dense {
    const int SVRG_LAST_LAST = 1;
    const int SVRG_AVER_AVER = 2;
    const int SVRG_AVER_LAST = 3;

    double* GD(double* X, double* Y, size_t N, blackbox* model, size_t iteration_no = 10000
        , double L = 1.0, double step_size = 1.0, bool is_store_result = false);
    double* SGD(double* X, double* Y, size_t N, blackbox* model, size_t iteration_no = 10000
        , double L = 1.0, double step_size = 1.0, bool is_store_result = false);
    std::vector<double>* SAGA(double* X, double* Y, size_t N, blackbox* model, size_t iteration_no
        , double L = 1.0, double step_size = 1.0, bool is_store_result = false);
    // For Prox_SVRG / SVRG, Mode 1: last_iter--last_iter, Mode 2: aver_iter--aver_iter, Mode 3: aver_iter--last_iter
    std::vector<double>* Prox_SVRG(double* X, double* Y, size_t N, blackbox* model, size_t iteration_no
        , int Mode = 1, double L = 1.0, double step_size = 1.0, bool is_store_result = false);
    std::vector<double>* SVRG(double* X, double* Y, size_t N, blackbox* model, size_t iteration_no
        , int Mode = 1, double L = 1.0, double step_size = 1.0, bool is_store_result = false);
    std::vector<double>* Ada_SVRG(double* X, double* Y, size_t N, blackbox* model, size_t iteration_no
        , int Mode = 1, double L = 1.0, double step_size = 1.0, bool is_store_result = false);
    std::vector<double>* Katyusha(double* X, double* Y, size_t N, blackbox* model, size_t iteration_no
        , double L = 1.0, double sigma = 0.0001, double step_size = 1.0, bool is_store_result = false);
    // Only L2. Non-Prox Update. Using Update Option I.
    std::vector<double>* Katyusha_2(double* X, double* Y, size_t N, blackbox* model, size_t iteration_no
        , double L = 1.0, double sigma = 0.0001, double step_size = 1.0, bool is_store_result = false);

    // Only Ridge Regression
    std::vector<double>* SVRG_SD(double* X, double* Y, size_t N, blackbox* model, size_t iteration_no
        , size_t interval, double L, double sigma, double step_size, double r, double* SV, bool is_store_result = false);
    std::vector<double>* SAGA_SD(double* X, double* Y, size_t N, blackbox* model, size_t iteration_no
        , size_t interval, double L, double sigma, double step_size, double r, double* SV, bool is_store_result = false);

}

#endif
