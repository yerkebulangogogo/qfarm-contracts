pragma solidity 0.8.9;

interface IQFarmWhitelist {

    event Whitelist(address user, address farmer, uint256 time);
    
    event DeWhitelist(address user);

    struct User{
        uint256 timeEnd;
        bool isWhitelist;
        address farmer;
    }

    function OPERATOR_ROLE() external returns(bytes32);

    function price() external returns(uint256);

    function payToken() external returns(address);

    function feeWallet() external returns(address);

    function getUser(address _wallet) 
        external 
        view
        returns(bool, uint256);

    function setPrice(uint256 _price) external;

    function addToWhitelist(
        address _to, 
        address _farmer, 
        uint256 _amount
    ) external;
}
