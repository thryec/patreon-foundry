### Deploying with `forge create`:

```
$ forge create --rpc-url $RPC_URL --private-key <your_private_key> /
src/Patreon.sol:Patreon --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

### Deploying with `forge scripts` :

```
forge script script/Patreon.s.sol:PatreonScript --rpc-url $RPC_URL \
 --private-key $PRIVATE_KEY --broadcast
```

Testnet Deployment: https://kovan-optimistic.etherscan.io/address/0xa848178aedeb9b40fa31ec513d4da14b4c88a0ff

### Logs verbosity guide

Level 2 (-vv): Logs emitted during tests are also displayed. That includes assertion errors from tests, showing information such as expected vs actual.
Level 3 (-vvv): Stack traces for failing tests are also displayed.
Level 4 (-vvvv): Stack traces for all tests are displayed, and setup traces for failing tests are displayed.
Level 5 (-vvvvv): Stack traces and setup traces are always displayed.

### sample foundry repositories

https://github.com/yieldprotocol/vault-v2
