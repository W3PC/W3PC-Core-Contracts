//dependencies

require("dotenv").config();
require("hardhat-deploy");

module.exports = {
  solidity: {
    compilers: [
    {
      version: '0.8.11',
      settings: {
        optimizer: {
          enabled: true,
          runs: 9999,
        }
      }
    }]
  },
  defaultNetwork: "hardhat",
  namedAccounts: {
    deployer: {
      default: 0,
      polygonMainnet: '0xca88A4b589bD76361517f20985365DE9c2376139'
    }
  },
  networks: {
    dev: {
      url: "http://0.0.0.0:8545",
    },
    hardhat: {
      accounts: {
        count: 100 
      },
      // forking: {
      //   url: "https://eth-mainnet.alchemyapi.io/v2/tZGJbZSkR3LAZLLaRoYw21uG1j1codpt",
      //   blockNumber: 14143618
      // }
    },
    ropsten: {
      url: "https://ropsten.infura.io/v3/cb3b2911315442f68e6d83936c5b46dd",
      accounts: [process.env.PRIVATE_KEY],
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      accounts: [process.env.PRIVATE_KEY],
    },
    polygonMainnet: {
      url: "https://polygon-mainnet.g.alchemy.com/v2/lP6lP_6hE-DN59hifFzJbMOM8vnZP7-g",
      accounts: [process.env.DEPLOYER_PRIVATE_KEY],
    },
    avalancheMainnet: {
      url: "https://api.avax.network/ext/bc/C/rpc",
      accounts: [process.env.DEPLOYER_PRIVATE_KEY],
    },
  },
  verify: {
    etherscan: {
      // apiUrl: 'https://polygonscan.com',
      // apiKey: 'process.env.POLYGONSCAN_API_KEY',
      // ^ pass this as a flag, for some reason the API KEY is not working. 
        // npx hardhat etherscan-verify --network polygonMainnet --api-key 9E1XCKEXXE2TY8T2CA9GH7AQXKC9EY2GRB

    }
  },
};
