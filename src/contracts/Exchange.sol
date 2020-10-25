pragma solidity ^0.5.0;

import "./Token.sol";

/*
 * Deposit & Withdraw Funds
 * Manage Orders - Make or Cancel
 * Handle Tades - Charge Fees
 */

// TODO:
// [X] Set the fee account
// [X] Create Fallback function for accidental deposits
// [X] Deposit Ether
// [ ] Withdraw Ether
// [X] Deposit tokens
// [ ] Withdrawal tokens
// [ ] Check balances
// [ ] Make order
// [ ] Cancel order
// [ ] Fill order
// [ ] Charge fees

contract Exchange {
    // Variables
    address public feeAccount; // account the recieves exchange fees
    uint256 public feePercent; // fee percentage
    address constant ETHER = address(0); // store Ether in tokens mapping with blank address
    mapping(address => mapping(address => uint256)) public tokens;

    // Events
    event Deposit(address token, address user, uint256 amount, uint256 balance);

    constructor(address _feeAccount, uint256 _feePercent) public {
        feeAccount = _feeAccount;
        feePercent = _feePercent;
    }

    // Fallback: reverts if Ether is sent to this smart contract by mistake
    function() external {
        revert();
    }

    function depositEther() public payable {
        tokens[ETHER][msg.sender] += msg.value;
        emit Deposit(ETHER, msg.sender, msg.value, tokens[ETHER][msg.sender]);
    }

    function depositToken(address _token, uint256 _amount) public {
        // Don't allow Ether deposits
        require(_token != ETHER);

        // Send tokens to this contract
        require(Token(_token).transferFrom(msg.sender, address(this), _amount));

        // Manage deposit - update balance
        tokens[_token][msg.sender] += _amount;

        // Emit event
        emit Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]);
    }
}
