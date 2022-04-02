module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const namedAccounts = await getNamedAccounts();
  const { deployer } = namedAccounts;

  const deployCashierResult = await deploy("Cashier", {
    from: deployer,
    args: [],
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

  const deployGameResult = await deploy("Game", {
    from: deployer,
    args: [deployCashierResult.address],
  })

  if (deployGameResult.newlyDeployed) {
    log(
      `contract Game deployed at ${deployGameResult.address} using ${deployGameResult.receipt.gasUsed} gas`
    );
  } else {
    log(
      `using pre-existing contract Game at ${deployGameResult.address}` 
    )
  }
};
module.exports.tags = [];