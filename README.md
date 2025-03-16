# Merkle Airdrop

## Overview

Merkle Airdrop is a project designed to distribute tokens to a large number of recipients efficiently using a Merkle tree. This approach ensures that the distribution is secure, scalable, and cost-effective.

## Features

- **Efficient Distribution**: Uses Merkle trees to minimize the amount of data that needs to be stored and transmitted.
- **Secure**: Ensures that only eligible recipients can claim their tokens.
- **Scalable**: Can handle a large number of recipients without significant performance degradation.

## Installation

To get started with the Merkle Airdrop project, follow these steps:

1. **Clone the repository**:

   ```bash
   git clone https://github.com/royalrock11/merkle-airdrop.git
   cd merkle-airdrop
   ```

2. **Install dependencies**:

   ```bash
   npm install
   ```

3. **Compile the contracts**:
   ```bash
   npx hardhat compile
   ```

## Usage

### Generating the Merkle Tree

To generate the Merkle tree, you need a list of recipients and their corresponding token amounts. Use the provided script to generate the tree:

```bash
see Makefile
```

### Deploying the Contract

Deploy the Merkle Airdrop contract to your desired network:

```bash
see Makefile
```

### Claiming Tokens

Recipients can claim their tokens by providing a proof generated from the Merkle tree:

```javascript
const proof = getMerkleProof(recipientAddress);
await merkleAirdropContract.claimTokens(proof, { from: recipientAddress });
```

## Contributing

We welcome contributions to the Merkle Airdrop project! Please fork the repository and submit pull requests.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For any questions or inquiries, please open an issue or contact us at [x.com].
