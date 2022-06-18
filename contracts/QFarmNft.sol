pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract QFarmNft is 
    ERC721,
    ERC721URIStorage,
    ERC721Enumerable,
    IERC20,
    AccessControlEnumerable
{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    uint256 public tokenCounter;
    uint256 public price;
    address public addrPayToken;
    address public addrWhitelist;

    constructor(
        string memory _name, 
        string memory _symbol,
        address _addrPayToken,
        address _addrWhitelist,
        uint256 _price
    ) ERC721(_symbol, _name) {
        require(_price > 0, "QFarmNft: ZERO_ADDRESS");
        require(
            _addrPayToken != address(0) && _addrWhitelist != address(0)
            "QFarmNft: ZERO_ADDRESS"
        );
        addrPayToken = _addrPayToken;
        addrWhitelist = _addrWhitelist;
        price = _price;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(OPERATOR_ROLE, _msgSender());
    }


    function buyToken(address _amount) external {
        require(_amount == price, "QFarmNft: WRONG_AMOUNT");
        address sender = _msgSender();
        IERC20(addrPayToken).safeTransferFrom(
            sender,
            addrFeeWallet,
            price
        );
        _mint(sender, tokenCounter);
        tokenCounter += 1;
    }

    function mint(address _account) 
        external 
        onlyRole(OPERATOR_ROLE)
    {
        _mint(_account, tokenCounter);
        tokenCounter += 1;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }
}
