#ifndef REGULARIZER_HPP
#define REGULARIZER_HPP
#include <stdio.h>

namespace regularizer {
    const int L2 = 1;
    const int L1 = 0;
    const int NONE = -1;
    double zero_oracle(int _regular, double lambda, double* weight);
    void first_oracle(int _regular, double* _pR, double lambda, double* weight);
    double proximal_operator(int _regular, double& _prox, double lambda, double step_size
            , size_t times = 1, double additional_constant = 0.0, bool is_lazy_weighted = false
            , double* lazy_average_weight = NULL);
}
#endif
