// contracts/MyVaultNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "openzeppelin-contracts@v3.2.0/token/ERC721/ERC721Burnable.sol";
import "./interfaces/IVaultMetaProvider.sol";
import "./interfaces/IVaultMetaRegistry.sol";


contract VaultNFTv3 is ERC721Burnable {

    address public _meta;
    string public base;

    constructor(string memory name, string memory symbol, address meta, string memory baseURI)
        public
        ERC721(name, symbol)
    {
        _meta = meta;
        base=baseURI;
    }

    function burn(uint256 tokenId) public override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}