// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {ERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";

interface ITokenSwap {
    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external;

    function addLiquidity(
        address tokenA,
        uint256 amountTokenA,
        address tokenB,
        uint256 amountTokenB
    ) external;
}

contract TokenSwapper is ITokenSwap, ERC20 {
    using SafeERC20 for ERC20;
    address private constant UNISWAP_ROUTER =
        0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008; // Uniswap Router on Sepolia
    address private constant UNISWAP_FACTORY =
        0xB7f907f7A9eBC822a80BD25E224be42Ce0A698A0; // Uniswap Factory on Sepolia

    constructor() ERC20("Token Swapper", "TSWP") {}

    function fund() external payable {}

    function createPair(address tokenA, address tokenB) external {
        IUniswapV2Factory(UNISWAP_FACTORY).createPair(tokenA, tokenB);
    }

    function addLiquidity(
        address tokenA,
        uint256 amountTokenA,
        address tokenB,
        uint256 amountTokenB
    ) external {
        IERC20(tokenA).approve(UNISWAP_ROUTER, amountTokenA);
        IERC20(tokenB).approve(UNISWAP_ROUTER, amountTokenB);
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountTokenA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountTokenB);

        // Add liquidity and receive LP tokens
        IUniswapV2Router02(UNISWAP_ROUTER).addLiquidity(
            tokenA,
            tokenB,
            amountTokenA,
            amountTokenB,
            0, // slippage is 0
            0, // slippage is 0
            msg.sender,
            block.timestamp
        );
    }

    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) public {
        IERC20(tokenIn).approve(address(UNISWAP_ROUTER), amountIn); // Approve Uniswap to spend tokens
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn); // Transfer tokens to this contract 

        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        IUniswapV2Router02(UNISWAP_ROUTER).swapExactTokensForTokens(
            amountIn,
            0,
            path,
            msg.sender,
            block.timestamp
        ); // Execute the swap
    }
}
