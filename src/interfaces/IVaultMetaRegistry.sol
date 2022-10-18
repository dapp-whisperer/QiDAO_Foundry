pragma solidity ^0.6.0;

interface IVaultMetaRegistry {
    function getMetaProvider(address vault_address) external view returns (address);
}