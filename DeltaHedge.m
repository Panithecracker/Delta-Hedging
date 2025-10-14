clear all
format long
% option parameters:
T = 1;
K = 100;
r = 0.05;
%stock parameters (GBM):
S0 = 100;
mu = 0;
sigma = 0.2;
%DELTA HEDGING OVER MANY SAMPLES:
hedges = 1;
PnL = zeros(hedges,1); %measure of replication accuracy
for k=1:hedges
N = 252;
t = linspace(0,T,N+1);
S(1) = S0;
dt = T/N;
%every dt units of time before expiry, ensure you have delta units of stock
%by borrowing/lending. Let us see if the payoff of the option is the same
%as the portfolio at the end.
option = zeros(N+1,1); %option portfolio history through [0,T]
option(1) = blsprice(S0,K,r,T,sigma);
portfolio = zeros(N+1,1); %replicating portfolio history through [0,T]
portfolio(1) = option(1);
dW = sigma*sqrt(dt)*randn(N,1); %precompute wiener increments
for i = 1:N
    %rebalance portfolio using its own wealth (self-financing) N times
    %before expiry.
    delta = blsdelta(S(i),K,r,T-t(i),sigma); % buy delta shares at current price and hold them during [t,t+dt)
    borrow = delta*S(i)-portfolio(i); %use bank to borrow[deposit] the remaining[extra] cash
    S(i+1) = S(i) * exp((mu - 0.5*sigma^2)*dt + dW(i)); %update price path with using exact solution of GBM model
    portfolio(i+1) = delta*S(i+1)-exp(r*dt)*borrow; %update the portfolio value after dt units of time 
    option(i+1) = blsprice(S(i+1),K,r,T-t(i+1),sigma); %update option value too
end
spread = 0; %extra fee to charge on top of the theoretical price 
PnL(k) = spread+portfolio(end)-option(end);
if k == 1 %show specific data of first one only   
    %stock path
    plot(t,S,'r');
    xlabel("Time");
    ylabel("Price");
    title("Stock path");
    hold on
    yline(K,'--');
    legend({'stock price','exercise price'});
    %comparison of option and portfolio paths
    figure
    plot(t,option,'b');
    hold on;
    plot(t,portfolio,'g--');
    xlabel("Time");
    ylabel("Price");
    title("Option Replication with Black Scholes");
    legend({'Call option' ,'Portfolio'});
    fprintf("Hedging error : %2f\n",PnL(1)); %discrete hedging error (difference of observed option payoff and portfolio value at T)
end
% %remarkably, as we increase the rebalancing frequency (higher N) then the
% %pnl distribution looks more degenerate at 0, ideally eliminating the risk of losses in the
% limit. Still for finite rebalancing, we could study what spread to add to be 99% confident that
% the error not "eat up" all profits. 
%Future work: 
%Determine the minimal spread to charge
%Use other underlying models (stochastic volatility, OU process)
%Include trading costs 

end
%approximate statistical distribution of the replication error for a finite
%rebalance frequency:
figure 
histogram(PnL, 'Normalization', 'probability')
title("Distribution of Delta Hedging Error");
xlabel("P&L");
ylabel("Frequency");
mean(PnL)
var(PnL)
pnl_approximate_deviation = (sqrt(0.25*pi)*blsvega(S0,K,r,T,sigma)*sigma)/(sqrt(N)); %I found that the approximate deviation of the PnL
%the convergence is like sqrt(h)so pretty slow. If you rebalance four times
%as frequently the deviation of the error is halved.
% 

