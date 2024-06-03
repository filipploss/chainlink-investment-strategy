# Investment strategy

Sender_Avalanche.sol - sends USDC with CCIP message and calls buyStock() function to buy stocks via Alpaca app.
Receiver_Sepolia.sol - receives USDC through CCIP and calls swapToken() function to swap USDC to selected token through Uniswap V2
Alpaca_Avalanche.sol - buys stocks through Alpaca API
TokenSwapper_Sepolia.sol - swaps tokens on Uniswap V2.
