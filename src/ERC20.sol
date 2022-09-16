// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./EIP712.sol";

contract ERC20 is EIP712 {
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    bool private _pause;
    address private _owner;

    mapping(address => uint256) private _balanceOf;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256 ) _nonce;



    bytes32 private constant _PERMIT_HASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    string private constant _VERSION = "V1";

    constructor(string memory name_,string memory symbol_) EIP712(name_,_VERSION) {
        _name = name_;
        _symbol = symbol_;
        _owner = msg.sender;
        _pause = false;

        _mint(msg.sender, 100 * (10**decimal()));
    }

    modifier check_address(address to_) {
        require(to_ != address(0),"To is address(0)");
        _;
    }

    modifier check_pause() {
        require(_pause == false , "Pasue!");
        _;
    }


    function nonces(address addr_) public view returns(uint256) {
        return _nonce[addr_];
    }
    function pause() external{
        require(msg.sender == _owner,"you are not owner!!");
        _pause = true;
    }

    function approve(address to_,uint256 amount_)public  {
        require(msg.sender == _owner,"You arent owner");
        _approve(msg.sender,to_,amount_);

    }

    function allowance(address from_,address to_) external view returns(uint256) {
        return _allowances[from_][to_];
    }

    function transfer(address to_, uint256 amount_) external check_address(to_) check_pause(){
        
        require(_balanceOf[msg.sender] >= amount_,"transfer amount exceeds balance");

        unchecked {
            _balanceOf[msg.sender] -= amount_;
            _balanceOf[to_] += amount_;
        }
    }

    function transferFrom(address from_,address to_, uint256 amount_) external check_address(to_) check_pause() {
        require(from_ != address(0),"from is address(0)");
        require(_balanceOf[from_] >= amount_,"transfer amount exceeds balance");
        require(_allowances[from_][msg.sender] > 0 ,"Check allowance");


        _allowances[from_][msg.sender] -= amount_;
        unchecked{
            _balanceOf[from_] -= amount_;
            _balanceOf[to_] += amount_;
        }    
    }


    function permit(address owner_, address spender_,uint256 value_, uint256 deadline_, uint8 v, bytes32 r, bytes32 s) external {
        require(block.timestamp <= deadline_, "expired");

        uint256  current_nonce = _nonce[owner_];
        ++_nonce[owner_];
        

        bytes32 structHash = keccak256(abi.encode(_PERMIT_HASH,owner_,spender_,value_,current_nonce,deadline_));

        bytes32 hash = _toTypedDataHash(structHash);

        address signer = ecrecover(hash,v,r,s);
        require(signer == owner_ , "INVALID_SIGNER");

        _approve(owner_,spender_,value_);
    }

    function decimal() public pure returns(uint256) {
        return 18;
    }



    function _approve(address from_ , address to_ , uint256 amount_) private check_address(to_) check_pause(){
        require(from_ != address(0),"from_ is address(0)");
        _allowances[from_][to_] += amount_;
    }


    function _mint(address to_, uint256 amount_) private check_address(to_){

        _totalSupply += amount_;
        unchecked {
            _balanceOf[to_] += amount_;
        }
        
    }

}