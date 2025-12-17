# Hedging the risks of an option:
In this project I investigated the insight behind the Black-Scholes-Merton formula: if you know the volatility of a stock then you can replicate the payoff of an option by a continuous rebalancing of a portfolio made up of the underlying stock and a risk-free bond. Therefore, to avoid arbitrage, the cost of the option must be that of the replication strategy.
This precise idea blew me away when I first heard of it in class, so I wanted to further explore the link between the price and the associated strategy in action.

As Merton said : "it gave us a prescription for how to produce them (derivatives), and this became an efficient production process... it opened the doors to not just dealing with options but to a whole array of financial innovations like the mortgage market... it has become a mainstay of how the whole industry works including central banks and other government agencies. None of these would work today without these complex computer models and the finance technologies and of course the data we have to collect in order to run them". Check the entire video: https://www.youtube.com/watch?v=3guNFc0Hf6M&t=1650s

# Key assumptions
The main assumptions of the Black-Scholes-Merton model for option pricing are :
- The price of a stock is lognormal or equivalently, $dS = \mu Sdt+\sigma S dW$ 
- Riskfree rate $r$ and volatility $\sigma$ constant 
- Arbitrarily high frequency trading is possible
- No transaction costs nor bid/ask spread

Despite these assumptions , I find its conclusions astonishing as it gives a systematic risk management strategy to limit the risks when selling an option something which has also contributed to the creation of a wide variety of new financial instruments that all participants in the market can use and benefit from. 

In this project, I analyzed the effects of relaxing the third assumption that is: only a finite amount of rebalancing can be done throughout the life of the option.
For this, I performed simulations of the hedging strategy for a European call option and visualized the statistical distribution of the replication error at maturity.
# Option replication :
In the first table I show graphically the accuracy of the replication strategy for two random stock paths, where the portfolio is rebalanced once a day. The specific parameters used for the simulations are $\sigma = 0.2, \mu = 0, r = 0.05, K = S0 = 100, T = 1$. I observed that the replication is not 100% exact, although remarkably close in both instances:
| <img width="700" height="525" alt="S2" src="https://github.com/user-attachments/assets/73a5f99e-390b-41fa-9fa7-2d4e2916dee6"/> | <img width="700" height="525" alt="C2" src="https://github.com/user-attachments/assets/7ff19d16-31a1-4702-8b5f-34117fc9b6ca" /> |
|:--:|:--:|
| **S2** | **C2** |

| <img width="700" height="525" alt="S3" src="https://github.com/user-attachments/assets/80938f56-b609-42a3-b7d3-95f8747e3065" /> | <img width="700" height="525" alt="C3" src="https://github.com/user-attachments/assets/15691a5e-1dec-482b-817f-3341d3f7a4dd" /> |
|:--:|:--:|
| **S3** | **C3** |





On the first path, the stock ends at 119.1 $ paying off 19.1$ to the holder, whereas the portfolio turns out to be worth slightly more (2.29$). However, the opposite happens in the second realisation, where the portfolio ends up being worth slightly less (0.39$). In general, as I observed later, the error is unbiased and its deviation vanishes as the rebalancing frequency increases.
To see these facts, I carried out a Monte Carlo simulation where I perform the strategy over 100000 randomly generated stock trajectories. I did this for two different rebalancing frequencies and obtained the following histograms for the replication error : the first one every trading day (252 times) and the second one about every hour (5000 times). 

| <img width="700" height="525" alt="H1" src="https://github.com/user-attachments/assets/9c78b2a9-c8e6-4ec4-8225-c220a016a24b" /> | <img width="700" height="525" alt="H2" src="https://github.com/user-attachments/assets/4cc39991-fc57-4d3d-a649-4ccb1498bbcc" /> |
|:--:|:--:|
| **H1** | **H2** |

The mean of both is almost 0 and their deviations are about 44 cents and 10 cents.
The GoldmanSachs quantitative strategies research team ![research_notes](risk-non_continuous_hedge.pdf) claimed that that the deviation of the error is approximately proportional to $\frac{\kappa\sigma}{\sqrt{N}}$, where $\kappa$ is the first derivative of the price with respect to volatility. I was able to confirm this result numerically with my code (indeed it holds reasonably well for the above examples where the relative factor should be about 4.45). The main takeaway is that the convergence is pretty slow with respect to the rebalancing amount $N$; quadrupling the rebalances only halves the deviation of the error. Therefore, the convergence rate of discrete hedging is just like that of crude Monte Carlo for the mean estimation, coursed by the factor $1/\sqrt(N)$.  

# Replication portfolio process
By performing discrete rebalancing, we are essentially approximating the theoretical replication portfolio, whose holdings change continuously (an object that is plausible on the mathematical world but we cannot cope with in reality) with one that is rebalanced finitely often (just like we approximating an arbitrary function using a combination of step functions). The reason for the convergence of these discretely rebalanced portfolios is similar to why the euler method converges when solving a classical DE; the error can be bounded by the second derivative of the price with respect to the stock (gamma). The following table shows how the components of the discrete portfolio evolved (stock holdings, cash borrowed/lent at that time) for the second path outlined above. Also, it is accompanied by the $$full$$ hedging error until expiry. Although the value of the error worth considering from a seller perspective is at maturity as it indicates the accuracy of the hedge provided you stayed short until maturity, I thought of an easy improvement on the strategy: if anytime before maturity your portfolio value is enough to buy you the same call then do it. On this way, you instantly hedge your risk from the call you sold and potentially earn more than the fee you charged on top of the BSM price.

![hedge_error](https://github.com/user-attachments/assets/62adaeca-935d-4fb4-9fcb-7184856a8916)



# The Binomial model and its equivalence: 
There is another model which assumes that prices only evolve through a binary tree corresponding to up and down moves for a given set of periods (corresponding to the tree depth). The replication strategy for this model is easy to calculate and it turns out that leads to equivalent conclusions as the BSM model, in some limiting sense and with the right choice of up/down factors. Here I also implemented this model and verified that indeed the associated pricing surface for a large enough period (number of branches of the tree of prices) is almost identical to the BSM one. In addition, this scheme is more versatile for replicating path dependent options and can easily be modified to account for a varying volatility and risk free rate. For the details of this model, one can read more in [BinomialNotes](f400n10.pdf)


<img width="1409" height="638" alt="image" src="https://github.com/user-attachments/assets/0d2fa8ae-eea6-49c4-b738-d67c11b10691" />




# Future work:
After learning what the Black Scholes formula accomplishes and seeing it succeed in the numerical exploration of this project, I have thought of the following follow-up matters on this interesting topic :
- Derive an explicit formula for the hedge error
- Account for transaction costs
- Test against historical data
- Learn how to analyse and derive other hedging strategies like Gamma hedging
- Explore local volatility and stochastic volatility models
- Learn how to model the risk free rate


