//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./Access/OwnableUpgradeable.sol";
import "./Proxy/Initializable.sol";
import "./Proxy/BeaconProxy.sol";
import "./Proxy/UpgradeableBeacon.sol";
import "./Security/PausableUpgradeable.sol";
import "./MortarGnosis.sol";

/**
 *@title Factory
 *@author Sasha Flores
 *@notice initiates a new beacon proxy for each wallet
*/
contract Factory is Initializable, OwnableUpgradeable, PausableUpgradeable {

    address private walletBeacon;
    address[] private walletProxies;
    mapping(address => address[]) internal ownerWallets;
   

    event FactoryInit(address indexed walletBeacon);
    event ProxyDeployed(address indexed walletProxy, uint256 count);
    event WalletInit(address[] owners, uint256 minApproval, address indexed sender);

    function __Factory_init() public virtual initializer {
        UpgradeableBeacon _walletBeacon = new UpgradeableBeacon(address(new MortarGnosis()));
        _walletBeacon.transferOwnership((msg.sender));
        walletBeacon = address(_walletBeacon);

        emit FactoryInit(walletBeacon);
    }

    function createWallet(address[] memory _owners, uint256 _minApprovals) public virtual payable whenNotPaused returns(address) {
        BeaconProxy proxy = new BeaconProxy(
            walletBeacon, 
            abi.encodeWithSelector(
                MortarGnosis(payable(address(0))).__MortarGnosis_init.selector, _owners, _minApprovals)
        );

        emit WalletInit(_owners, _minApprovals, msg.sender);

        address walletProxy = address(proxy);
        uint256 walletCount = walletProxies.length;
        walletProxies.push(walletProxy);

        for(uint256 i = 0; i <_owners.length; i++) {
            address owner = _owners[i];
            ownerWallets[owner].push(walletProxy);      
        }

        emit ProxyDeployed(walletProxy, walletCount);
     
        return walletProxy;
    }

    function getWalletBeacon() external view virtual returns(address) {
        return walletBeacon;
    }

    function allWallets() external view virtual returns(address[] memory) {
        return walletProxies;
    }

    function walletsCount() external view virtual returns(uint256) {
        return walletProxies.length;
    }

    function walletAddress(uint256 id) external view virtual returns(address) {
        return walletProxies[id];
    }

    function getOwnerWallets(address owner) external view returns(address[] memory) {
        return ownerWallets[owner];
    }

    function pause() public virtual onlyOwner {
        _pause();
    }

    function unpause() public virtual onlyOwner {
        _unpause();
    }

    function isPaused() public view returns(bool) {
        return paused();
    }

}