//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./Proxy/Initializable.sol";
import "./Owners.sol";
import "./Cryptography/ECDSAUpgradeable.sol";
import "./Token/ERC721HolderUpgradeable.sol";
import "./Token/ERC1155HolderUpgradeable.sol";

contract MortarGnosis is Initializable, Owners, ERC721HolderUpgradeable, ERC1155HolderUpgradeable {
    using ECDSAUpgradeable for bytes32;

    event BrickReceived(address indexed sender, uint256 amount, uint256 balance);
    event BrickTransfered(address indexed to, uint256 amount);

    //brick balance per address
    mapping(address => uint256) private balance;
    mapping(address => uint256) private nonces;
    mapping(bytes32 => bool) private executed;


    function __MortarGnosis_init(address[] memory _owners, uint256 _minApprovals) public payable initializer {
        __Owners_init(_owners, _minApprovals);
        __ERC1155Holder_init();
        __ERC721Holder_init();
    }

        
    //to recieve brick and update balance
    receive() external payable {
        balance[msg.sender]+= msg.value;
        emit BrickReceived(msg.sender, msg.value, balance[msg.sender]);
    }

    // //ERC721 to show balance 
    // function propertyBalance(address account, address contractAddress) public view returns(uint256) {
    //     return IERC721Upgradeable(contractAddress).balanceOf(account);
    // }

    // //should have functions to show metadata
    // function propertyTokenMetadata(uint256 id, address contractAddress) public view returns(string memory, string memory) {
    //     return IEstates(contractAddress).tokenMetadata(id);
    // }

    // //ERC721 token URI
    // function propertyTokenURI(uint256 id, address contractAddress) public view returns(string memory) {
    //     return IEstates(contractAddress).tokenURI(id);
    // }

    //ERC1155 to show balance - no transfer is allowed

    //BRICK balance needs testing
    function walletBrickBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function ownerBrickBalance(address owner) public view returns(uint256) {
        return balance[owner];
    }

    function transferBrick(address to, uint256 amount, bytes[] memory sigs) public virtual onlyOwners() { 
        require(balance[to] >= amount || balance[address(this)] >= amount, "exceeds balance");
        bytes32 txHash = getTxHash(to, amount, nonces[_msgSender()]);
        require(!executed[txHash], "Wallet: transaction executed");
        require(_validSig(sigs, txHash), "Wallet: invalid signature");
        nonces[msg.sender] += 1;
        executed[txHash] = true;

        (bool transfer, ) = to.call{value: amount}("");
        require(transfer, "transaction failed");
        emit BrickTransfered(to, amount);
    }

    function getTxHash(address to, uint256 amount, uint256 nonce) public view returns(bytes32) {
        return keccak256(abi.encodePacked(address(this), to, amount, nonce));
    }

    function _validSig(bytes[] memory sigs, bytes32 _txhash) private view returns(bool) {
        bytes32 ethSignedHash = _txhash.toEthSignedMessageHash();
        for(uint i = 0; i < sigs.length; i++) {
            address signer = ethSignedHash.recover(sigs[i]);
            bool valid = signer == owners[i];
            if(!valid) {
                return false;
            }
        }
        return true;
    }
}