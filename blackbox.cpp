#include "blackbox.hpp"

blackbox::~blackbox() {
    delete[] m_weights;
    delete[] m_params;
}

void blackbox::set_init_weights(double* init_weights) {
    update_model(init_weights);
}

double* blackbox::get_model() const {
    return m_weights;
}

void blackbox::update_model(double* new_weights) {
    for(size_t i = 0; i < MAX_DIM; i ++)
        m_weights[i] = new_weights[i];
}

void blackbox::first_oracle(Data* data, double* _pF, bool is_stochastic
        , std::default_random_engine* generator
        , std::uniform_int_distribution<int>* distribution
        , double* weights) const {
        if(weights == NULL) weights = m_weights;
        if(is_stochastic) {
            int rand_samp = (*distribution)(*generator);
            first_oracle(data, _pF, rand_samp, weights);
        }
        else {
            for(size_t i = 0; i < data->size(); i ++) {
                double* _pf = new double[MAX_DIM];
                first_oracle(data, _pf, i, weights);
                for(size_t j = 0; j < MAX_DIM; j ++)
                    _pF[j] += _pf[j];
                delete[] _pf;
            }
            for(size_t j = 0; j < MAX_DIM; j ++)
                _pF[j] /= data->size();
        }
}
