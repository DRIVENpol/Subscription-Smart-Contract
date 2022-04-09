// SPDX License
//SPDX-License-Identifier: MIT

// Version of solidity
pragma solidity ^0.8.13;

// Imports for mathematical operations
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Imports for ERC20 Payments
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// Initialize the smart contract
contract Subscription {
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Access variable
    address public owner;

    // Action variable
    uint256 public forTesting;

    // ERC20 Object
    // For payments made in ERC20 tokens
    IERC20 public secondaryTokenForPayment;

    // Manage the payment options
    uint256 public paymentOption; // 1 - Eth Payments & 2 - ERC20 Payments

    // Struct for payments
    struct Payment {
        address user; // Who made the payment
        uint256 paymentMoment; // When the last payment was made?
        uint256 paymentExpire; // When the user needs to pay again
    }

    // Array of payments
    Payment[] public payments;

    // Link user to payment
    mapping (address => Payment) public userPayment;

    // Fees
    uint256 public ethFee; // What's the fee in eth
    uint256 public erc20Fee; // What's the fee in Erc20 tokens

    // Analytics
    uint256 public totalPaymentsEth;
    mapping (address => uint256) public userTotalPaymentsEth;

    uint256 public totalPaymentsErc20;
    mapping (address => uint256) public userTotalPaymentsErc20;

    // Constructor
    constructor() {
        owner = msg.sender; // Owner = deployer

        forTesting = 1;

        paymentOption = 1; // Payments in Eth by default

        totalPaymentsEth = 0;
        totalPaymentsErc20 = 0;

        ethFee = 1000000000000000000; // 1 Eth by default
    }

    // Modifier
    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner!");
        _;
    }

    // Check if user paid - modifier
    modifier userPaid {
        require(block.timestamp < userPayment[msg.sender].paymentExpire, "Your payment expired!"); // Time now < time when last payment expire
        _;
    }

    // Allow the smart contract to receive ether
    receive() external payable onlyOwner {
    }

    // Make a payment
    function paySubscription(uint256 _period) public payable { 
        if(paymentOption == 1) {

            require(msg.value == ethFee.mul(_period));
            totalPaymentsEth = totalPaymentsEth.add(msg.value); // Compute total payments in Eth
            userTotalPaymentsEth[msg.sender] = userTotalPaymentsEth[msg.sender].add(msg.value); // Compute user's total payments in Eth

        } else {

             secondaryTokenForPayment.safeTransferFrom(msg.sender, address(this), erc20Fee.mul(_period));
             totalPaymentsErc20 = totalPaymentsErc20.add(erc20Fee.mul(_period)); // Compute total payments in Erc20 tokens
             userTotalPaymentsErc20[msg.sender] = userTotalPaymentsErc20[msg.sender].add(erc20Fee.mul(_period)); // Compute user's total payments in Erc20

        }

        Payment memory newPayment = Payment(msg.sender, block.timestamp, block.timestamp.add(_period.mul(30 days)));
        payments.push(newPayment); // Push the payment in the payments array
        userPayment[msg.sender] = newPayment; // User's last payment
    }

    // Pay in advance
    function payInAdvance(uint256 _period) public payable {
         if(paymentOption == 1) {

            require(msg.value == ethFee.mul(_period));
            totalPaymentsEth = totalPaymentsEth.add(msg.value); // Compute total payments in Eth
            userTotalPaymentsEth[msg.sender] = userTotalPaymentsEth[msg.sender].add(msg.value); // Compute user's total payments in Eth

        } else {

             secondaryTokenForPayment.safeTransferFrom(msg.sender, address(this), erc20Fee.mul(_period));
             totalPaymentsErc20 = totalPaymentsErc20.add(erc20Fee.mul(_period)); // Compute total payments in Erc20 tokens
             userTotalPaymentsErc20[msg.sender] = userTotalPaymentsErc20[msg.sender].add(erc20Fee.mul(_period)); // Compute user's total payments in Erc20

        }

        uint256 newExpirationPeriod = userPayment[msg.sender].paymentExpire.add(_period.mul(30 days));

        Payment memory newPayment = Payment(msg.sender, block.timestamp, newExpirationPeriod);
        payments.push(newPayment); // Push the payment in the payments array
        userPayment[msg.sender] = newPayment; // User's last payment
    }

    // Action for testing
    // Add your function instead
    function doAction() public userPaid {
        forTesting = forTesting.add(1);
    }

    // Setters
    function setEthFee(uint256 _newEthFee) public onlyOwner {
        ethFee = _newEthFee;
    }

    function setErc20Fee(uint256 _newErc20Fee) public onlyOwner {
        erc20Fee = _newErc20Fee;
    }

    function setNewOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function setTokenForPayment(IERC20 _newToken) public onlyOwner {
        secondaryTokenForPayment = _newToken;
    }

    function setPaymentOption(uint256 _paymentOption) public onlyOwner {
        require(_paymentOption == 1 || _paymentOption == 2, "Invalid option!");
        paymentOption = _paymentOption;
    }

    // Getters
    function lastPaymentOfUser(address _user) public view returns(uint256) {
        return userPayment[_user].paymentMoment;
    } 

}
