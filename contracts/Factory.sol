//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./Access/OwnableUpgradeable.sol";
import "./Proxy/Initializable.sol";
import "./Security/PausableUpgradeable.sol";
import "./Proxy/BeaconProxy.sol";
import "./Proxy/UpgradeableBeacon.sol";
import "./MrtrSafe.sol";
import "./Interfaces/IFactory.sol";


contract Factory is Initializable, OwnableUpgradeable, PausableUpgradeable, IFactory {

    address private walletBeacon;
    address[] private walletProxies;
    mapping(address => address[]) internal ownerWallets;
   


    function __Factory_init() public virtual initializer {
        __Ownable_init();
        __Pausable_init();
        
        UpgradeableBeacon _walletBeacon = new UpgradeableBeacon(address(new MrtrSafe()));
        _walletBeacon.transferOwnership((msg.sender));
        walletBeacon = address(_walletBeacon);

        emit FactoryInit(walletBeacon);
    }

    function createWallet(address[] memory _owners, uint256 _minApprovals) public virtual override whenNotPaused returns(address) {
        BeaconProxy proxy = new BeaconProxy(
            walletBeacon, 
            abi.encodeWithSelector(
                MrtrSafe(payable(address(0))).__MrtrSafe_init.selector, _owners, _minApprovals)
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

    function getWalletBeacon() external view virtual override returns(address) {
        return walletBeacon;
    }

    function allWallets() external view virtual override returns(address[] memory) {
        return walletProxies;
    }

    function walletsCount() external view virtual override returns(uint256) {
        return walletProxies.length;
    }

    function walletAddress(uint256 id) external view virtual override returns(address) {
        return walletProxies[id];
    }

    function getOwnerWallets(address owner) external view virtual override returns(address[] memory) {
        return ownerWallets[owner];
    }

    function pause() public virtual override onlyOwner {
        _pause();
    }

    function unpause() public virtual override onlyOwner {
        _unpause();
    }

    function isPaused() public view virtual override returns(bool) {
        return paused();
    }

}