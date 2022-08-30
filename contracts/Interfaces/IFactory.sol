//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

interface IFactory {

    event FactoryInit(address indexed walletBeacon);
    event ProxyDeployed(address indexed walletProxy, uint256 count);
    event WalletInit(address[] owners, uint256 minApproval, address indexed creator);

    function createWallet(address[] memory _owners, uint256 _minApprovals) external returns(address);

    function getWalletBeacon() external returns(address);

    function allWallets() external returns(address[] memory);

    function walletsCount() external returns(uint256);

    function walletAddress(uint256 id) external returns(address);

    function getOwnerWallets(address owner) external returns(address[] memory);

    function pause() external;

    function unpause() external;

    function isPaused() external returns(bool);
}