//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./Proxy/Initializable.sol";
import "./Utils/ContextUpgradeable.sol";

/** 
 *@title Owners
 *@author Sasha Flores
 *@notice let owners add & remove other owners, and 
 * set min approval needed to execute or revoke transactions. 
 */
abstract contract Owners is Initializable, ContextUpgradeable {


    uint256 internal ownersCount;
    uint256 internal minApproval;
    address[] internal owners;
    mapping(address => bool) private isOwner;

    
    event OwnerAdded(address newOwner);
    event OwnerRemoved(address removedOwner);
    event ApprovalsChanged(uint256 minApproval);

    modifier onlyOwners() {
        for(uint256 i = 0; i < ownersCount; i++) {
            if(owners[i] == _msgSender()) {
                isOwner[msg.sender] = true;
            }
        }
        require(isOwner[msg.sender] == true, "Owners: owners only");
        _;
    }

    /**
     *@dev initialize owners contract
     *@param _owners address, list of `_owners`
     *@param _minApproval uint, min approval needed 
     * Requirements:
     * `owner` is a non zero address, & do not exists before.
     * `_owners` length is greater than zero
     * `minApproval` is greater than zero, less than, or equal to `_owners`
     */
    function __Owners_init(address[] memory _owners, uint256 _minApproval) internal onlyInitializing {
        for(uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Owners: no zero address allowed");
            require(isOwner[owner] == false, "Owners: address duplicate");
            
            owners.push(owner);
            isOwner[owner] = true;
        }
        require(_owners.length > 0, "Owners: no owner yet");
        require(
            _minApproval > 0 && _minApproval <= _owners.length, 
            "Owners: approvals greater than zero & equal or less than owners"
        );

        minApproval = _minApproval;
        ownersCount = owners.length;
    }

    //@dev returns owners' addresses
    function getOwners() public view returns(address[] memory) {
        return owners;
    }
    //@dev check if `owner` exists
    function ownerExists(address owner) public view returns(bool) {
        return isOwner[owner];
    }
    //@dev returns min approvals
    function getMinApproval() public view returns(uint256) {
        return minApproval;
    }
    //@dev returns total count of owners
    function getOwnersCount() public view returns(uint256) {
        return ownersCount;
    }

    /**
     *@dev allow owners to add `newOwner` & change `minApproval`
     *@param newOwner address, `newOwner` address
     *@param _minApproval uint, sets `minApproval`
     * Requirements:
     * `newOwner` is non zero address, & does not exist
     * function caller is one of the owners
     * `_minApproval` is at least one, & equal to, or less than `ownersCount`
     */
    function addOwner(address newOwner, uint256 _minApproval) public virtual onlyOwners() {
        require(isOwner[newOwner] == false && newOwner != address(0), "Owners: owner exists or zero address");
        owners.push(newOwner);
        ownersCount++;
        isOwner[newOwner] = true;
        if(minApproval != _minApproval) _changeMinApproval(_minApproval);
        emit OwnerAdded(newOwner);
    }

    /**
     *@dev allow owners to remove `owner` & change `minApproval`
     *@param owner address, `owner` address to be removed
     *@param _minApproval uint, sets `minApproval`
     * Requirements:
     * `owner` is non zero address, & does not exist
     * function caller is one of the owners
     * `_minApproval` is at least one, & equal to, or less than `ownersCount`
     */
    function removeOwner(address owner, uint256 _minApproval) public virtual onlyOwners() {
        require(isOwner[owner] == true && owner != address(0), "Owners: owner  does not exist or zero address");
        uint256 newCount = ownersCount - 1;
        if(_minApproval <= newCount) {
            owner = owners[newCount];
            owners.pop();
            isOwner[owner] = false;
            ownersCount--;
            if(minApproval != _minApproval) _changeMinApproval(_minApproval);
            emit OwnerRemoved(owner);            
        } else {
            revert("Owners: min approval has to be equal or less than new owners count");
        }
    }

    function _changeMinApproval(uint256 _minApproval) private {
        require(
            _minApproval >= 1 && _minApproval <= ownersCount, 
            "Owners: approvals greater than one & equal or less than owners"
        );
        minApproval = _minApproval;
        emit ApprovalsChanged(minApproval);
    }

}