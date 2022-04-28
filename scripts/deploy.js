// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  // const Greeter = await hre.ethers.getContractFactory("Greeter");
  // const greeter = await Greeter.deploy("Hello, Hardhat!");
  const CBS = await hre.ethers.getContractFactory('CBS')
  const CBR = await hre.ethers.getContractFactory('CBR')
  const cbr = await CBR.deploy()
  await cbr.deployed()
  const cbs = await CBS.deploy()
  await cbs.deployed()
  const Escrow = await hre.ethers.getContractFactory('escrow')
  const escrow = await Escrow.deploy()
  await escrow.deployed();
  const Proxy = await hre.ethers.getContractFactory('UnstructuredProxy')
  const proxy = await  Proxy.deploy()
  await proxy.deployed()
  await proxy.upgradeTo(escrow.address)
  console.log('Implementation Upgraded')
  console.log("CBS deployed to:", cbs.address);
  console.log("CBR deployed to:", cbr.address);
  console.log("Implementation deployed to:", escrow.address);
  console.log("Proxy deployed to:", proxy.address);
  const CBE = await hre.ethers.getContractFactory('CBE')
  const cbe = await CBE.deploy()
  await cbe.deployed()
  console.log('CBE is deployed @ ', cbe.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
