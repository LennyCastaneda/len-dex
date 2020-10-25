pragma solidity ^0.5.0;

/*
 * Deposit & Withdraw Funds
 * Manage Orders - Make or Cancel
 * Handle Tades - Charge Fees
 */

contract Exchange {
    // Variables
    address public feeAccount; // account the recieves exchange fees

    constructor(address _feeAccount) public {
        feeAccount = _feeAccount;
    }
}

// TODO:
// [ ] Set the fee account
// [ ] Deposit Ether
// [ ] Withdraw Ether
// [ ] Deposit tokens
// [ ] Withdrawal tokens
// [ ] Check balances
// [ ] Make order
// [ ] Cancel order
// [ ] Fill order
// [ ] Charge fees
