const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Staking", () => {
  let owner;
  let addr1;
  let addr2;
  let addr3;

  let token;
  let TOKEN;
  let totalSupply = ethers.utils.parseUnits("1", 17);
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
    nft.safeTransferFrom(nft.address, addr1, 0, 1000, "");
    nft.safeTransferFrom(nft.address, addr2, 0, 1000, "");
  });

  describe("minting nfts", function () {
    it("should assign the right amount of nfts to the owner of the contract", async function () {
      expect(await nft.balanceOf(owner.address, 0)).to.equal(10 ** 4);
      expect(await nft.balanceOf(owner.address, 1)).to.equal(10 ** 3);

      expect(await nft.balanceOf(owner.address, 2)).to.equal(1);
    });
  });

  describe("staking", function () {
    it("should let users stake nfts", async () => {
      await staking.stakeNFT(0, 1000);
    });
  });
});
