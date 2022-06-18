//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract QFarmToken is ERC20 {
    using SafeMath for uint256;

    struct Reward{
        uint256 timeLast;
        uint256 rewardNonce;
    }

    address public addrNft;                        // NFT address
    uint256 public constant rewardAmount = 5e18;   // 5 MILK TOKEN
    uint256 public rewardTime = 180;               // 3 min
    uint256 public projectStart = block.timestamp; // Time to calculate rewards.
    uint256 public WEEK = 4233600;                 // 1 week in seconds

    constructor(
        string memory name, 
        string memory symbol,
        address _addrNft
    ) ERC20(symbol, name) {
        require(
            _addrNft != address(0), 
            "QFarmToken: ZERO_ADDRESS"
        );
        addrNft = _addrNft;
    }
    mapping(uint256 => Reward) public rewards;

    function reward(uint256 _tokenId) public {
        Reward memory reward = rewards[_tokenId];
        uint256 rewardToUser = rewardAmount;
        address tokenOwner = IERC721(addrNft).ownerOf(_tokenId);
        require(
            msg.sender == tokenOwner,
            "QFarmToken: ONLY_OWNER"
        );
        if(reward.timeLast == 0){
            _setDataAboutMint(
                _tokenId, 
                block.timestamp,
                reward.rewardNonce.add(1)
            );
        }else{
            rewardToUser = rewardAmount
                .mul(
                    block.timestamp.sub(reward.timeLast)
                )
                .mul(1e18)
                .div(WEEK)
                .div(1e18);
            _setDataAboutMint(
                _tokenId, 
                block.timestamp,
                reward.rewardNonce.add(1)
            );
        }
        _mint(msg.sender, rewardToUser);
    }


    function _setDataAboutMint(
        uint256 _id,
        uint256 _lastTime,
        uint256 _rewardNonce
    ) internal {
        rewards[_id] = Reward({
            timeLast: _lastTime,
            rewardNonce: _rewardNonce
        });
    }
}
