# Delta-Hedging
In this project I investigated how the black scholes formula corresponds to the cost of constructing a portfolio using the underlying and financing from a bank which replicates the payoff of the option at maturity, independent of the path realised. This idea blew me away when I first heard it, so I wanted to see by myself how this link arises, in the form of numerical evidence in Matlab, aside from the theoretical derivation that can be found on Shreve II.

# Key assumptions:
After all, it is a mathematical model aiming to price derivatives using some assumptions :
- The price of a stock is lognormally distributed
- The interest rate and volatility are constant
- Trading can be done infinitely often (continuous trading) and without any costs
Even in a world where these hold, I still found the model conclusions powerful and nontrivial, giving a systematic and rational framework that can be used by a market maker to asses its risk when selling an option and overall help in the creation of a wide variety of new financial products that all participants in the market may benefit from.
# Delta Hedging strategy in plain words: 
0) Sell an option for the price given by the formula plus some extra spread.
1) Reinvest the money from the option (excluding spread) on buying delta shares of stock and borrow[deposit] money using the bank if necessary.
2) Repeat step 1) but with the current earnings of the portfolio before expiry every small amount of time before expiration date.
The goal of this project is to see that this strategy establishes (in practice) an arbitrage opportunity for the writer of the option as the rebalancing frequency is large enough for a fixed nonzero spread.
# Some results:
This first table shows how the accuracy of the replication strategy for two realised paths, where the portfolio is rebalanced 200 times across a trading year (about every 30 hours).
| <img width="700" height="525" alt="S2" src="https://github.com/user-attachments/assets/5be31613-28a0-4f93-8560-0ac7f3a6ca6f" /> | <img width="700" height="525" alt="C2" src="https://github.com/user-attachments/assets/e3aa21aa-f953-40f6-a9fc-3e0b27b3778f" /> |
|:--:|:--:|
| **S2** | **C2** |

| <img width="700" height="525" alt="S3" src="https://github.com/user-attachments/assets/ddb6b99c-19ce-4eec-9ae4-3d206aa5ede7" /> | <img width="700" height="525" alt="C3" src="https://github.com/user-attachments/assets/bd5c6c1a-4662-461b-9a5f-4b511008ab98" /> |
|:--:|:--:|
| **S3** | **C3** |

