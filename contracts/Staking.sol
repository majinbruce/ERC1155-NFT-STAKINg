// SPDX-License-Identifier: UNLISENCED
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

contract Staking is ReentrancyGuard, ERC1155Holder {
    using SafeERC20 for IERC20;
    IERC20 private token;
    IERC1155 private nft;

    uint256 constant oneMonthInSeconds = 2629743;

    struct StakingItem {
        address owner;
        uint256 tokenId;
        uint256 amount;
        uint256 stakingStartTimeStamp;
    }
    // owner => tokenID => item
    mapping(address => mapping(uint256 => StakingItem)) public stakedNFTs;

    event Staked(
        address indexed owner,
        uint256 tokenId,
        uint256 amount,
        uint256 time
    );

    event Unstaked(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 indexed amount,
        uint256 time,
        uint256 reward
    );

    constructor(IERC20 _tokenAddress, IERC1155 _nftAddress) {
        require(
            address(_tokenAddress) != address(0) &&
                address(_nftAddress) != address(0),
            "Contract addresses cannot be zero address."
        );
        token = _tokenAddress;
        nft = _nftAddress;
    }

    function calculateInterestRate(uint256 _stakedTime)
        private
        pure
        returns (uint256)
    {
        if (_stakedTime < oneMonthInSeconds) return 0;
        else if (_stakedTime < oneMonthInSeconds * 6) return 5;
        else if (_stakedTime < oneMonthInSeconds * 12) return 10;
        else return 15;
    }

    function calculateStakedTimeInSeconds(uint256 _timestamp)
        private
        view
        returns (uint256)
    {
        return (block.timestamp - _timestamp);
    }

    function stakeNFT(uint256 _tokenId, uint256 _amount) external {
        require(
            nft.balanceOf(msg.sender, _tokenId) >= _amount,
            "you dont have enough balance"
        );
        require(
            nft.isApprovedForAll(msg.sender, address(this)) == true,
            "this contract is not approved by you to do transactions"
        );
        require(
            _tokenId == 0 || _tokenId == 1 || _tokenId == 2,
            "Nft with this token id does not exist"
        );

        uint256 currentTime = block.timestamp; // current block time stamp in seconds

        //create new nft item
        stakedNFTs[msg.sender][_tokenId] = StakingItem(
            msg.sender,
            _tokenId,
            _amount,
            currentTime
        );

        // Transfer nft tokens from msg.sender to this staking contract.
        nft.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "");

        //emit staked event
        emit Staked(msg.sender, _tokenId, _amount, currentTime);
    }

    function unStakeNFT(uint256 _tokenId, uint256 _amount) external {
        require(stakedNFTs[msg.sender][_tokenId].owner == msg.sender);
        require(
            stakedNFTs[msg.sender][_tokenId].amount <= _amount,
            "you dont have enough staked NFTS"
        );
        require(
            nft.isApprovedForAll(msg.sender, address(this)) == true,
            "this contract is not approved by you to do transactions"
        );

      
        uint256 timestamp = stakedNFTs[msg.sender][_tokenId]
            .stakingStartTimeStamp;

        
        uint256 stakingPeriodTime = calculateStakedTimeInSeconds(timestamp);
        uint256 interestrate = calculateInterestRate(stakingPeriodTime);

        uint256 reward = ((interestrate *
            stakingPeriodTime *
            _amount *
            10**18) / oneMonthInSeconds) *
            12 *
            100;

        //  token.safeTransfer(msg.sender,reward);
        nft.safeTransferFrom(address(this), msg.sender, _tokenId, _amount, "");
        if (reward != 0) {
            token.safeTransfer(msg.sender, amount);
        }
        emit Unstaked(msg.sender, _tokenId, _amount, stakingPeriodTime, reward);
    }
}
