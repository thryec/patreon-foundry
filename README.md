### Deploying with `forge create`:

```
$ forge create --rpc-url $RPC_URL --private-key <your_private_key> /
src/Patreon.sol:Patreon --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

### Deploying with `forge scripts` :

```
forge script script/Patreon.s.sol:PatreonScript --rpc-url $RPC_URL \
 --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

Testnet Deployment: https://kovan-optimistic.etherscan.io/address/0xa848178aedeb9b40fa31ec513d4da14b4c88a0ff
