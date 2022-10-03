//SPDX-License-Identifier: MIT

// Version of solidity
pragma solidity ^0.8.10;

// Ownership
import "@openzeppelin/contracts/access/Ownable.sol";

// Imports for ERC20 Payments
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


// Initialize the smart contract
abstract contract SubscriptionErc20AndEth is Ownable {

    // ERC20 Object
    // For payments made in ERC20 tokens
    IERC20 public erc20Token;

    // Who can withdraw the fees
    address public feeColector;

    // Struct for payments
    struct Erc20Payment {
        address user; // Who made the payment
        uint256 paymentMoment; // When the last payment was made
        uint256 paymentExpire; // When the user needs to pay again
    }

    // Array of payments
    Erc20Payment[] public erc20Payments;

    // Link an user to its payment
    mapping ( address => Erc20Payment ) public userPaymentErc20;

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

     // Fees
    uint256 public erc20Fee; // Fee for ethereum payments

    // Analytics
    uint256 public totalPaymentsErc20;
    mapping (address => uint256) public userTotalPaymentsErc20;

    // Events
    event UserPaidErc20(address indexed who, uint256 indexed fee, uint256 indexed period);
    event UserPaidEth(address indexed who, uint256 indexed fee, uint256 indexed period);

    constructor() {
        _transferOwnership(_msgSender());
        feeColector = _msgSender();
    }

    // Check if user paid - modifier
    modifier userPaid() {
        require(block.timestamp < userPaymentEth[msg.sender].paymentExpire || block.timestamp < userPaymentErc20[msg.sender].paymentExpire, "Your payment expired!"); // Time now < time when last payment expire
        _;
    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller can not be another smart contract!");
        _;
    }

    // Make a payment | 1 = eth payment | 2 = erc20 payment
    function paySubscription(uint256 _period, uint256 _paymentOption) public payable virtual callerIsUser {
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
            require(erc20Token.transfer(address(this), _period * erc20Fee));

            totalPaymentsErc20 = totalPaymentsErc20 + msg.value; // Compute total payments in Eth
            userTotalPaymentsErc20[msg.sender] = userTotalPaymentsErc20[msg.sender] + msg.value; // Compute user's total payments in Eth

            Erc20Payment memory newPayment = Erc20Payment(msg.sender, block.timestamp, block.timestamp + _period * 30 days);
            erc20Payments.push(newPayment); // Push the payment in the payments array
            userPaymentErc20[msg.sender] = newPayment; // User's last payment

            emit UserPaidErc20(msg.sender, erc20Fee * _period, _period);
        }
    }

    // Only-owner functions
    function setEthFee(uint256 _newEthFee) public virtual onlyOwner {
        ethFee = _newEthFee;
    }

    function setErc20Fee(uint256 _newErc20Fee) public virtual onlyOwner {
        erc20Fee = _newErc20Fee;
    }

    function setErc20TokenForPayments(address _newErc20Token) public virtual onlyOwner {
        erc20Token = IERC20(_newErc20Token);
    }

    // Getters
    function lastPaymentOfUserErc20(address _user) public view virtual returns(uint256) {
        return userPaymentErc20[_user].paymentMoment;
    }

    function paymentsInSmartContractErc20() public view virtual returns(uint256) {
        return erc20Token.balanceOf(address(this));
    }

    function withdrawErc20() public virtual onlyOwner {
         erc20Token.transfer(feeColector, erc20Token.balanceOf(address(this)));
    }

    function withdrawEth() public virtual onlyOwner {
         payable(feeColector).transfer(address(this).balance);
    }

    // Getters
    function lastPaymentOfUserEth(address _user) public view virtual returns(uint256) {
        return userPaymentEth[_user].paymentMoment;
    }

    function paymentsInSmartContractEth() public view virtual returns(uint256) {
        return address(this).balance;
    }

}
