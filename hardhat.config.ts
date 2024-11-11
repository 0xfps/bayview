import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-foundry";
import "@nomicfoundation/hardhat-toolbox";
import dotenv from "dotenv"

dotenv.config()
const { PRIVATE_KEY, ARBITRUM_TOKEN, BASE_TOKEN, OPTIMISM_TOKEN, INFURA_ID } = process.env

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.27",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000
      }
    }
  },
  etherscan: {
    apiKey: {
      arbitrumSepolia: ARBITRUM_TOKEN || "",
      baseSepolia: BASE_TOKEN || "",
      optimism: OPTIMISM_TOKEN || ""
    },
    customChains: [{
      network: "optimism",
      chainId: 11155420,
      urls: {
        apiURL: "https://api-sepolia-optimistic.etherscan.io/api",
        browserURL: "https://api-sepolia-optimistic.etherscan.io/api"
      }
    }]
  },
  networks: {
    arbitrum: {
      url: `https://arbitrum-sepolia.infura.io/v3/${INFURA_ID}`,
      chainId: 421614,
      accounts: [PRIVATE_KEY || ""],
      allowUnlimitedContractSize: true,
    },
    base: {
      url: "https://base-sepolia.blockpi.network/v1/rpc/public",
      chainId: 84532,
      accounts: [PRIVATE_KEY || ""],
      allowUnlimitedContractSize: true,
    },
    optimism: {
      url: "https://sepolia.optimism.io",
      chainId: 11155420,
      accounts: [PRIVATE_KEY || ""],
      allowUnlimitedContractSize: true
    }
  }
};

export default config;
