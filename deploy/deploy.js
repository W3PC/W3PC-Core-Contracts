module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const namedAccounts = await getNamedAccounts();
  const { deployer } = namedAccounts;

  const deployAccountResult = await deploy("Account", {
    from: deployer,
    args: [],
  });
  if (deployAccountResult.newlyDeployed) {
    log(
      `contract Account deployed at ${deployAccountResult.address} using ${deployAccountResult.receipt.gasUsed} gas`
    );
  } else {
    log(
      `using pre-existing contract Account at ${deployAccountResult.address}` 
    )
  }
 
  const deployCashierResult = await deploy("Cashier", {
    from: deployer,
    args: ['0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174'], // $USDC contract address on Polygon Mainnet
  });
  if (deployCashierResult.newlyDeployed) {
    log(
      `contract Cashier deployed at ${deployCashierResult.address} using ${deployCashierResult.receipt.gasUsed} gas`
    );
  } else {
    log(
      `using pre-existing contract Cashier at ${deployCashierResult.address}` 
    )
  }

  const deployGameDirectoryResult = await deploy("GameDirectory", {
    from: deployer,
    args: [deployCashierResult.address],
  })

  if (deployGameDirectoryResult.newlyDeployed) {
    log(
      `contract GameDirectory deployed at ${deployGameDirectoryResult.address} using ${deployGameDirectoryResult.receipt.gasUsed} gas`
    );
  } else {
    log(
      `using pre-existing contract GameDirectory at ${deployGameDirectoryResult.address}` 
    )
  }
};
module.exports.tags = [];