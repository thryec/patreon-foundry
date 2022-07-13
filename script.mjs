import ethers from "ethers";
import { TESTNET_ADDRESS, CONTRACT_ABI, KOVAN_CHAIN_ID } from "./constants.mjs";

const main = async () => {
  const receiver = "0xA73B9e90258cd779d3341D8f4eA2C793372F502a";
  const startTime = 0;
  const stopTime = 1000;
  const tipValue = new ethers.BigNumber.from("1000000000000000000");
  const privateKey =
    "e8b9b155cbad4b7efe1a1c675305b3f6ed6af9123414e4f3382dddfdc0e94908";

  const provider = new ethers.providers.JsonRpcProvider(
    "https://opt-kovan.g.alchemy.com/v2/Ragjvftvm2NlbK7CPBVFvv5ha3GjjvsL"
  );
  let wallet = new ethers.Wallet(privateKey, provider);

  // console.log("provider: ", provider);
  const signer = await provider.getSigner();

  const contract = new ethers.Contract(TESTNET_ADDRESS, CONTRACT_ABI, provider);
  const contractWithSigner = contract.connect(wallet);
  const profile = await contract.getAllProfiles();
  console.log("profile: ", profile);

  // const tipETH = await contractWithSigner.tipETH(receiver, { value: tipValue });
  // const receipt = await tipETH.wait();
  // console.log("tipETH: ", receipt);

  const blockNumber = await provider.getBlockNumber();
  const timestamp = (await provider.getBlock(blockNumber)).timestamp;
  const endTimeStamp = timestamp + 10000000;

  console.log("timestamps: ", timestamp, endTimeStamp);

  const txn = await contractWithSigner.createETHStream(
    receiver,
    timestamp,
    endTimeStamp,
    {
      value: tipValue,
    }
  );

  const receipt = await txn.wait();
  console.log("create txn: ", receipt);
};

main();
