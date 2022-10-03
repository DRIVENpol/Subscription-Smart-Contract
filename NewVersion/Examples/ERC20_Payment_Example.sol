// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

// Import the subscription smart contract
import "https://github.com/DRIVENpol/Subscription-Smart-Contract/blob/main/NewVersion/ERC20_payment.sol";


contract Example_SC2 is SubscriptionInErc20 {

  uint256 public c = 0;

  constructor() {
    // Set the address of the token used for payments
    // In this case: BUSD (BSC Mainnet)
    setErc20TokenForPayments(0x55d398326f99059fF775485246999027B3197955);
    
    // We set the fee to 1 BUSD (1 * 10 * 18)
    setErc20Fee(1000000000000000000);

  }

  // We use the "userPaid" modifier and we allow only users with valid subscriptions to call this function
  function increaseC() public userPaid {
      c++;
  }
}
