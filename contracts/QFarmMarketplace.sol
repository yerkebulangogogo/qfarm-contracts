pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./interface/IQFarmWhitelist.sol";

contract QFarmMarketPlace {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;

    event OpenSale(
        address from, 
        address nft, 
        uint256 id, 
        uint256 price
    );
    event CloseSale(address nft, uint256 id);
    event Sold(address to, uint256 saleId);

    bytes32 public override constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    uint256 public override addrPayToken;
    uint256 public override addrFeeWallet;
    uint256 public override counterIds;
    uint256 public override feePrecent;

    struct Sale{
        address owner;
        address nft;
        uint256 id;
        uint256 price;
        uint256 time;
    }

    mapping(uint256 => Sale) public sales;
    mapping(address => EnumerableSet.UintSet) internal saleIds;

    constructor(
        address _addrFeeWallet
        address _addrPayToken,
        uint256 _feePrecent 
    ){
        require(
            _addrFeeWallet != address(0) && _addrPayToken != address(0), 
            "QFarmMarketPlace: ZERO_ADDRESS"
        );
        require(
            _feePrecent > 0 && 50 >= _feePrecent, 
            "QFarmMarketPlace: WRONG_PRECENT"
        );
        addrPayToken = _addrPayToken;
        addrFeeWallet = _addrFeeWallet;
        feePrecent = _feePrecent;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(OPERATOR_ROLE, _msgSender());
    }

    receive() external payable {
        revert("QFarmMarketPlace: ERROR_ETH_TRANSFER");
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function getSaleIdsByAddress(address _walllet) 
        external 
        view 
        override 
        returns(uint256[] memory)
    {
        return saleIds[_wallet];
    }    

    function saleToken(
        address _addrNft
        uint256 _tokenId, 
        uint256 _price
    ) external override{
        address sender = _msgSender();
        require(
            _addrNft != address(0),
            "QFarmMarketPlace: ZERO_ADDRESS"
        );
        IERC721(_addrNft).safeTransferFrom(
            sender, 
            address(this), 
            _tokenId
        );
        sales[counterIds] = Sale({
            owner: sender,
            price: _price,
            time: bloc.timestamp
        })
        saleIds[sender].add(counterIds);
        counterIds = counterIds.add(1);
        emit OpenSale(sender, _addrNft, _tokenId, _price);
    }

    function removeToken(uint256 _saleId, address _to) external override{
        Sale memory sale = sales[_saleId];
        require(
            sale.owner == _msgSender(), 
            "QFarmMarketPlace: ONLY_OWNER"
        );
        sales[_saleId].owner = address(0);
        sales[_saleId].nft = address(0);
        saleIds[address].remove(_saleId);
        IERC721(sale.nft).safeTransferFrom(
            address(this)
            sale.owner,
            sale.id
        );
        emit CloseSale(sale.nft, sale.id);
    }
    
    function buyToken(uint256 _saleId) external override{
        Sale memory sale = sales[_saleId];
        require(
            sale.nft != address(0), 
            "QFarmMarketPlace: NOT_EXIST"
        );
        uint256 fee = sale.price
            .mul(feePrecent)
            .div(1000);
        sales[_saleId].owner = address(0);
        _safeTrasferFrom20(_msgSender(), addrFeeWallet, fee);
        _safeTrasferFrom20(
            _msgSender(), 
            sale.owner, 
            sale.price.sub(fee)
        );
        IERC721(sale.nft).safeTranferFrom(
            address(this),
            _msgSender(),
            sale.id
        );
        sales[_saleId].nft = address(0);
        emit Sold(_msgSender(), _saleId);
    }

    function _safeTrasferFrom20(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        IERC20(token).safeTransferFrom(from, to, amount);
    }
}
