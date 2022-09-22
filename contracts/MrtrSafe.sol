//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./ReceiveBrick.sol";
import "./Owners.sol";
import "./Proxy/Initializable.sol";
import "./Cryptography/ECDSAUpgradeable.sol";
import "./Cryptography/draft-EIP712Upgradeable.sol";
import "./Interfaces/IERC1155Modified.sol";
import "./Token/ERC1155HolderModified.sol";
import "./Interfaces/IERC20Upgradeable.sol";


contract MrtrSafe is 
    Initializable,
    Owners, 
    ERC1155HolderModified, 
    EIP712Upgradeable, 
    ReceiveBrick
{
   

    IERC1155Modified private VCT;
    IERC20Upgradeable private AND;
    uint256 private nonce;
    mapping(bytes32 => bool) private executed;


    bytes32 private constant TRANSFER_TYPEHASH = keccak256("Transfer(address reciever,string symbol,uint256 id,uint256 amount,uint256 nonce");

    function __MrtrSafe_init(address[] memory _owners, uint256 _minApprovals) public payable initializer {
        __Owners_init(_owners, _minApprovals);
        __EIP712_init("MrtrSafe", "1.0.0");
        __ERC1155HolderModified_init();

        VCT = IERC1155Modified(0xC265Ee3c7173818dad8e212197044Eb3b23b55C9);
        AND = IERC20Upgradeable(0x50Dd14Aa06f0032993E6a96fB314596BeccD25c4);
    }


    function VCTExist(uint256 id) public view returns(uint256) {
        return VCT.balanceOf(address(this), id);
    }


    //BRCK balance 
    function BRCKBalance() public view virtual returns(uint256) {
        return address(this).balance;
    }

    function transfer(address payable receiver, string calldata symbol, uint256 id, uint256 amount, bytes[] calldata signatures) public virtual onlyOwners {
        
        require(verifySiganture(transferHash(receiver, symbol, id, amount, nonce), signatures), "Safe: invalid siganture");

        if(keccak256(bytes(symbol)) == keccak256(bytes("BRCK"))) {
            require(address(this).balance >= amount, "Safe: exceeds balance");
        } else if(keccak256(bytes(symbol)) == keccak256(bytes("AND"))) {
            require(AND.balanceOf(address(this)) >= amount, "Safe: exceeds balance");
        } else if(keccak256(bytes(symbol)) == keccak256(bytes("VCT"))) {
            require(id == 1, "Safe: ");
        }
        (bool success, ) = receiver.call{value: amount}("");
        require(success, "Safe: tx failed");
        nonce++;
    }

    function transferHash(address receiver, string memory symbol, uint256 id, uint256 amount, uint256 _nonce) public view returns(bytes32) {
       
        return _hashTypedDataV4(keccak256(abi.encode(
            TRANSFER_TYPEHASH,
            receiver,
            symbol,
            id,
            amount,
            _nonce
            )
        ));
    }

    function verifySiganture(bytes32 _transferHash, bytes[] memory signatures) public view returns(bool) {
       
        for(uint256 i = 0; i < signatures.length; i++) {
            address signer = ECDSAUpgradeable.recover(_transferHash, signatures[i]);
            signer = owners[i];        
            bool valid = signer == owners[i];
            if(!valid) {
                return false;
            }
        }
        return true;
    }

    function getChainId() external view returns (uint256) {
        uint256 id;

        assembly {
            id := chainid()
        }
        return id;
    }

    function domainSeparator() external view returns(bytes32) {
        return _domainSeparatorV4();
    }
}


