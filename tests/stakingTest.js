const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Staking", () => {
  let owner;
  let addr1;
  let addr2;

  let token;
  let TOKEN;
  let totalSupply = 100000000 * ethers.utils.parseUnits("1", 18);
  let NFT;
  let nft;
  let STAKING;
  let staking;
  let URI = "dummy URI";

  beforeEach(async () => {
    [owner, addr1, addr2, addr3] = await ethers.getSigners();

    // Deploy the Token contract.
    TOKEN = await ethers.getContractFactory("MyToken");
    token = await TOKEN.deploy(totalSupply);
    await token.deployed();

    // Deploy the ERC1155 NFT contract.
    NFT = await ethers.getContractFactory("MyNFT");
    nft = await NFT.deploy(URI);
    await nft.deployed();

    // Deploy the Staking contract.
    STAKING = await ethers.getContractFactory("Staking");
    staking = await STAKING.deploy(token.address, nft.address);
    await staking.deployed();

    await token.transfer(staking.address, totalSupply);

    // Give Staking contract approval for tokens from all accounts.
    await nft.setApprovalForAll(staking.address, true);
    await nft.connect(addr1).setApprovalForAll(staking.address, true);
    await nft.connect(addr2).setApprovalForAll(staking.address, true);

    // transfer 1000 silver nfts to addr1,addr2
    await nft.safeTransferFrom(owner.address, addr1.address, 0, 1000, "0x00");
    await nft.safeTransferFrom(owner.address, addr2.address, 0, 1000, "0x00");

    // stake 1000 nft tokens from addr 1
    await staking.connect(addr1).stakeNFT(0, 1000);
  });

  describe("minting nfts", function () {
    it("should assign the right amount of nfts to the owner of the contract", async function () {
      expect(await nft.balanceOf(owner.address, 0)).to.equal(8000);
      expect(await nft.balanceOf(owner.address, 1)).to.equal(10 ** 3);

      expect(await nft.balanceOf(owner.address, 2)).to.equal(1);
    });
  });

  describe("staking", function () {
    it("should let users stake nfts", async () => {
      // transfer 1000 silver nfts to addr1,addr2
      const _tokenID = 0;
      const _amount = 1000;

      const stakedNft = await staking.stakedNFTs(addr1.address, _tokenID);

      // check if the amount was rightly set in mapping
      expect(await stakedNft.amount).to.equal(_amount);

      //check if transfer of nft was done correctly
      expect(await nft.balanceOf(staking.address, _tokenID)).to.equal(_amount);
      expect(await nft.balanceOf(addr1.address, _tokenID)).to.equal(0);
    });
  });

  describe("unstaking", function () {
    it("should let users unstakestake nfts & receive reward tokens", async () => {
      const _tokenID = 0;
      const _amount = 1000;
      const oneMonthInSeconds = 2629743;
      const balanceBeforeStaking = await token.balanceOf(addr1.address);
      console.log("\n", balanceBeforeStaking, "balanceBeforeStaking");
      // Increase evm time by 2 months.
      await ethers.provider.send("evm_increaseTime", [oneMonthInSeconds * 2]);

      await staking.connect(addr1).unStakeNFT(_tokenID, _amount);

      expect(await token.balanceOf(addr1.address)).to.not.equal(
        balanceBeforeStaking
      );
      console.log(
        "\n",
        await token.balanceOf(addr1.address),
        "balance after staking"
      );
    });
  });
});
