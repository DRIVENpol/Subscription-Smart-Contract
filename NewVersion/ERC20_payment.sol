// SPDX-License-Identifier: MIT

// Solidity Version
pragma solidity ^0.8.0;

// Imports for ERC20 Payments
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Ownership
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract SubscriptionInErc20 is Ownable {

    // Who can withdraw the fees
    address public feeColector;
    IERC20 public erc20Token;

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

    // Fees
    uint256 public erc20Fee; // Fee for ethereum payments

    // Analytics
    uint256 public totalPaymentsErc20;
    mapping (address => uint256) public userTotalPaymentsErc20;

    // Events
    event UserPaidErc20(address indexed who, uint256 indexed fee, uint256 indexed period);

    // Constructor
    constructor() {
        _transferOwnership(_msgSender());
        feeColector = _msgSender();
    }

    // Check if user paid - modifier
    modifier userPaid() {
        require(block.timestamp < userPaymentErc20[msg.sender].paymentExpire, "Your subscription expired!"); // Time now < time when last payment expire
        _;
    }

     modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller can not be another smart contract!");
        _;
    }

     // Make a payment
    function paySubscription(uint256 _period) public payable virtual callerIsUser { 
        require(erc20Token.transfer(address(this), _period * erc20Fee));

        totalPaymentsErc20 = totalPaymentsErc20 + msg.value; // Compute total payments in Eth
        userTotalPaymentsErc20[msg.sender] = userTotalPaymentsErc20[msg.sender] + msg.value; // Compute user's total payments in Eth

        Erc20Payment memory newPayment = Erc20Payment(msg.sender, block.timestamp, block.timestamp + _period * 30 days);
        erc20Payments.push(newPayment); // Push the payment in the payments array
        userPaymentErc20[msg.sender] = newPayment; // User's last payment

        emit UserPaidErc20(msg.sender, erc20Fee * _period, _period);
    }

    // Only-owner functions
    function setErc20Fee(uint256 _newErc20Fee) public virtual onlyOwner {
        erc20Fee = _newErc20Fee;
    }

    function setErc20TokenForPayments(address _newErc20Token) public virtual onlyOwner {
        erc20Token = IERC20(_newErc20Token);
    }

    function setNewPaymentCollector(address _feeColector) public virtual onlyOwner {
        feeColector = _feeColector;
    }

    function withdrawErc20() public virtual onlyOwner {
         erc20Token.transfer(feeColector, erc20Token.balanceOf(address(this)));
    }

    // Getter
    function lastPaymentOfUser(address _user) public view virtual returns(uint256) {
        return userPaymentErc20[_user].paymentMoment;
    }

    function paymentsInSmartContract() public view virtual returns(uint256) {
        return erc20Token.balanceOf(address(this));
    }
}
