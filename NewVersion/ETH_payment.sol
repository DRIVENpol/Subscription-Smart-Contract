/**

>>> UPDATES

>>> 18 DEC 2022:
        - Add Custom Errors;
        - paySubscription function returns a boolean value so devs can perform actions
          after a user successfully paid the subscription;

 */


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Subscription based smart contract
 * @notice Pay a monthly subscription in Eth
 * @author Socarde Paul-Constantin, DRIVENlabs Inc.
 */

abstract contract SubscriptionInEth is Ownable {

    /// @dev Variables to manage the fee
    uint256 public ethFee;
    
    /// @dev Variables for analytics
    uint256 public totalPaymentsEth;

    mapping (address => EthPayment ) public userPaymentEth;
    mapping (address => uint256) public userTotalPaymentsEth;

    /// @dev Where the fees will be sent
    address public feeCollector;

    /// @dev Struct for payments
    /// @param user Who made the payment
    /// @param paymentMoment When the last payment was made
    /// @param paymentExpire When the user needs to pay again
    struct EthPayment {
        address user; // Who made the payment
        uint256 paymentMoment; // When the last payment was made
        uint256 paymentExpire; // When the user needs to pay again
    }

    /// @dev Array of Eth payments
    EthPayment[] public ethPayments;

    /// @dev Events
    event UserPaidEth(address indexed who, uint256 indexed fee, uint256 indexed period);

    /// @dev Errors
    error NotEOA();
    error FailedEthTransfer();
    error SubscriptionNotPaid();

    /// @dev We transfer the ownership to a given owner
    constructor() {
        _transferOwnership(_msgSender());
        feeCollector = _msgSender();
    }

    /// @dev Modifier to check if user's subscription is still active
    modifier userPaid() {
        if(block.timestamp >= userPaymentEth[msg.sender].paymentExpire) revert SubscriptionNotPaid();
        _;
    }

    /// @dev Function to pay the subscription
    /// @param _period For how many months the user wants to pay the subscription
    function paySubscription(uint256 _period) external payable virtual returns(bool) { 

        if(msg.value != ethFee * _period) revert FailedEthTransfer();

        totalPaymentsEth = totalPaymentsEth + msg.value; // Compute total payments in Eth
        userTotalPaymentsEth[msg.sender] = userTotalPaymentsEth[msg.sender] + msg.value; // Compute user's total payments in Eth

        EthPayment memory newPayment = EthPayment(msg.sender, block.timestamp, block.timestamp + _period * 30 days);
        ethPayments.push(newPayment); // Push the payment in the payments array
        userPaymentEth[msg.sender] = newPayment; // User's last payment

        emit UserPaidEth(msg.sender, ethFee * _period, _period);

        return true;
    }

    /// @dev Set the monthly Eth fee
    function setEthFee(uint256 _newEthFee) external virtual onlyOwner {
        ethFee = _newEthFee;
    }

    /// @dev Set a new payment collector
    function setNewPaymentCollector(address _feeCollector) external virtual onlyOwner {
        feeCollector = _feeCollector;
    }

    /// @dev Withdraw the Eth balance of the smart contract
    function withdrawEth() external virtual onlyOwner {
        uint256 _amount = address(this).balance;

        (bool sent, ) = feeCollector.call{value: _amount}("");
        if(sent == false) revert FailedEthTransfer();
    }

    /// @dev Get the last payment of user in Eth
    function lastPaymentOfUserEth(address _user) external view virtual returns(uint256) {
        return userPaymentEth[_user].paymentMoment;
    }

    function paymentsInSmartContractEth() external view virtual returns(uint256) {
        return address(this).balance;
    }
}
