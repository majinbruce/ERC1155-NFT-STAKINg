# ERC1155-NFT-STAKINg

## Technology Stack & Tools

* Solidity (Writing Smart Contract)

* Javascript (React & Testing)

* Ethers (Blockchain Interaction)

* Hardhat (Development Framework)

#

### Description:-

#### NFT Staking Smart Contract , with ERC 20 reward token & NFT Smart Contract with ERC 1155, with Mint, Burn functionaliy, 

#### Code is split into 3 diffrent smart contracts:-

## MyToken.sol contarct

Custom ERC20 token for staking rewards of nfts.

* Contract deployed on rinkeby test network at:

> 0x81610526b2134d023513F14b9D108326da9E25b4

## ERC115.sol contarct

#### mints NFTs directly to the deployer of the contract </br>

#### 3 types of nfts with supply:- </br>

silver    : 10^4 tokens </br>

gold      : 10^3 tokens </br>

platinum  : 1 token (non-fungible) </br>


* Contract deployed on rinkeby test network at:

> 0x5Af84AbcCFa69958BF215Ff1e181f1Be463Efd6E

## staking.sol contarct

* Users can Stake, Unstake NFT to get reward tokens

| Duration (in months)  | APR |
| ------------- | ------------- |
| 1   | 10% |
| 6  | 15%  |
| 12  | 25%  |
| 12 months onwards  | stable @25%  |

* Contract deployed on rinkeby test network at:

> 0x30d3020aD5C1D0fd3229FCC78344CA3A81a0375B

## Requirements For Initial Setup

* Install NodeJS, should work with any node version below 16.5.0

* Install Hardhat

## Setting Up

1. Clone/Download the Repository </br>

> git clone https://github.com/majinbruce/ERC1155-NFT-STAKINg.git

3. Install Dependencies:

> npm init --yes </br>

> npm install --save-dev hardhat </br>

> npm install dotenv --save </br>

3. Install Plugins:

> npm install --save-dev @nomiclabs/hardhat-ethers ethers @nomiclabs/hardhat-waffle ethereum-waffle chai </br>

> npm install --save-dev @nomiclabs/hardhat-etherscan  </br>

> npm install @openzeppelin/contracts

4. Compile:

> npx hardhat compile

5. Migrate Smart Contracts

> npx hardhat run scripts/deploy.js --network <network-name>

6. Run Tests

> $ npx hardhat test
