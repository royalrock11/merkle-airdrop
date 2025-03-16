-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 



help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make fund ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install

# Update Dependencies
update:; forge update

build:; forge build

zkbuild :; forge build --zksync

test :; forge test

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

zk-anvil :; npx zksync-cli dev start

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop $(NETWORK_ARGS)

# As of writing, the Alchemy zkSync RPC URL is not working correctly 
deploy-zk:
	forge create src/MerkleAirdrop.sol:MerkleAirdrop --rpc-url http://127.0.0.1:8011 --private-key ${DEFAULT_ZKSYNC_LOCAL_KEY} --constructor-args ${ROOT} $(shell forge create src/BagelToken.sol:BagelToken --rpc-url http://127.0.0.1:8011 --private-key ${DEFAULT_ZKSYNC_LOCAL_KEY} --legacy --zksync | grep "Deployed to:" | awk '{print $$3}') --legacy --zksync

deploy-zk-sepolia:
	forge create src/MerkleAirdrop.sol:MerkleAirdrop --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL} --constructor-args ${ROOT} $(shell forge create src/BagelToken.sol:BagelToken --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL} --account default --legacy --zksync | grep "Deployed to:" | awk '{print $$3}') --account default --legacy --zksync

# Generate Merkle Tree input file
generate :; forge script script/GenerateInput.s.sol:GenerateInput

# Make Merkle Root and Proofs
make :; forge script script/MakeMerkle.s.sol:MakeMerkle

# Generate input and output files 

merkle :; forge script script/GenerateInput.s.sol:GenerateInput && forge script script/MakeMerkle.s.sol:MakeMerkle

zktest :; foundryup-zksync && forge test --zksync && foundryup

sign :; 
	@cast wallet sign --no-hash --private-key $(DEFAULT_ANVIL_KEY) ${shell cast call ${AIRDROP_ADDRESS} "getMessageHash(address,uint256)" ${DEFAULT_ANVIL_ADDRESS} ${AIRDROP_AMOUNT} --rpc-url http://localhost:8545}

claim:;
	@forge script script/Interact.s.sol:ClaimAirdrop --sender ${DEFAULT_ANVIL_ADDRESS_2} --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY_2) --broadcast

balance :; 
	@cast --to-dec ${shell cast call ${TOKEN_ADDRESS} "balanceOf(address)" ${DEFAULT_ANVIL_ADDRESS} --rpc-url http://localhost:8545}

zk-get-message :; cast call ${AIRDROP_ADDRESS} "getMessageHash(address,uint256)" ${DEFAULT_ANVIL_ADDRESS} ${AIRDROP_AMOUNT} --rpc-url http://127.0.0.1:8011

zk-claim :; cast send ${AIRDROP_ADDRESS} "claim(address,uint256,bytes32[],uint8,bytes32,bytes32)" ${DEFAULT_ANVIL_ADDRESS} ${AIRDROP_AMOUNT} "[${PROOF_1},${PROOF_2}]" ${V} ${R} ${S} --private-key ${DEFAULT_ZKSYNC_LOCAL_KEY} --rpc-url http://127.0.0.1:8011

zk-fund :; cast send ${TOKEN_ADDRESS} "mint(address,uint256)" ${DEFAULT_ZKSYNC_ADDRESS} 100000000000000000000 --private-key ${DEFAULT_ZKSYNC_LOCAL_KEY} --rpc-url http://127.0.0.1:8011

zk-transfer :; cast send ${TOKEN_ADDRESS} "transfer(address,uint256)" ${AIRDROP_ADDRESS} 100000000000000000000 --private-key ${DEFAULT_ZKSYNC_LOCAL_KEY} --rpc-url http://127.0.0.1:8011

zk-balance :; cast call ${TOKEN_ADDRESS} "balanceOf(address)" ${DEFAULT_ANVIL_ADDRESS} --rpc-url http://127.0.0.1:8011