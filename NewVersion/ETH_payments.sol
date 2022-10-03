// SPDX-License-Identifier: MIT

// Solidity Version
pragma solidity 0.8.10;

// Import IERC20 for ERC20 token manipulation
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Ownership
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract SubscriptionInEth is Ownable {

    // Who can withdraw the fees
    address public feeColector;

    // Struct for payments
    struct EthPayment {
        address user; // Who made the payment
        uint256 paymentMoment; // When the last payment was made
        uint256 paymentExpire; // When the user needs to pay again
    }

    // Array of payments
    EthPayment[] public ethPayments;

    // Link an user to its payment
    mapping ( address => EthPayment ) public userPaymentEth;

    // Fees
    uint256 public ethFee; // Fee for ethereum payments

    // Analytics
    uint256 public totalPaymentsEth;
    mapping (address => uint256) public userTotalPaymentsEth;

    // Constructor
    constructor() {
        _transferOwnership(_msgSender());
        feeColector = _msgSender();
    }

    // Check if user paid - modifier
    modifier userPaid() {
        require(block.timestamp < userPaymentEth[msg.sender].paymentExpire, "Your subscription expired!"); // Time now < time when last payment expire
        _;
    }

     modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller can not be another smart contract!");
        _;
    }

     // Make a payment
    function paySubscription(uint256 _period) public virtual payable callerIsUser { 
        require(msg.value == ethFee * _period, "Invalid!");

        totalPaymentsEth = totalPaymentsEth + msg.value; // Compute total payments in Eth
        userTotalPaymentsEth[msg.sender] = userTotalPaymentsEth[msg.sender] + msg.value; // Compute user's total payments in Eth

        EthPayment memory newPayment = EthPayment(msg.sender, block.timestamp, block.timestamp + _period * 30 days);
        ethPayments.push(newPayment); // Push the payment in the payments array
        userPaymentEth[msg.sender] = newPayment; // User's last payment
    }

    // Only-owner functions
    function setEthFee(uint256 _newEthFee) public virtual onlyOwner {
        ethFee = _newEthFee;
    }

    function setNewPaymentCollector(address _feeColector) public virtual onlyOwner {
        feeColector = _feeColector;
    }

    function withdrawEth() public virtual onlyOwner {
         payable(feeColector).transfer(address(this).balance);
    }

    // Getter
    function lastPaymentOfUser(address _user) public view virtual returns(uint256) {
        return userPaymentEth[_user].paymentMoment;
    }

    function paymentsInSmartContract() public view virtual returns(uint256) {
        return address(this).balance;
    }
}
