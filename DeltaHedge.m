clear all
clc
format long
% option parameters:
T = 1;
K = 10;
r = 0.12;
type = 0;
%stock parameters (GBM):
S0 = 13;
mu = 1;
sigma = 0.5;
%DELTA HEDGING OVER MANY SAMPLES:
hedges = 1;
N = 1008; %hourly trading for a year
t = linspace(0,T,N+1);
S(1) = S0;
dt = T/N;
PnL_writer = zeros(hedges,1); 
PnL_buyer = zeros(hedges,1);

for k=1:hedges
%every dt units of time before expiry, ensure you have delta units of stock
%by borrowing/lending. Let us see if the payoff of the option is the same
%as the portfolio at the end.
option = zeros(N+1,1); %option portfolio history through [0,T]
[call,put]= blsprice(S0,K,r,T,sigma);
if type == 0
    option(1) = call;
else
    option(1) = put;
end
portfolio = zeros(N+1,1); %replicating portfolio history through [0,T]
portfolio(1) = option(1);
dW = sigma*sqrt(dt)*randn(N,1); %precompute wiener increments
for i = 1:N
    %rebalance portfolio using its own wealth (self-financing) N times
    %before expiry.
    S(i+1) = S(i) * exp((mu - 0.5*sigma^2)*dt + dW(i)); %update price path with using exact solution of GBM model
    [dcall,dput] = blsdelta(S(i),K,r,T-t(i),sigma); % buy delta shares at current price and hold them during [t,t+dt)
    [call,put] = blsprice(S(i+1),K,r,T-t(i+1),sigma); %exact option price for next time
    if type == 0
        delta = dcall;
        option(i+1) = call;
    else
        delta = dput;
        option(i+1) = put;
    end
    borrow = delta*S(i)-portfolio(i); %use bank to borrow[deposit] the remaining[extra] cash
    portfolio(i+1) = delta*S(i+1)-exp(r*dt)*borrow; %portfolio value for next time 
end
pnl_approximate_deviation = (sqrt(0.25*pi)*blsvega(S0,K,r,T,sigma)*sigma)/(sqrt(N)); %approx std of error is prop to option vega at start 
spread = max(1,2*pnl_approximate_deviation); %extra fee to charge on top of the theoretical price 
PnL_writer(k) = spread+portfolio(end)-option(end);
PnL_buyer(k) = option(end)-spread-option(1);
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
%     fprintf("Hedging error : %2f\n",PnL_writer(1)-spread); %discrete hedging error (difference of observed option payoff and portfolio value at T)
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


 
if hedges == 1
    %% OPTION SUMMARY AND PAYOFF SUMMARY
    if type == 0
        fprintf("Call option\n");
    else
        fprintf("Put option\n");
    end
  fprintf("Strike: %d$\n",K);
  fprintf("Time to maturity: %d years\n",T); 
  fprintf("Priced at %.2f$\n",option(1)+spread); 
  fprintf("Stock ended at %.2f$\n",S(end));
  fprintf("Buyer Payoff: %.2f$\n",max(S(end)-K,0));
  fprintf("Buyer P&L: %.2f$\n",PnL_buyer(1));
  fprintf("Writer P&L: %.2f$\n",PnL_writer(1));
  fprintf("Replication error: %.2f$\n",PnL_writer(1)-spread);
else
%% statistical summary of writer and buyer P&L
figure 
histogram(PnL_writer, 'Normalization', 'probability')
title("Distribution of P&L (writer)");
xlabel("$");
ylabel("Frequency");
fprintf("WRITER P&L STATS:\n");
fprintf("Mean: %.2f$\n",mean(PnL_writer));
fprintf("Deviation: %.2f$\n",sqrt(var(PnL_writer)));
% fprintf("Estimated: %.2f$\n",pnl_approximate_deviation); %GSachs estimate
fprintf("---------------------\n");
figure 
histogram(PnL_buyer,'Normalization','probability');
title("Distribution of P&L (buyer)");
xlabel("$");
ylabel("Frequency");
fprintf("BUYER P&L STATS:\n");
fprintf("Mean: %.2f$\n",mean(PnL_buyer));
fprintf("Deviation: %.2f$\n",sqrt(var(PnL_buyer)));
fprintf("---------------------\n");
%this is useful to determine spread based on given rebalance frequency N.
%the convergence is like sqrt(h)so pretty slow. If you rebalance four times
%as frequently the deviation of the error is halved.
end

%TESTING WITH REAL OPTION: we will see how the trading goes if we simulate
%it on a real path of the stock, using an approximation of the volatility
%and the risk free rate. Then, lets see how it performs on a particular
%option of our choice. We can then program a simulation which will delta
%hedge as time goes by based on the price seen every dt units of time,
%readjust the portfolio ignoring the transaction costs and at maturity
%data we can evaluate how good our strategy was by comparing the payoff of the option to our portfolio of stock and bonds and then our charged spread. We sold at this price 



%% ALTERNATIVE : BINOMIAL TREES 
u = exp(sigma*sqrt(dt));
d = exp((-1)*sigma*sqrt(dt));
p = (exp(r*dt)-d)/(u-d); 
for k=N:-1:0 %option values at maturity
    if type == 0
        V(k+1) = max(u^k*d^(N-k)*S0-K,0);
    else
        V(k+1) = max(K-u^k*d^(N-k)*S0,0);
    end
end
for i=N:-1:1
    if i == 1 %final iteration, compute delta before losing it:
        D = (V(2)-V(1))/((u-d)*S0);
    end
    for j=1:i
        V(j) = exp(-r*dt)*(p*V(j+1)+(1-p)*V(j));
    end
end
fprintf("Bin price : %.2f$, Initial Delta: %.2f shares\n",V(1)+spread,D);

