pragma solidity ^0.6.0;

import "./interfaces/IVaultMetaRegistry.sol";
import "openzeppelin-contracts@v3.2.0/access/Ownable.sol";

contract VaultMetaRegistry is IVaultMetaRegistry, Ownable {
    mapping (address => address) public _registry;

    function getMetaProvider(address vault_address) public override view returns (address) {
        return _registry[vault_address];
    }

    function setMetaProvider(address vault_address, address vault_meta) public onlyOwner() {
        _registry[vault_address] = vault_meta;
    }
}