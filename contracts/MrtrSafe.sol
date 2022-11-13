//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./ReceiveBrick.sol";
import "./Owners.sol";
import "./proxy/Initializable.sol";
import "./interfaces/IERC1155Modified.sol";
import "./token/ERC1155HolderModified.sol";
import "./interfaces/IERC20Upgradeable.sol";
import "./interfaces/IERC721Modified.sol";
import "./token/ERC721HolderUpgradeable.sol";
import "./interfaces/IFactory.sol";



contract MrtrSafe is 
    Initializable,
    Owners, 
    ReceiveBrick,
    ERC1155HolderModified, 
    ERC721HolderUpgradeable
    
{
   
    // contracts storage
    IERC1155Modified private VCT;
    IERC20Upgradeable private AND;
    IERC721Modified private EstateToken;
    IFactory private factory;

    address public manager;

    uint256 private nonce;
    mapping(bytes32 => bool) private executed;


  
    function __MrtrSafe_init(address[] memory _owners, uint256 _minApprovals) public payable initializer {
        __Owners_init(_owners, _minApprovals);
        __ERC1155HolderModified_init();
        __ERC721Holder_init();

        factory = IFactory(msg.sender);
        require(msg.sender != address(0), "Safe: address zer sender");

        VCT = IERC1155Modified(0x5e17b14ADd6c386305A32928F985b29bbA34Eff5);
        AND = IERC20Upgradeable(0xd9145CCE52D386f254917e481eB44e9943F39138);
    }



    function approve(address spender, uint256 amount) public returns(bool) {
        return AND.approve(spender, amount);
    }

    //checks if VCT exists in safe if it's minted to safe not to address
    function isVerified(address holder) public view returns(bool) {
        return VCT.isVerified(holder);
    }

    function VctId(address holder) public view returns(uint256) {
        return VCT.authToken(holder);
    }


    //checks BRCK balance per safe not per address
    function BRCKBalance() public view virtual returns(uint256) {
        return address(this).balance;
    }


    function EstateTokenBalance(address contractAddress, address holder) public view returns(uint256) {
        return IERC721Modified(contractAddress).balanceOf(holder);
    }

    function transferEstateToken(address contractAddress, address to, uint256 tokenId) public {
        _whenNotPaused();
        IERC721Modified(contractAddress).safeTransferFrom(address(this), to, tokenId);
    }

    function Transferfractions(address vault, address to, uint256 amount) public {
        _whenNotPaused();
        require(msg.sender == manager, "Safe: only manager");
        IERC20Upgradeable(vault).transfer(to, amount);
    }


    function transfer(address payable receiver, string calldata symbol, uint256 amount) public virtual onlyOwners {
        _whenNotPaused();
        require(receiver != address(0) && receiver != address(this), "safe: non zero address & out of the safe only");
        if(keccak256(bytes(symbol)) == keccak256(bytes("BRCK"))) {
            require(address(this).balance >= amount, "Safe: exceeds available Brick's balance");
        } else {
            keccak256(bytes(symbol)) == keccak256(bytes("AND"));
            require(AND.balanceOf(address(this)) >= amount, "Safe: exceeds available AND's balance");
        } 
        (bool success, ) = receiver.call{value: amount}("");
        require(success, "Safe: transfer brick failed");      
    }
    
    function setManager(address _manager) public virtual {
        require(msg.sender == address(factory), "Safe: unauthorized sender");
        manager = _manager;
    }

    function _whenNotPaused() private view returns(bool) {
        require(!factory.isPaused(), "Safe: contract paused");
        return factory.isPaused();
    }
}





