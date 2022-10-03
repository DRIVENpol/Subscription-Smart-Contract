// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

// Import the subscription smart contract
import "https://github.com/DRIVENpol/Subscription-Smart-Contract/blob/main/NewVersion/ETH_payments.sol";


contract Example_SC is SubscriptionInEth {

  uint256 public c = 0;

  constructor() {
    // IMPORTANT!
    // We set the fee to 1 Ether (1 * 10 * 18)
    setEthFee(1000000000000000000);
  }

  // We use the "userPaid" modifier and we allow only users with valid subscriptions to call this function
  function increaseC() public userPaid {
      c++;
  }
}
