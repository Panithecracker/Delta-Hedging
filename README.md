# Delta-Hedging
In this project I investigated how the black scholes formula corresponds to the cost of constructing a portfolio using the underlying and financing from a bank which replicates the payoff of the option at maturity, independent of the path realised. This idea blew me away when I first heard it, so I wanted to see by myself how this link arises, in the form of numerical evidence in Matlab, aside from the theoretical derivation that can be found on Shreve II.

# Key assumptions:
The main assumptions of the Black Scholes model for option pricing are :
- The price of a stock is lognormally distributed ($dS/S = \mu dt+\sigma dW)S$ )
- The interest rate $r$ and volatility $\sigma$ are constant
- Trading can be done infinitely often
- Trading is free (no transaction costs)

Despite these key assumptions (all but the third can be dropped) , I find its conclusions remarkable and not at all obvious, giving a systematic and rational framework for a market maker to asses its risk when selling an option and for its overall contribution to the creation of a wide variety of new financial instruments that all participants in the market can use and benefit from.
# Delta Hedging strategy in plain words: 
The theory of Black Scholes suggests the following hedging strategy if we relax the third assumption (and perhaps the most unrealistic one too)  :
0) Sell an option for the price given by the formula plus some extra spread.
1) Reinvest the money from the option (excluding spread) on buying delta shares of stock and borrow[deposit] money using the bank if necessary.
2) Repeat step 1) but with the current earnings of the portfolio before expiry every small amount of time before expiration date.
The goal of this project is to see that this strategy establishes (in practice) an arbitrage opportunity for the writer of the option as the rebalancing frequency is large enough for a fixed nonzero spread.
# Some results:
This first table shows how the accuracy of the replication strategy for two realised paths, where the portfolio is rebalanced 200 times across a trading year (about every 30 hours). The specific parameters used for the simulations are $\sigma = 0.2, \mu = 0, r = 0.05, K = S0 = 100, T = 1$
The results of the strategy speaks for themselves through the pictures:
| <img width="700" height="525" alt="S2" src="https://github.com/user-attachments/assets/5be31613-28a0-4f93-8560-0ac7f3a6ca6f" /> | <img width="700" height="525" alt="C2" src="https://github.com/user-attachments/assets/e3aa21aa-f953-40f6-a9fc-3e0b27b3778f" /> |
|:--:|:--:|
| **S2** | **C2** |

| <img width="700" height="525" alt="S3" src="https://github.com/user-attachments/assets/ddb6b99c-19ce-4eec-9ae4-3d206aa5ede7" /> | <img width="700" height="525" alt="C3" src="https://github.com/user-attachments/assets/bd5c6c1a-4662-461b-9a5f-4b511008ab98" /> |
|:--:|:--:|
| **S3** | **C3** |

Due to the fact that the rebalancing is done finitely often the replication is not 100% exact, although remarkably close in both universes. On the first one, the portfolio has turned out to be worth slightly more than the option payoff while the opposite happens in the second realisation. In general, finite rebalancing leads to an unbiased replication error (mean of 0), whose deviation will converge to 0 as the rebalancing frequency increases.
To examine the range of possibilities, I carried out a Monte Carlo simulation in which I evaluate the outcome of the discrete delta-hedging strategy over 5000 different, randomly generated scenarios of future stock price evolution. The table below summarizes the histograms for the replication error at expiry with two different rebalancing frequencies: the first one every trading day (252 times) and the second one about every 1 hour (5000 times). The mean of both is almost 0 and their deviations are about 44 cents and 1 cents. 

| <img width="700" height="525" alt="H1" src="https://github.com/user-attachments/assets/9c78b2a9-c8e6-4ec4-8225-c220a016a24b" /> | <img width="700" height="525" alt="H2" src="https://github.com/user-attachments/assets/4cc39991-fc57-4d3d-a649-4ccb1498bbcc" /> |
|:--:|:--:|
| **H1** | **H2** |





# Future work:
After learning what the Black Scholes formula accomplishes and seeing it succeed in the numerical exploration of this project, I have thought of the following questions to continue learning:
- Rigorous analysis of the replication error to determine the optimal spread to charge on top of the theoretical price and guarantee no losses with 99% confidence
- Include transaction costs
- Test this with other underlying models (Heston, OU process) where there is usually no closed formula for their price
- Learn about delta-gamma trading
