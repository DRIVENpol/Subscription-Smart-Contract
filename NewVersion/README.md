---

Back in April, I wrote an article about how you can create a subscription-based smart contract that allows users to perform actions only if they paid a monthly fee in ERC20 tokens or in blockchain's native tokens. After I got a lot of good feedback about it, I decided to make an upgraded version that can be inherited like Ownable.sol from OpenZeppelin.

---

<b>Examples:</b> https://github.com/DRIVENpol/Subscription-Smart-Contract/tree/main/NewVersion/Examples

---

<b>What you need to know</b>

---

https://medium.com/@psocarde/subscription-based-smart-contract-update-4605ba8be440

---

<b>Only-owner functions [Blockchain's native tokens]
  - setEthFee
  - setNewPaymentCollector
  - withdrawEth
  
<b>User functions [Blockchain's native tokens]
  - paySubscription
   
 ---
  
<b>Only-owner functions [ERC20 tokens]
  - setErc20Fee
  - setErc20TokenForPayments
  - setNewPaymentCollector
  - withdrawErc20
  
<b>User functions [ERC20 tokens]
  - paySubscription
  
---

<b>Only-owner functions [Both]
  - setEthFee
  - setNewPaymentCollector
  - withdrawEth
  - setErc20Fee
  - setErc20TokenForPayments
  - setNewPaymentCollector
  - withdrawErc20
  
<b>User functions [Both]
  - paySubscription: there is a _paymentOption variable that can be equal to 1 or 2 (1 = eth payment | 2 = erc20 payment). In this way you allow the user to choose one of two payment options.

---

Did you inherite one of those smart contracts in your project? If yes, let me know!
