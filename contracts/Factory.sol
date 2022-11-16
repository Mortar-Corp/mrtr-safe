//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./access/OwnableUpgradeable.sol";
import "./proxy/Initializable.sol";
import "./security/PausableUpgradeable.sol";
import "./proxy/BeaconProxy.sol";
import "./proxy/UpgradeableBeacon.sol";
import "./MrtrSafe.sol";
import "./interfaces/IFactory.sol";

/**
 *@title Factory
 *@author Sasha Flores
 *@notice gateway to Mortar's uers to create safe
 * Mortar is the owner who is responsible for upgrade,
 * pause, & unpause of operations, & assigning manager
 * for safes.
 * manager can be responsible for more than one safe.
 * owner can have more than one safe.
 * safe can have more than one owner.
 */
contract Factory is Initializable, OwnableUpgradeable, PausableUpgradeable, IFactory {

    address private safeBeacon;
    address[] private safeProxies;
    mapping(address => address[]) private ownerSafes;
    mapping(address => address[]) private managers;
   


    function __Factory_init() public virtual initializer {
        __Ownable_init();
        __Pausable_init();
        
        UpgradeableBeacon _safeBeacon = new UpgradeableBeacon(address(new MrtrSafe()));
        _safeBeacon.transferOwnership((msg.sender));
        safeBeacon = address(_safeBeacon);

        emit FactoryInit(safeBeacon, msg.sender);
    }

    function createSafe(address[] calldata _owners, uint256 _minApprovals) public virtual override whenNotPaused returns(address) {
        BeaconProxy proxy = new BeaconProxy(
            safeBeacon, 
            abi.encodeWithSelector(
                MrtrSafe(payable(address(0))).__MrtrSafe_init.selector, _owners, _minApprovals)
        );


        address safeProxy = address(proxy);
        uint256 safeCount = safeProxies.length;
        safeProxies.push(safeProxy);

        for(uint256 i = 0; i <_owners.length; i++) {
            address owner = _owners[i];
            ownerSafes[owner].push(safeProxy);      
        }

        emit ProxyDeployed(safeProxy, safeCount);
        emit SafeInit(_owners, _minApprovals, msg.sender);
     
        return safeProxy;
    }

    function getSafeBeacon() external view virtual override returns(address) {
        return safeBeacon;
    }

    function setManager(address safe, address manager) public virtual override onlyOwner whenNotPaused returns(bool) {
        require(manager != address(0), "Factory: non zero address only");
        (bool success, ) = 
        safe.call(abi.encodeWithSignature("setManager(address)", manager));
        require(success, "Factory: assign manager failed");
        managers[manager].push(safe);
        return success;
    }

    function managerSafes(address manager) external view virtual override returns(address[] memory) {
        return managers[manager];
    }

    function managerSafesCount(address manager) external view virtual override returns(uint256) {
        return managers[manager].length;
    }

    function managerSafeId(address manager, uint256 id) external view virtual override returns(address) {
        return managers[manager][id];
    }

    function allSafes() external view virtual override returns(address[] memory) {
        return safeProxies;
    }

    function safesCount() external view virtual override returns(uint256) {
        return safeProxies.length;
    }

    function safeAddress(uint256 id) external view virtual override returns(address) {
        return safeProxies[id];
    }

    function getOwnerSafes(address owner) external view virtual override returns(address[] memory) {
        return ownerSafes[owner];
    }

    function ownerSafesCount(address owner) external view virtual override returns(uint256) {
        return ownerSafes[owner].length;
    }

    function ownerSafeId(address owner, uint256 id) external view virtual override returns(address) {
        return ownerSafes[owner][id];
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