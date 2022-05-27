module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const namedAccounts = await getNamedAccounts();
  const { deployer } = namedAccounts;

  // const deployAccountResult = await deploy("Account", {
  //   from: deployer,
  //   args: [],
  // });
  // if (deployAccountResult.newlyDeployed) {
  //   log(
  //     `contract Account deployed at ${deployAccountResult.address} using ${deployAccountResult.receipt.gasUsed} gas`
  //   );
  // } else {
  //   log(
  //     `using pre-existing contract Account at ${deployAccountResult.address}` 
  //   )
  // }
 
  // const deployCashierResult = await deploy("Cashier", {
  //   from: deployer,
  //   args: ['0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e'], // $USDC contract address on Avax Mainnet
  // });
  // if (deployCashierResult.newlyDeployed) {
  //   log(
  //     `contract Cashier deployed at ${deployCashierResult.address} using ${deployCashierResult.receipt.gasUsed} gas`
  //   );
  // } else {
  //   log(
  //     `using pre-existing contract Cashier at ${deployCashierResult.address}` 
  //   )
  // }

  // const deployGameDirectoryResult = await deploy("GameDirectory", {
  //   from: deployer,
  //   args: [deployCashierResult.address],
  // })

  // if (deployGameDirectoryResult.newlyDeployed) {
  //   log(
  //     `contract GameDirectory deployed at ${deployGameDirectoryResult.address} using ${deployGameDirectoryResult.receipt.gasUsed} gas`
  //   );
  // } else {
  //   log(
  //     `using pre-existing contract GameDirectory at ${deployGameDirectoryResult.address}` 
  //   )
  // }

  const deployCreditPoolResult = await deploy("CreditPool", {
    from: deployer,
    args: ["0xB97EF9Ef8734C71904D8002F8b6Bc66Dd9c48a6E"],
  })

  if (deployCreditPoolResult.newlyDeployed) {
    log(
      `contract Game deployed at ${deployCreditPoolResult.address} using ${deployCreditPoolResult.receipt.gasUsed} gas`
    );
  } else {
    log(
      `using pre-existing contract Game at ${deployCreditPoolResult.address}` 
    )
  }

};
module.exports.tags = [];