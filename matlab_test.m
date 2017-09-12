clear;
%load 'real-sim.mat';
load 'rcv1_train.binary.mat';
%load 'a9a.mat';
%load 'Adult.mat';
%load 'covtype.mat';
%% Parse Data
X = [ones(size(X, 1), 1) X];
[N, Dim] = size(X);
X = X';

%% Normalize Data
sum1 = 1./sqrt(sum(X.^2, 1));
if abs(sum1(1) - 1) > 10^(-10)
    X = X.*repmat(sum1, Dim, 1);
end
clear sum1;

%% Set Params
passes = 240;
model = 'logistic'; % least_square / svm / logistic
regularizer = 'L1'; % L1 / L2 / elastic_net
init_weight = repmat(0, Dim, 1); % Initial weight
lambda1 = 10^(-6); % L2_norm parameter
lambda2 = 10^(-5); % L1_norm parameter
L = (0.25 * max(sum(X.^2, 1)) + lambda1); % For logistic regression
sigma = lambda1; % For Katyusha / SAGA, Strong Convex Parameter
is_sparse = issparse(X);
Mode = 1;
is_plot = true;
fprintf('Model: %s-%s\n', regularizer, model);


% SAGA
algorithm = 'SAGA';
loop = int64((passes - 1) * N); % One Extra Pass for initialize SAGA.
step_size = 1 / (2 * (sigma * N + L));
fprintf('Algorithm: %s\n', algorithm);
tic;
hist1 = Interface(X, y, algorithm, model, regularizer, init_weight, lambda1, L, step_size, loop, is_sparse, Mode, sigma, lambda2);
time = toc;
fprintf('Time: %f seconds \n', time);
X_SAGA = [0 1 2:3:passes - 2]';
hist1 = [X_SAGA, hist1];
clear X_SAGA;


% SVRG
% For SVRG / Prox_SVRG
% Mode 1: last_iter--last_iter  ----Standard SVRG
% Mode 2: aver_iter--aver_iter  ----Standard Prox_SVRG
% Mode 3: aver_iter--last_iter  ----VR-SGD
algorithm = 'Prox_SVRG';
Mode = 1;
step_size = 1 / (5 * L);
loop = int64(passes / 3); % 3 passes per loop
fprintf('Algorithm: %s\n', algorithm);
tic;
hist2 = Interface(X, y, algorithm, model, regularizer, init_weight, lambda1, L, step_size, loop, is_sparse, Mode, sigma, lambda2);
time = toc;
fprintf('Time: %f seconds \n', time);
X_SVRG = [0:3:passes]';
hist2 = [X_SVRG, hist2];

% Prox_SVRG
algorithm = 'Prox_SVRG';
Mode = 2;
step_size = 1 / (5 * L);
loop = int64(passes / 3); % 3 passes per loop
fprintf('Algorithm: %s\n', algorithm);
tic;
hist3 = Interface(X, y, algorithm, model, regularizer, init_weight, lambda1, L, step_size, loop, is_sparse, Mode, sigma, lambda2);
time = toc;
fprintf('Time: %f seconds \n', time);
hist3 = [X_SVRG, hist3];

% Katyusha
algorithm = 'Katyusha';
% Fixed step_size
loop = int64(passes / 3); % 3 passes per loop
fprintf('Algorithm: %s\n', algorithm);
tic;
hist4 = Interface(X, y, algorithm, model, regularizer, init_weight, lambda1, L, step_size, loop, is_sparse, Mode, sigma, lambda2);
time = toc;
fprintf('Time: %f seconds \n', time);
X_Katyusha = [0:3:passes]';
hist4 = [X_Katyusha, hist4];
clear X_Katyusha;

% VR-SGD
algorithm = 'Prox_SVRG';
Mode = 3;
step_size = 1.85 / L;
loop = int64(passes / 3); % 3 passes per loop
fprintf('Algorithm: %s\n', algorithm);
tic;
hist5 = Interface(X, y, algorithm, model, regularizer, init_weight, lambda1, L, step_size, loop, is_sparse, Mode, sigma, lambda2);
time = toc;
fprintf('Time: %f seconds \n', time);
hist5 = [X_SVRG, hist5];
clear X_SVRG;

%% Plot
if(is_plot)
    aa1 = min(hist1(:, 2));
    aa2 = min(hist2(:, 2));
    aa3 = min(hist3(:, 2));
    aa4 = min(hist4(:, 2));
    aa5 = min(hist5(:, 2));
    minval = min([aa1, aa2, aa3, aa4, aa5]) - 2e-16;
    aa = max(max([hist5(:, 2)])) - minval;
    b = 1;

    figure(101)
    set(gcf,'position',[200,100,386,269])
    semilogy(hist1(1:b:end,1), abs(hist1(1:b:end,2) - minval),'b-.^','linewidth',1.6,'markersize',4.5);
    hold on,semilogy(hist2(1:b:end,1), abs(hist2(1:b:end,2) - minval),'g--o','linewidth',1.6,'markersize',4.5);
    hold on,semilogy(hist3(1:b:end,1), abs(hist3(1:b:end,2) - minval),'c-+','linewidth',1.2,'markersize',4.5);
    hold on,semilogy(hist4(1:b:end,1), abs(hist4(1:b:end,2) - minval),'r-d','linewidth',1.2,'markersize',4.5);
    hold on,semilogy(hist5(1:b:end,1), abs(hist5(1:b:end,2) - minval),'k-<','linewidth',1.2,'markersize',4.5);
    hold off
    xlabel('Number of effective passes');
    ylabel('Objective minus best');
    axis([0 passes, 1E-12,aa])
    legend('SAGA', 'SVRG', 'Prox-SVRG', 'Katyusha', 'VR-SGD');
end
