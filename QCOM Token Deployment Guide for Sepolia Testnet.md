# QCOM Token Deployment Guide for Sepolia Testnet

This guide provides instructions for deploying the QCOM token on the Ethereum Sepolia testnet.

## Prerequisites

1. Node.js and npm installed
2. A wallet with Sepolia ETH for gas fees
3. Basic familiarity with Ethereum and smart contracts

## Project Structure

The token deployment project is organized as follows:

```
token_deployment/
├── contracts/
│   └── QCOMToken.sol       # The QCOM token smart contract
├── scripts/
│   └── deploy.js           # Deployment script for Sepolia
├── .env                    # Environment variables (add your private key here)
├── .env.example            # Example environment file
├── hardhat.config.js       # Hardhat configuration for Sepolia
└── package.json            # Project dependencies
```

## Deployment Instructions

### Step 1: Add Your Private Key

1. Open the `.env` file
2. Add your private key (without the 0x prefix) to the `PRIVATE_KEY` field
3. Ensure your wallet has some Sepolia ETH for gas fees

```
PRIVATE_KEY=your_private_key_here
```

### Step 2: Deploy the Token

Run the following command from the token_deployment directory:

```bash
npx hardhat run scripts/deploy.js --network sepolia
```

This will:
- Deploy the QCOM token to Sepolia testnet
- Use the contract address you specified (0x1770FDD0449E1673e1B18dc0cb6791A4BfFbbAd6)
- Output the deployed contract address
- Attempt to verify the contract on Etherscan (if API key is provided)

### Step 3: Verify Deployment

After deployment, you can verify the token on Sepolia Etherscan:
- Visit https://sepolia.etherscan.io/
- Search for your contract address
- Check that the token details match the expected configuration

## Token Details

- **Name**: QuantumDAO Communication Token
- **Symbol**: QCOM
- **Total Supply**: 1,000,000,000 QCOM
- **Distribution**:
  - Ecosystem Development: 30%
  - Community Treasury: 25%
  - Initial Contributors: 15%
  - Public Sale: 10%
  - Private Sale: 10%
  - Liquidity Provision: 5%
  - Airdrops & Incentives: 5%

## Advanced Configuration

If you want to use a different RPC provider or add Etherscan verification:

1. Update the `.env` file with:
   ```
   SEPOLIA_RPC_URL=your_rpc_url
   ETHERSCAN_API_KEY=your_etherscan_api_key
   ```

2. Run the deployment command again

## Troubleshooting

- **Insufficient funds error**: Ensure your wallet has enough Sepolia ETH
- **Nonce too high error**: Reset your account in Metamask or use a different wallet
- **Contract verification fails**: Double-check your Etherscan API key and try manual verification

## Next Steps After Deployment

1. Test token functionality on Sepolia
2. Prepare for mainnet deployment when ready
3. Set up a multisig wallet for production deployment
4. Implement a token distribution mechanism
