---

Back in April, I wrote an article about how you can create a subscription-based smart contract that allows users to perform actions only if they paid a monthly fee in ERC20 tokens or in blockchain's native tokens. After I got a lot of good feedback about it, I decided to make an upgraded version that can be inherited like Ownable.sol from OpenZeppelin.

---

The source code: https://github.com/DRIVENpol/Subscription-Smart-Contract/tree/main/NewVersion <br/>
Examples: https://github.com/DRIVENpol/Subscription-Smart-Contract/tree/main/NewVersion/Examples

---

OPTION 1: Accept payments in blockchain's native token

<b>Step 1:</b> Import the smart contract directly from my Github

import "https://github.com/DRIVENpol/Subscription-Smart-Contract/blob/main/NewVersion/ETH_payment.sol";


<b>Step 2:</b> Create your smart contract and inherite the imported one
contract Example_SC is SubscriptionInEth {
}


---
READ THE FULL ARTICLE: https://medium.com/@psocarde/subscription-based-smart-contract-update-4605ba8be440
