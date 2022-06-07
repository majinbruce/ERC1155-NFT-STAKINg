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
        uint256 time;
        bool isStaked;
    }
    // owner => tokenID => item
    mapping(address => mapping(uint256 => StakingItem)) public stakedNFTs;

    event Unstaked(
        address indexed owner,
        uint256 indexed tokenId,
        uint256 indexed amount,
        uint256 time,
        uint256 reward
    );

    event Staked(
        address indexed owner,
        uint256 tokenId,
        uint256 amount,
        uint256 time
    );

    constructor(IERC20 _tokenAddress, IERC1155 _nftAddress) {
        require(
            address(_TokenAddress) != address(0) &&
                address(_nftAddress) != address(0) &&
                "Contract addresses cannot be zero address."
        );
        rewardTokenContract = _TokenAddress;
        nftContract = _nftAddress;
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
        pure
        returns (uint256)
    {
        return (block.timestamp - _timestamp);
    }

    function stakeNFT(uint256 _tokenId, uint256 _amount) external {
        preStakingValidation(_tokenId, _amount);

        currentTime = block.timestamp;

        stakedNFTs[msg.sender][_tokenId] = StakingItem(
            msg.sender,
            _tokenId,
            _amount,
            currentTime,
            true
        );

        // Transfer nft tokens from msg.sender to this staking contract.
        nftsafeTransferFrom(msg.sender, address(this), _id, _amount, "");

        emit Staked(msg.sender, _id, _amount, currentTime);
    }

    function unStakeNFT(uint256 _tokenId, uint256 _amount) external {}
}
