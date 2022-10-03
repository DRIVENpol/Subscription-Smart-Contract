// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

// Import the subscription smart contract
import "https://github.com/DRIVENpol/Subscription-Smart-Contract/blob/main/NewVersion/ERC20_And_ETH_Payment.sol";


contract Example_SC is SubscriptionErc20AndEth {

  uint256 public c = 0;

  constructor() {
  }

  // We use the "userPaid" modifier and we allow only users with valid subscriptions to call this function
  function increaseC() public userPaid {
      c++;
  }
}
