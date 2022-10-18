> ⚠️ This code is modified from the QiDAO codebase and designed for a test environment only. Don't use in production.

# QiDAO Foundry
Source code is updated to 0.6.x for compatibility, and deps switched to OZ v3.2.0 from OZ v2.5.0 as part of this.

## Build
Get foundry and then:

`forge build`

## Test
Test on forked Polygon env as we use the token / oracle addresses from there.

`forge test -f https://polygon-rpc.com -vvv`

Recommened using the `-vvv` to see console output.