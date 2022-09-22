//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./ReceiveBrick.sol";
import "./Owners.sol";
import "./Proxy/Initializable.sol";
import "./Interfaces/IERC1155Modified.sol";
import "./Token/ERC1155HolderModified.sol";
import "./Interfaces/IERC20Upgradeable.sol";
import "./Interfaces/IERC721Upgradeable.sol";
import "./ERC721HolderUpgradeable.sol";


contract MrtrSafe is 
    Initializable,
    Owners, 
    ERC1155HolderModified, 
    ERC721HolderUpgradeable,
    ReceiveBrick
{
   

    IERC1155Modified private VCT;
    IERC20Upgradeable private AND;
    //IERC721Upgradeable private EstateToken;

    uint256 private nonce;
    mapping(bytes32 => bool) private executed;
    mapping(address => address[]) internal ownerWallets;


  

    function __MrtrSafe_init(address[] memory _owners, uint256 _minApprovals) public payable initializer {
        __Owners_init(_owners, _minApprovals);
        __ERC1155HolderModified_init();

        VCT = IERC1155Modified(0x0C12780426024405E90b9b40DEE4B8F99B2E3Da5);
        //this is the stable coin address which doesn't exist yet
        AND = IERC20Upgradeable(0x50Dd14Aa06f0032993E6a96fB314596BeccD25c4);
    }


    //checks if VCT exists in safe if it's minted to safe not to address
    function VCTExist(uint256 id) public view returns(uint256) {
        return VCT.balanceOf(address(this), id);
    }


    //checks BRCK balance per safe not per address
    function BRCKBalance() public view virtual returns(uint256) {
        return address(this).balance;
    }

    function walletAddress() public view returns(address) {
        return address(this);
    }

    function EstateTokenBalance(address contractAddress, address owner) public view returns(uint256) {
        return IERC721Upgradeable(contractAddress).balanceOf(owner);
    }

    function transferEstateToken(address contractAddress, uint256 tokenId, address to) public {
        IERC721Upgradeable(contractAddress).transferToken(address(this), tokenId, to);
    }


    function transfer(address payable receiver, string calldata symbol, uint256 id, uint256 amount) public virtual onlyOwners {
        require(receiver != address(0) && receiver != address(this), "safe: non zero address & out of the safe only");
        if(keccak256(bytes(symbol)) == keccak256(bytes("BRCK"))) {
            require(address(this).balance >= amount, "Safe: exceeds available Brick's balance");
            (bool success, ) = receiver.call{value: amount}("");
            require(success, "Safe: transfer brick failed");
            //no stable coin yet
        } else if(keccak256(bytes(symbol)) == keccak256(bytes("AND"))) {
            require(AND.balanceOf(address(this)) >= amount, "Safe: exceeds available AND's balance");
        } else if(keccak256(bytes(symbol)) == keccak256(bytes("VCT"))) {
            require(VCT.balanceOf(address(this), id) >= amount, "Safe: exceeds available VCT's balance");
            VCT.safeTransferFrom(address(this), receiver, id, amount, "");
        } else {
            revert("Safe: token do not exist or estate token");
        }
        
    }

}



