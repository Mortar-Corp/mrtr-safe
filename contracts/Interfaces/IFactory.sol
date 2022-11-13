//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface IFactory {

    event FactoryInit(address indexed safeBeacon, address indexed upgrader);
    event ProxyDeployed(address indexed safeProxy, uint256 count);
    event SafeInit(address[] owners, uint256 minApproval, address indexed creator);

    function createSafe(address[] memory _owners, uint256 _minApprovals) external returns(address);

    function getSafeBeacon() external view returns(address);

    function setManager(address safe, address manager) external returns(bool);

    function managerSafes(address manager) external view returns(address[] memory);

    function managerSafesCount(address manager) external view returns(uint256);

    function managerSafeId(address manager, uint256 id) external view returns(address);

    function allSafes() external view returns(address[] memory);

    function safesCount() external view returns(uint256);

    function safeAddress(uint256 id) external view returns(address);

    function getOwnerSafes(address owner) external returns(address[] memory);

    function ownerSafesCount(address owner) external view returns(uint256);

    function ownerSafeId(address owner, uint256 id) external view returns(address);

    function pause() external;

    function unpause() external;

    function isPaused() external view returns(bool);
}