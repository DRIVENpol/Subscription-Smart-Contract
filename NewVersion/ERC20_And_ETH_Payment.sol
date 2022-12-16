//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IToken {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/**
 * @title Subscription based smart contract
 * @notice Pay a monthly subscription in coins or erc20 tokens
 * @author Socarde Paul-Constantin, DRIVENlabs Inc.
 */

abstract contract SubscriptionErc20AndEth is Ownable {

    /// @dev IToken Object - IERC20
    IToken public erc20Token;

    /// @dev Variables to manage the fee for each type of payment
    uint256 public ethFee; // Fee for ethereum payments
    uint256 public erc20Fee; // Fee for ethereum payments

    /// @dev Variables for analytics
    uint256 public totalPaymentsEth;
    uint256 public totalPaymentsErc20;

    mapping (address => uint256) public userTotalPaymentsEth;
    mapping (address => uint256) public userTotalPaymentsErc20;

    /// @dev Where the fees will be sent
    address public feeCollector;

    /// @dev Struct for payments
    /// @param user Who made the payment
    /// @param paymentMoment When the last payment was made
    /// @param paymentExpire When the user needs to pay again
    struct Erc20Payment {
        address user;
        uint256 paymentMoment;
        uint256 paymentExpire;
    }

    /// @dev Array of erc20 payments
    Erc20Payment[] public erc20Payments;

    /// @dev Link an EOA to an ERC20 payment
    mapping(address => Erc20Payment) public userPaymentErc20;

    /// @dev Struct for payments
    /// @notice Same parameters as the "Erc20Payment" struct
    struct EthPayment {
        address user;
        uint256 paymentMoment;
        uint256 paymentExpire;
    }

    /// @dev Array of Eth payments
    EthPayment[] public ethPayments;

    /// @dev Link an EOA to an Eth payment
    mapping (address => EthPayment) public userPaymentEth;

    /// @dev Events
    event UserPaidErc20(address indexed who, uint256 indexed fee, uint256 indexed period);
    event UserPaidEth(address indexed who, uint256 indexed fee, uint256 indexed period);

    /// @dev We transfer the ownership to a given owner
    constructor() {
        _transferOwnership(_msgSender());
        feeCollector = _msgSender();
    }

    /// @dev Modifier to check if user's subscription is still active
    modifier userPaid() {
        require(block.timestamp < userPaymentEth[msg.sender].paymentExpire || block.timestamp < userPaymentErc20[msg.sender].paymentExpire, "Your payment expired!");
        _;
    }

    /// @dev Modifier to check if the caller is an EOA
    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller can not be another smart contract!");
        _;
    }

    /// @dev Function to pay the subscription
    /// @notice User can chose to pay either in Eth, either in Erc20 Tokens
    /// @param _period For how many months the user wants to pay the subscription
    /// @param _paymentOption 1 - if the user wants to pay in Eth; 2 - if the user wants to pay in Erc20
    function paySubscription(uint256 _period, uint256 _paymentOption) external payable virtual callerIsUser {

        require(_paymentOption == 1 || _paymentOption == 2, "Invalid payment option!"); 

        if(_paymentOption == 1) {
            require(msg.value == ethFee * _period, "Invalid!");

            totalPaymentsEth = totalPaymentsEth + msg.value; // Compute total payments in Eth
            userTotalPaymentsEth[msg.sender] = userTotalPaymentsEth[msg.sender] + msg.value; // Compute user's total payments in Eth

            EthPayment memory newPayment = EthPayment(msg.sender, block.timestamp, block.timestamp + _period * 30 days);
            ethPayments.push(newPayment); // Push the payment in the payments array
            userPaymentEth[msg.sender] = newPayment; // User's last payment

            emit UserPaidEth(msg.sender, ethFee * _period, _period);

        } else if(_paymentOption == 2){

            require(erc20Token.transferFrom(msg.sender, address(this), _period * erc20Fee), "ERC20 Transfer Failed!");

            totalPaymentsErc20 = totalPaymentsErc20 + msg.value; // Compute total payments in Eth
            userTotalPaymentsErc20[msg.sender] = userTotalPaymentsErc20[msg.sender] + msg.value; // Compute user's total payments in Eth

            Erc20Payment memory newPayment = Erc20Payment(msg.sender, block.timestamp, block.timestamp + _period * 30 days);
            erc20Payments.push(newPayment); // Push the payment in the payments array
            userPaymentErc20[msg.sender] = newPayment; // User's last payment

            emit UserPaidErc20(msg.sender, erc20Fee * _period, _period);

        }
    }

    /// @dev Set the monthly Eth fee
    function setEthFee(uint256 _newEthFee) external virtual onlyOwner {
        ethFee = _newEthFee;
    }

    /// @dev Set the monthly Erc20 fee
    function setErc20Fee(uint256 _newErc20Fee) external virtual onlyOwner {
        erc20Fee = _newErc20Fee;
    }

    /// @dev Set the Erc20 token
    function setErc20TokenForPayments(address _newErc20Token) external virtual onlyOwner {
        erc20Token = IToken(_newErc20Token);
    }

    /// @dev Set a new payment collector
    function setNewPaymentCollector(address _feeCollector) external virtual onlyOwner {
        feeCollector = _feeCollector;
    }

    /// @dev Withdraw erc20 tokens
    function withdrawErc20() external virtual onlyOwner {
        require(erc20Token.transferFrom(address(this), feeCollector, erc20Token.balanceOf(address(this))), "ERC20 Transfer Failed!");
    }

    /// @dev Withdraw the Eth balance of the smart contract
    function withdrawEth() external virtual onlyOwner {
        uint256 _amount = address(this).balance;

        (bool sent, ) = feeCollector.call{value: _amount}("");
        require(sent, "Transaction failed!");
    }

    /// @dev Get the last payment of user in Eth
    function lastPaymentOfUserEth(address _user) external view virtual returns(uint256) {
        return userPaymentEth[_user].paymentMoment;
    }

    /// @dev Get the last payment of user in Erc20
    function lastPaymentOfUserErc20(address _user) external view virtual returns(uint256) {
        return userPaymentErc20[_user].paymentMoment;
    }

    function paymentsInSmartContractEth() external view virtual returns(uint256) {
        return address(this).balance;
    }

    /// @dev Get the smart contract's balance of tokens
    function paymentsInSmartContractErc20() external view virtual returns(uint256) {
        return erc20Token.balanceOf(address(this));
    }
}
