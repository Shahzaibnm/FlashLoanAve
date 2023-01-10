// contracts/FlashLoan.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import {FlashLoanSimpleReceiverBase} from "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import {IPoolAddressesProvider} from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import {IERC20} from "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";

import './interfaces/IUniswapV2Router02.sol';
import './interfaces/IUniswapV2Factory.sol';

contract FlashLoan is FlashLoanSimpleReceiverBase {
address payable owner;
address immutable Router;

    constructor(address _addressProvider)
        FlashLoanSimpleReceiverBase(IPoolAddressesProvider(_addressProvider))
    {
        owner = payable(msg.sender);
        Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        // 0xf164fC0Ec4E93095b804a4795bBe1e041497b92a
    }

    
    
    address token0;
    address token1;

    uint256 Amount;
    // uint deadline = block.timestamp;

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {

        swap(asset,token1,amount);
        swap(token1,asset,IERC20(token1).balanceOf(address(this)));

        uint256 amountOwed = Amount + premium;
        IERC20(token0).approve(address(POOL), amountOwed);

        return true;
    }

    function swap(address _tokenIn, address _tokenOut, uint256 _amountIn) internal {
      
    // IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
    
    IERC20(_tokenIn).approve(Router, _amountIn);

    address[] memory path;
    if (_tokenIn == IUniswapV2Router01(Router).WETH() || _tokenOut == IUniswapV2Router01(Router).WETH()) {
      path = new address[](2);
      path[0] = _tokenIn;
      path[1] = _tokenOut;
    } else {
      path = new address[](3);
      path[0] = _tokenIn;
      path[1] = IUniswapV2Router01(Router).WETH();
      path[2] = _tokenOut;
    }
        IUniswapV2Router02(Router).swapExactTokensForTokens(_amountIn, 0, path, address(this), block.timestamp+96400);
    }

//     function Swap(address _token0,address _token1,uint256 _amount) internal {
//     address[] memory path= new address[](2);

//         path[0] =_token0;
//         path[1] =_token1;

//             IERC20(_token0).approve(Router, _amount);

//         // require(IUniswapV2Factory(Router).getPair(path[0], path[1]) != address(0)," The pair doesnt exist");
        
//      IUniswapV2Router02(Router).swapExactTokensForTokens(
//         _amount,
//         0,
//         path,
//         address(this),
//         block.timestamp+86400
// );
//     }
    function requestFlashLoan(address _token,address tokenb, uint256 _amount) public {
        address receiverAddress = address(this);
        Amount = _amount;
        bytes memory params = "";
        uint16 referralCode = 0;
        token0 = _token;
        token1 = tokenb;
        POOL.flashLoanSimple(
            receiverAddress,
            token0,
            Amount,
            params,
            referralCode
        );
    }
    function getBalance(address _tokenAddress) external view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }
    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can call this function"
        );
        _;
    }
    receive() external payable {}
}