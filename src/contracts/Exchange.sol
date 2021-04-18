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
// [X] Withdraw Ether
// [X] Deposit tokens
// [X] Withdrawal tokens
// [X] Check balances
// [X] Make order
// [X] Cancel order
// [ ] Fill order
// [ ] Charge fees

contract Exchange {
    /********************
    *   VARIABLES       *
    ********************/
    address public feeAccount; // account the recieves exchange fees
    uint256 public feePercent; // fee percentage
    address constant ETHER = address(0); // store Ether in tokens mapping with blank address
    mapping(address => mapping(address => uint256)) public tokens;

    // to know how many orders are inside of order mapping, there is no way to determine size of mapping by itself which is why we need a counter cache -> ordercount.
    uint256 public orderCount; // keep tracks of orders as a counter cache, starts at zero
    
    mapping(uint256 => bool) public orderCancelled;
    mapping(uint256 => bool) public orderFilled;

    // Store the order on blockchain using a mapping
    mapping(uint256 => _Order) public orders; // key is an id of uint256 and the value is an _Order struct with a free orders function allows to read all orders from the mapping


    /********************
    *   EVENTS          *
    ********************/
    event Deposit(address token, address user, uint256 amount, uint256 balance);
    event Withdraw(address token, address user, uint256 amount, uint256 balance);
    event Order(    // This event used outside of SmartContract
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
    );

    event Cancel(    // This event used outside of SmartContract
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
    );

    event Trade(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        address userFill,
        uint256 timestamp        
    );

    /********************
    *   STRUCTS         *
    ********************/
    // Model the order by creating an new type 
    struct _Order { // For internal use only - used inside SmartContract only hence underscore is used to avoid naming conflicts
        uint256 id;
        address user;
        address tokenGet;
        uint256 amountGet;
        address tokenGive;
        uint256 amountGive;
        uint256 timestamp;
    }

    /********************
    *   CONSTRUCTOR     *
    ********************/
    constructor(address _feeAccount, uint256 _feePercent) public {
        feeAccount = _feeAccount;
        feePercent = _feePercent;
    }

    /********************
    *   FUNCTIONS       *
    ********************/
    function() external {   // Fallback function reverts if Ether is sent to this smart contract by mistake
        revert();
    }

    function depositEther() public payable {
        tokens[ETHER][msg.sender] += msg.value;
        emit Deposit(ETHER, msg.sender, msg.value, tokens[ETHER][msg.sender]);
    }

    function withdrawEther(uint256 _amount) public {
        // Check for sufficient balance of sender to send tokens; else stop execution
        require(tokens[ETHER][msg.sender] >= _amount);

        // Subtract the amount of tokens to send from sender
        tokens[ETHER][msg.sender] -= _amount;

        // Send Ether back to original user
        msg.sender.transfer(_amount);

        // Publish event
        emit Withdraw(ETHER, msg.sender, _amount, tokens[ETHER][msg.sender]);
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

    function withdrawToken(address _token, uint256 _amount) public {
        // Ensure this is not an Ether address
        require(_token != ETHER);

        // Make sure there is enough tokens to withdraw
        require(tokens[_token][msg.sender] >= _amount);

        tokens[_token][msg.sender] -= _amount;

        // Require token gets transferred back to user from this SmartContract
        require(Token(_token).transfer(msg.sender, _amount));

        // Publish event
        emit Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);
    }

    function balanceOf(address _token, address _user) public view returns (uint256) {
        return tokens[_token][_user];
    }

    function makeOrder(address _tokenGet, uint256 _amountGet, address _tokenGive, uint256 _amountGive) public {
        // Set order count
        orderCount += 1; 

        // Add newly created orders to orders count and aded to the mapping
        orders[orderCount] = _Order(orderCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, now);

        // Trigger event anytime an order it made
        emit Order(orderCount, msg.sender, _tokenGet, _amountGet, _tokenGive, _amountGive, now);
    }

    function cancelOrder(uint256 _id) public {
        // Fethc order from mapping
        _Order storage _order = orders[_id]; // passing in Id and fetching order out of mapping from storage assign to _order local variable

        // Make sure order user is the same as the person calling this function
        require(address(_order.user) == msg.sender);

        // Ensure it is a valid order, make sure not to cancel an order that does not exist
        require(_order.id == _id);

        orderCancelled[_id] = true; // source of truth that determines whether an order has been canceled or not
        emit Cancel(_order.id, msg.sender, _order.tokenGet, _order.amountGet, _order.tokenGive, _order.amountGive, now);
    }

    function fillOrder(uint256 _id) public {
        // Make sure we are filling in a valid order
        require(_id > 0 && _id <= orderCount);  // Ensure order Id is valid by being greater than zero and less than the total order count 

        // ensure the order is not filled or cancelled already
        require(!orderFilled[_id]);     // require orderFilled is not true
        require(!orderCancelled[_id]);  // require orderCancelled is not true

        // Fetch order from storage
        _Order storage _order = orders[_id]; // passing in Id and fetching order out of mapping from storage assign to _order local variable

        // Call trade helper function to execute the trade
        _trade(_order.id, _order.user, _order.tokenGet, _order.amountGet, _order.tokenGive, _order.amountGive);

        // Mark order as filled
        orderFilled[_order.id] = true;


    }

    /************************
    *   HELPER FUNCTIONS    *
    ************************/
    function _trade(uint256 _orderId, address _user, address _tokenGet, uint256 _amountGet, address _tokenGive, uint256 _amountGive) internal {
        /****************************************************************
        *   Execute trade - swap balances from one account to another   *
        ****************************************************************/

        // Calculate fees
        uint256 _feeAmount = (_amountGive * feePercent) / 100;  // 10 divided by 100 is a percentage - 10% of total.
        
        
        // Charge fees
        // Fee deducted from _amountGet
        tokens[_tokenGet][msg.sender] = (tokens[_tokenGet][msg.sender] - _amountGet) + _feeAmount;  // fetch msg.sender's (user who is filling order) balance and set it to thier balance minus amountGet. msg.sender is person filling the order
        
        // whatever is the tokenGet is for the user we are going to add it to the user's balance. user is person who created order.
        tokens[_tokenGet][_user] = tokens[_tokenGet][_user] + _amountGet;            
        
        // Fees paid by the user that fills the order, which is msg.sender
        tokens[_tokenGet][feeAccount] = tokens[_tokenGet][feeAccount] + _feeAmount;  // Update feeAccount to the _feeAmount, so we can collect the fees. 

        // take user's balance and subtract amountGive
        tokens[_tokenGive][_user] = tokens[_tokenGive][_user] - _amountGive;    

        // add amountGive to the person filling the order.     
        tokens[_tokenGive][msg.sender] = tokens[_tokenGive][msg.sender] + _amountGive; 

        // emit trade event
        emit Trade(_orderId, _user, _tokenGet, _amountGet, _tokenGive, _amountGive, msg.sender, now);
    }
}
