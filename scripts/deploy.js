const { ethers } = require("hardhat");

async function main() {
  const totalSupply = ethers.utils.parseUnits("1", 8);
  const TOKEN = await ethers.getContractFactory("MyToken");
  const token = await TOKEN.deploy(totalSupply);
  await token.deployed();

  console.log("\n token deployed at", token.address);

  const uri = "sample uri";
  const NFT = await ethers.getContractFactory("MyNFT");
  const nft = await NFT.deploy(uri);
  await nft.deployed();

  console.log("\n nft deployed at", nft.address);

  const STAKING = await ethers.getContractFactory("staking");
  const staking = await STAKING.deploy(token.address, nft.address);
  await staking.deployed();

  console.log("\n STAKING deployed at", staking.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
