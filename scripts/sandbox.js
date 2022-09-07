const MrtrSafe = require("../artifacts/contracts/MortarGnosis.sol/MortarGnosis.json");

async function sandbox() {
  const bytes = MrtrSafe.bytecode;
  const abi = MrtrSafe.abi;

  console.log("bytes: ", bytes);
}

sandbox().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
