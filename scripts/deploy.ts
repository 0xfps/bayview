import { ethers, network, run } from "hardhat"
import dotenv from "dotenv"
import { existsSync, readFileSync, mkdirSync, writeFileSync, write } from "fs"
import path from "path"
import data from "./config.json"

const BLOCKS = 10
const destinationDir = path.join(__dirname, "/output")
const destination = path.join(__dirname, "/output/deployments.json")
const CHAINS_TO_DEPLOY_ON = ["arbitrum", "base", "optimism"]

if (!existsSync(destinationDir)) {
    mkdirSync(destinationDir)
}

async function deployOracleOnChain(chain: string): Promise<string> {
    const PythOracle = await ethers.getContractFactory("PythOracle")
    // @ts-ignore
    const pythTestnetDeploymentAddress = data[chain].pyth
    const pythOracle = await PythOracle.deploy(pythTestnetDeploymentAddress)
    await pythOracle.deploymentTransaction()?.wait(BLOCKS)
    const pythOracleAddress = await pythOracle.getAddress()

    await run("verify:verify", {
        address: pythOracleAddress,
        constructorArguments: [pythTestnetDeploymentAddress]
    })

    return pythOracleAddress
}

async function deployBCTController({ chain, oracleAddress }: { chain: string, oracleAddress: string }): Promise<string> {
    // @ts-ignore
    const weth = data[chain].weth
    // @ts-ignore
    const nfPositionManager = data[chain].nonFungiblePositionManager

    const BCTController = await ethers.getContractFactory("BayviewContinuousTokenController")
    const bctController = await BCTController.deploy(nfPositionManager, oracleAddress, weth)
    await bctController.deploymentTransaction()?.wait(BLOCKS)
    const bctControllerAddress = await bctController.getAddress()

    await run("verify:verify", {
        address: bctControllerAddress,
        constructorArguments: [nfPositionManager, oracleAddress, weth]
    })

    return bctControllerAddress
}

/**

{
  chain: {
    controller: "",
    oracle: ""
  }
}
 */
function writeToFile({ chain, oracleAddress, bctControllerAddress }: any) {
    const deploymentFileContent = existsSync(destination) ? JSON.parse(readFileSync(destination) as unknown as string) : {}
    const newFileContent = {
        ...deploymentFileContent,
        [chain]: {
            controller: bctControllerAddress,
            oracle: oracleAddress
        }
    }

    writeFileSync(destination, JSON.stringify(newFileContent))
}

(async function deploy() {
    const chain = network.name.toLowerCase()

    if (!CHAINS_TO_DEPLOY_ON.includes(chain)) {
        throw new Error("This chain is not to be deployed on.")
    }

    console.log("##############################################")
    console.log(chain)
    console.log("##############################################")
    console.log("\n")

    const oracleAddress = await deployOracleOnChain(chain)
    const bctControllerAddress = await deployBCTController({ chain, oracleAddress })
    writeToFile({ chain, oracleAddress, bctControllerAddress })

    console.log({
        oracleAddress,
        bctControllerAddress
    })
    console.log("\n")
    console.log("##############################################")
    console.log("Finished")
    console.log("##############################################")
    console.log("\n")
})()

