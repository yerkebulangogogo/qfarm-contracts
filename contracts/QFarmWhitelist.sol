pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interface/IQFarmWhitelist.sol";

contract QFarmWhitelist is IQFarmWhitelist, AccessControlEnumerable{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    bytes32 public override constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    uint256 public override price; 
    uint256 public override addrPayToken;
    uint256 public override addrFeeWallet;

    mapping(address => User) public users;
    mapping(address => User) public farmers;

    constructor(
        address _addrFeeWallet
        address _addrPayToken, 
        uint256 _price
    ){
        require(_price > 0, "QFarmWhitelist: ZERO_AMOUNT");
        require(
            _addrFeeWallet != address(0) && _addrPayToken != address(0), 
            "QFarmWhitelist: ZERO_ADDRESS"
        );
        price = _price;
        addrPayToken = _addrPayToken;
        addrFeeWallet = _addrFeeWallet;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(OPERATOR_ROLE, _msgSender());
    }

    function getUser(address _wallet) 
        external 
        view 
        override
        returns(bool, uint256)
    {
        User memory user = users[_wallet];
        return (user.isWhitelist, user.timeEnd);
    }

    function setPrice(uint256 _price) 
        external 
        override
        onlyRole(OPERATOR_ROLE)
    {
        require(_price > 0, "QFarmWhitelist: ZERO_AMOUNT");
        price = _price
    }

    function addToWhitelist(
        address _to,
        address _farmer, 
        uint256 _amount
    ) external override {
        require(_amount == price, "QFarmWhitelist: WRONG_AMOUNT");
        require(_farmer != address(0), "QFarmWhitelist: ZERO_ADDRESS");
        IERC20(addrPayToken).safeTransferFrom(
            _msgSender(),
            addrFeeWallet,
            price
        );
        uint256 time = block.timestamp.add(365 days);
        users[_to] = User({
            timeEnd: time,
            isWhitelist: true,
            farmer: _farmer
        });
        emit Whitelist(_to, _farmer, time);
    }

    function removeFromWhitelist(address _to, uint256 _amount) 
        external 
        override 
        onlyRole(OPERATOR_ROLE)
    {
        users[_to] = User({
            timeEnd: 0,
            isWhitelist: false
        });
        emit DeWhitelist(_to);
    }
}
