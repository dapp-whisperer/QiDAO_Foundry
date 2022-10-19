// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.24 <0.9.0;

import "forge-std/Test.sol";
import "../src/erc20Stablecoin/erc20QiStablecoin.sol";
import "../src/QiStablecoin.sol";
import "../src/MyVault.sol";
import "../src/VaultMetaRegistry.sol";
import "../src/mock/EACAggregatorProxyMock.sol";

contract QiSetupTest is Test {
    QiStablecoin public mai;
    VaultNFT public maiNftVault;
    erc20QiStablecoin public vault;
    VaultMetaRegistry public vaultMetaRegistry;
    EACAggregatorProxyMock fakelinkEthUsd;
    
    address constant CHAINLINK_ETH_USD = 0xF9680D99D6C9589e2a93a78A04A279e509205945;
    address constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;

    IERC20 public weth = IERC20(WETH);

    address dev = address(this);

    /*
        address ethPriceSourceAddress,
        uint256 minimumCollateralPercentage,
        string memory name,
        string memory symbol,
        address _mai,
        address _collateral,
        address meta,
        string memory baseURI
    */
    function setUp() public {
        fakelinkEthUsd = new EACAggregatorProxyMock();
        fakelinkEthUsd.publishAnswer(1300e8); // 1000 dollars per ETH

        deal(address(weth), dev, 10000e18);
        _setupMai();
        _setupVault();
        deal(address(mai), address(vault), 10000e18);
    }

    function _initialStateOneUser() internal returns (uint256) {
        uint256 vaultId = vault.createVault();
        console.log(vaultId);
        weth.approve(address(vault), 10000e18);
        vault.depositCollateral(vaultId, 3e18);
        vault.borrowToken(vaultId, 1800e18);
        return vaultId;
    }

    function testDepositBorrow() public {
        uint256 vaultId = vault.createVault();
        console.log(vaultId);
        weth.approve(address(vault), 10000e18);

        _balanceSnapshot(dev);
        _vaultState(vault, vaultId);

        vault.depositCollateral(vaultId, 3e18);
        
        _balanceSnapshot(dev);
        _vaultState(vault, vaultId);

        vault.borrowToken(vaultId, 1000e18);

        _balanceSnapshot(dev);
        _vaultState(vault, vaultId);
    }

    function testWithdrawBurn() public {
        uint256 vaultId = _initialStateOneUser();

        _balanceSnapshot(dev);
        _vaultState(vault, vaultId);

        mai.approve(address(vault), 10000e18);
        vault.payBackToken(vaultId, 500e8);

        _balanceSnapshot(dev);
        _vaultState(vault, vaultId);
    }

    function testPartialLiquidate() public {
        uint256 vaultId = _initialStateOneUser();
        _vaultState(vault, vaultId);
        _userVaultState(vault, vaultId);
        
        //Make CDP Underwater

        fakelinkEthUsd.publishAnswer(500e8);
        _vaultState(vault, vaultId);
        _userVaultState(vault, vaultId);
    
        // Liquidate
    }

    function testPartialLiquidateStabilityPool() public {
        // Test liquidations when only stability pool can cause liquidations
    }

    function _userVaultState(erc20QiStablecoin vault, uint256 vaultId) internal {
        console.log("=== User Vault Health ===", vault.name(), vaultId);
        console.log("vaultCollateral", vault.vaultCollateral(vaultId));
        console.log("vaultDebt", vault.vaultDebt(vaultId));

        console.log("checkCost", vault.checkCost(vaultId));
        console.log("checkExtract", vault.checkExtract(vaultId));
        console.log("checkCollateralPercentage", vault.checkCollateralPercentage(vaultId));
        console.log("checkLiquidation", vault.checkLiquidation(vaultId));
        console.log("");
    }

    function _vaultState(erc20QiStablecoin vault, uint256 vaultId) internal {
        console.log("=== Vault State ===", vault.name(), vaultId);
        console.log("vaultCollateral", vault.vaultCollateral(vaultId));
        console.log("vaultDebt", vault.vaultDebt(vaultId));
        console.log("getDebtCeiling", vault.getDebtCeiling());
        console.log("getEthPriceSource", vault.getEthPriceSource());
        console.log("getTokenPriceSource", vault.getTokenPriceSource());
        console.log("");
    }

    function _balanceSnapshot(address account) internal {
        console.log("=== Balance Check ===", account, block.number);
        console.log("weth:", weth.balanceOf(dev));
        console.log("mai:", mai.balanceOf(dev));
        console.log("");
    }

    function _setupMai() internal {
        maiNftVault = new VaultNFT();

        /*
        -----Decoded View---------------
        Arg [0] : ethPriceSourceAddress (address): 0xab594600376ec9fd91f8e885dadf0ce036862de0
        Arg [1] : minimumCollateralPercentage (uint256): 150
        Arg [2] : name (string): miMATIC
        Arg [3] : symbol (string): miMATIC
        Arg [4] : vaultAddress (address): 0x6af1d9376a7060488558cfb443939ed67bb9b48d
        */
        mai = new QiStablecoin(
            0xAB594600376Ec9fD91F8e885dADF0CE036862dE0,
            150,
            "miMATIC",
            "miMATIC",
            address(maiNftVault)
        );
    }

    function _setupVault() internal {
        vaultMetaRegistry = new VaultMetaRegistry();
        /*
        -----Decoded View---------------
        Arg [0] : ethPriceSourceAddress (address): 0xf9680d99d6c9589e2a93a78a04a279e509205945
        Arg [1] : minimumCollateralPercentage (uint256): 150
        Arg [2] : name (string): WETH MAI Vault
        Arg [3] : symbol (string): WEMVT
        Arg [4] : _mai (address): 0xa3fa99a148fa48d14ed51d610c367c61876997f1
        Arg [5] : _collateral (address): 0x7ceb23fd6bc0add59e62ac25578270cff1b9f619 //WETH
        Arg [6] : meta (address): 0x4920184f60221a75abf39bb0b4d06ac25d9b2bb2
        Arg [7] : baseURI (string): 
        */
        vault = new erc20QiStablecoin(
            address(fakelinkEthUsd),
            150,
            "WETH MAI Vault",
            "WEMVT",
            address(mai),
            address(WETH),
            address(vaultMetaRegistry),
            "https://ipfs.io/ipfs/"
        );        
    }
}
