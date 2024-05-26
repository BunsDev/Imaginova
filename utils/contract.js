import { ethers } from "ethers";

const Avax = {
  chainId: "43113",
  name: " Avalanche Fuji C-Chain",
  currency: "AVAX",
  explorerUrl: "https://subnets-test.avax.network/c-chain",
  rpcUrl: " https://api.avax-test.network/ext/bc/C/rpc",
};

async function connectToNetwork() {
  if (window.ethereum) {
    try {
      await window.ethereum.request({
        method: "wallet_switchEthereumChain",
        params: [{ chainId: Avax.chainId }],
      });
    } catch (switchError) {
      // This error code indicates that the chain has not been added to MetaMask.
      if (switchError.code === 4902) {
        try {
          await window.ethereum.request({
            method: "wallet_addEthereumChain",
            params: [
              {
                chainId: Avax.chainId,
                chainName: Avax.name,
                nativeCurrency: {
                  name: Avax.currency,
                  symbol: Avax.currency,
                  decimals: 18,
                },
                rpcUrls: [Avax.rpcUrl],
                blockExplorerUrls: [Avax.explorerUrl],
              },
            ],
          });
        } catch (addError) {
          console.error("Failed to add network:", addError);
        }
      } else {
        console.error("Failed to switch network:", switchError);
      }
    }
  } else {
    console.error(
      "Non-Ethereum browser detected. You should consider trying MetaMask!"
    );
  }
}

async function buyToken(
  contractAddress,
  contractABI,
  amount,
  packageType,
  signer
) {
  // Ensure user is connected to the correct network
  await connectToNetwork();

  const contract = new ethers.Contract(contractAddress, contractABI, signer);

  try {
    const value = ethers.utils.parseEther(amount.toString());
    console.log(
      `Attempting to send transaction with value: ${value.toString()}`
    );
    const tx = await contract.purchase(packageType, { value });
    await tx.wait();
    console.log("Transaction successful:", tx);
  } catch (error) {
    console.error("Transaction failed:", error);
  }
}

export { connectToNetwork, buyToken };
