#ifndef LASSO_H
#define LASSO_H
#include "blackbox.hpp"

class lasso: public blackbox {
public:
    lasso(double param);
    int classify(double* sample) const override;
    double zero_oracle(Data* data, double* weights = NULL) const override;
    void first_oracle(Data* data, double* _pF, int given_index, double* weights = NULL) const override;
};

#endif
