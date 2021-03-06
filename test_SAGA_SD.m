clear; mex_all;
%load 'real-sim.mat';
%load 'rcv1_train.binary.mat';
load 'a9a.mat';
%load 'Covtype.mat';
%% Parse Data
% X = [ones(size(X, 1), 1) X];
[N, Dim] = size(X);
X = full(X');

%% Normalize Data
% sum1 = 1./sqrt(sum(X.^2, 1));
% if abs(sum1(1) - 1) > 10^(-10)
%     X = X.*repmat(sum1, Dim, 1);
% end
% clear sum1;

%% Set Params
passes = 300;
model = 'least_square'; % least_square / svm / logistic
regularizer = 'L2'; % L1 / L2 / elastic_net
init_weight = repmat(0, Dim, 1); % Initial weight
lambda1 = 10^(-7); % L2_norm / elastic_net
lambda2 = 10^(-4); % L1_norm / elastic_net
L = (max(sum(X.^2, 1)) + lambda1); % For logistic regression
sigma = lambda1; 
is_sparse = issparse(X);
Mode = 1;
is_plot = true;
fprintf('Model: %s-%s\n', regularizer, model);

% For SVRG / Prox_SVRG
% Mode 1: last_iter--last_iter  ----Standard SVRG
% Mode 2: aver_iter--aver_iter  ----Standard Prox_SVRG
% Mode 3: aver_iter--last_iter  ----VR-SGD

% SAGA
algorithm = 'SAGA';
loop = int64((passes - 1) * N); % One Extra Pass for initialize SAGA gradient table.
step_size = 2 / (5 * L);
fprintf('Algorithm: %s\n', algorithm);
tic;
hist1 = Interface(X, y, algorithm, model, regularizer, init_weight, lambda1, L, step_size, loop, is_sparse, Mode, sigma, lambda2);
time = toc;
fprintf('Time: %f seconds \n', time);
X_SAGA = [0 1 2:3:passes - 2]';
% X_SGD = [0:1:passes - 1]';
hist1 = [X_SAGA, hist1];
clear X_SAGA;

% Katyusha
% algorithm = 'Katyusha';
% % Fixed step_size
% loop = int64(passes / 3); % 3 passes per loop
% fprintf('Algorithm: %s\n', algorithm);
% tic;
% hist2 = Interface(X, y, algorithm, model, regularizer, init_weight, lambda1, L, step_size, loop, is_sparse, Mode, sigma, lambda2, 0, 0, 0);
% time = toc;
% fprintf('Time: %f seconds \n', time);
% X_Katyusha = [0:3:passes]';
% hist2 = [X_Katyusha, hist2];
% clear X_Katyusha;

% SAGA_SD
algorithm = 'SAGA_SD';
sigma = 1.0 / 2.0; % Momentum Constant
interval = 5000; % Sufficient Decrease Iterate Interval
step_size = 9.6 / (5 * L);
loop = int64(passes / 2); % 3 passes per loop
fprintf('Algorithm: %s\n', algorithm);
% for partial SVD(in dense case)
r = Dim;
A = 0;
tic;
% SVD for dense case
if(~is_sparse)
    [U, S, V] = svds(X', r);
    A = (S * V')';
end
hist3 = Interface(X, y, algorithm, model, regularizer, init_weight, lambda1, L, step_size, loop, is_sparse, Mode, sigma, lambda2, interval, r, A);
time = toc;
fprintf('Time: %f seconds \n', time);
X_SAGA_SD = [0:2:passes]';
hist3 = [X_SAGA_SD, hist3];
clear X_SAGA_SD;

% clear X;
% clear y;
% load 'a9a.mat';
% [N, Dim] = size(X);
% X = full(X');
% is_sparse = issparse(X);
% 
% % SAGA
% algorithm = 'SAGA';
% loop = int64((passes - 1) * N); % One Extra Pass for initialize SAGA gradient table.
% step_size = 2 / (5 * L);
% fprintf('Algorithm: %s\n', algorithm);
% tic;
% hist4 = Interface(X, y, algorithm, model, regularizer, init_weight, lambda1, L, step_size, loop, is_sparse, Mode, sigma, lambda2);
% time = toc;
% fprintf('Time: %f seconds \n', time);
% X_SAGA = [0 1 2:3:passes - 2]';
% % X_SGD = [0:1:passes - 1]';
% hist4 = [X_SAGA, hist4];
% clear X_SAGA;
% 
% % Katyusha
% % algorithm = 'Katyusha';
% % % Fixed step_size
% % loop = int64(passes / 3); % 3 passes per loop
% % fprintf('Algorithm: %s\n', algorithm);
% % tic;
% % hist2 = Interface(X, y, algorithm, model, regularizer, init_weight, lambda1, L, step_size, loop, is_sparse, Mode, sigma, lambda2, 0, 0, 0);
% % time = toc;
% % fprintf('Time: %f seconds \n', time);
% % X_Katyusha = [0:3:passes]';
% % hist2 = [X_Katyusha, hist2];
% % clear X_Katyusha;
% 
% % SAGA_SD
% algorithm = 'SAGA_SD';
% sigma = 1.0 / 2.0; % Momentum Constant
% interval = 2000; % Sufficient Decrease Iterate Interval
% step_size = 2 / (5 * L);
% loop = int64(passes / 2); % 3 passes per loop
% fprintf('Algorithm: %s\n', algorithm);
% % for partial SVD(in dense case)
% r = Dim;
% A = 0;
% tic;
% % SVD for dense case
% if(~is_sparse)
%     [U, S, V] = svds(X', r);
%     A = (S * V')';
% end
% hist5 = Interface(X, y, algorithm, model, regularizer, init_weight, lambda1, L, step_size, loop, is_sparse, Mode, sigma, lambda2, interval, r, A);
% time = toc;
% fprintf('Time: %f seconds \n', time);
% X_SAGA_SD = [0:2:passes]';
% hist5 = [X_SAGA_SD, hist5];
% clear X_SAGA_SD;


%% Plot
if(is_plot)
    aa1 = min(hist1(:, 2));
    % aa2 = min(hist2(:, 2));
    aa3 = min(hist3(:, 2));
%     aa4 = min(hist4(:, 2));
%     aa5 = min(hist5(:, 2));
    minval = min([aa1, aa3]) - 2e-16;
    aa = max(max([hist1(:, 2)])) - minval;
    b = 1;

    figure(101);
    set(gcf,'position',[200,100,386,269]);
    semilogy(hist1(1:b:end,1), abs(hist1(1:b:end,2) - minval),'b--o','linewidth',1.6,'markersize',4.5);
     %hold on,semilogy(hist2(1:b:end,1), abs(hist2(1:b:end,2) - minval),'g-.^','linewidth',1.6,'markersize',4.5);
    hold on,semilogy(hist3(1:b:end,1), abs(hist3(1:b:end,2) - minval),'c--+','linewidth',1.2,'markersize',4.5);
%     hold on,semilogy(hist4(1:b:end,1), abs(hist4(1:b:end,2) - minval),'r-.d','linewidth',1.2,'markersize',4.5);
%     hold on,semilogy(hist5(1:b:end,1), abs(hist5(1:b:end,2) - minval),'k--<','linewidth',1.2,'markersize',4.5);
    hold off;
    xlabel('Number of effective passes');
    ylabel('Objective minus best');
    axis([0 300, 1E-12,aa]);
    legend('SAGA', 'SGD');%, 'SAGAD', 'SAGAD-SD');
end
