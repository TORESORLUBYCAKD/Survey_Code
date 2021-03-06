clear;mex_all;
%load 'real-sim.mat';
load news20.binary.mat;
%load 'kdda.mat';
%load 'rcv1_train.binary.mat';
%load 'rcv1_full.mat'; 
%load 'a9a.mat';
%load 'Covtype.mat';

%% Parse Data
% X = [ones(size(X, 1), 1) X];
[N, Dim] = size(X);
X = X';

%% Normalize Data
% sum1 = 1./sqrt(sum(X.^2, 1));
% if abs(sum1(1) - 1) > 10^(-10)
%     X = X.*repmat(sum1, Dim, 1);
% end
% clear sum1;

%% Set Params
passes = 900;
model = 'least_square'; % least_square / svm / logistic
regularizer = 'L2'; % L1 / L2 / elastic_net
init_weight = repmat(0, Dim, 1); % Initial weight
lambda1 = 10^(-6); % L2_norm / elastic_net
lambda2 = 10^(-7); % L1_norm / elastic_net
L = (max(sum(X.^2, 1)) + lambda1);
sigma = lambda1;
is_sparse = issparse(X);
is_plot = true;
fprintf('Model: %s-%s\n', regularizer, model);

%% Prox_ASVRG
algorithm = 'Prox_ASVRG';
Mode = 2;
thread_no = 1;
step_size = 1 / (2 * L);
loop = int64(passes / 3); % 3 passes per loop
fprintf('Algorithm: %s\n', algorithm);
tic;
hist1 = Interface(X, y, algorithm, model, regularizer, init_weight, lambda1, L, step_size, loop, is_sparse, Mode, sigma, lambda2, thread_no);
time = toc;
fprintf('Time: %f seconds \n', time);
X_SVRG = [0:3:passes]';
hist1 = [X_SVRG, hist1];

%% Prox_ASVRG
% algorithm = 'ASAGA';
% thread_no = 1;
% step_size = 1 / (2 * L);
% loop = int64((passes - 1) * N); % One Extra Pass for initialize SAGA gradient table.
% fprintf('Algorithm: %s\n', algorithm);
% tic;
% hist2 = Interface(X, y, algorithm, model, regularizer, init_weight, lambda1, L, step_size, loop, is_sparse, Mode, sigma, lambda2, thread_no);
% time = toc;
% fprintf('Time: %f seconds \n', time);
% X_SAGA = [0 1 2:3:passes - 2]';
% hist2 = [X_SAGA, hist2];

%% Prox_ASVRG
algorithm = 'Prox_ASVRG';
thread_no = 8;
fprintf('Algorithm: %s\n', algorithm);
tic;
hist3 = Interface(X, y, algorithm, model, regularizer, init_weight, lambda1, L, step_size, loop, is_sparse, Mode, sigma, lambda2, thread_no);
time = toc;
fprintf('Time: %f seconds \n', time);
hist3 = [X_SVRG, hist3];
clear X_SVRG;

%% Plot
if(is_plot)
    aa1 = min(hist1(:, 2));
%     aa2 = min(hist2(:, 2));
    aa3 = min(hist3(:, 2));
    % aa4 = min(hist4(:, 2));
    % aa5 = min(hist5(:, 2));
    % aa6 = min(hist6(:, 2));
    minval = min([aa1, aa3]) - 2e-16;
    aa = max(max([hist1(:, 2)])) - minval;
    b = 1;

    figure(101);
    set(gcf,'position',[200,100,386,269]);
    semilogy(hist1(1:b:end,1), abs(hist1(1:b:end,2) - minval),'m--o','linewidth',1.6,'markersize',4.5);
%     hold on,semilogy(hist2(1:b:end,1), abs(hist2(1:b:end,2) - minval),'k-.^','linewidth',1.6,'markersize',4.5);
    hold on,semilogy(hist3(1:b:end,1), abs(hist3(1:b:end,2) - minval),'r--+','linewidth',1.2,'markersize',4.5);
    % hold on,semilogy(hist4(1:b:end,1), abs(hist4(1:b:end,2) - minval),'b-.d','linewidth',1.2,'markersize',4.5);
    % hold on,semilogy(hist5(1:b:end,1), abs(hist5(1:b:end,2) - minval),'m-.^','linewidth',1.2,'markersize',4.5);
    % hold on,semilogy(hist6(1:b:end,1), abs(hist6(1:b:end,2) - minval),'m--<','linewidth',1.2,'markersize',4.5);
    hold off;
    xlabel('Number of effective passes');
    ylabel('Objective minus best');
    axis([0 passes, 1E-12,aa]);
    legend('Prox-ASVRG1', 'Prox-ASVRG8');
end
