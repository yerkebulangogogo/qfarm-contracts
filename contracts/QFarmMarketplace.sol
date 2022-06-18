pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./interface/IQFarmWhitelist.sol";

contract QFarmReward {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    bytes32 public override constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    uint256 public override price; 
    uint256 public override addrPayToken;
    uint256 public override addrFeeWallet;

    mapping(address => User) public users;

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
}
