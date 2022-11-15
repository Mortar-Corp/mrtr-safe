//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./ReceiveBrick.sol";
import "./Owners.sol";
import "./proxy/Initializable.sol";
import "./cryptography/EIP712Upgradeable.sol";
import "./interfaces/IERC1155Modified.sol";
import "./token/ERC1155HolderModified.sol";
import "./interfaces/IERC20Upgradeable.sol";
import "./interfaces/IERC721Modified.sol";
import "./token/ERC721HolderUpgradeable.sol";
import "./utils/AddressUpgradeable.sol";
import "./token/ERC20Upgradeable.sol";
import "./interfaces/IFactory.sol";



contract MrtrSafe is 
    Initializable,
    Owners, 
    ReceiveBrick,
    EIP712Upgradeable,
    ERC1155HolderModified, 
    ERC721HolderUpgradeable
    
{
    using AddressUpgradeable for address;
   
    // contracts storage
    address private constant VCT = 0x5e17b14ADd6c386305A32928F985b29bbA34Eff5;
    address private constant AND = 0xd9145CCE52D386f254917e481eB44e9943F39138;
    IFactory private factory;

    address public manager;

    uint256 private nonce;
    mapping(bytes32 => bool) private executed;
    mapping(address => bool) private exists;
    mapping(string => Asset) private assets;

    struct Asset {
        address assetAddress;
        string symbol;
        string name;
        uint256 id;
    }

  
    function __MrtrSafe_init(address[] memory _owners, uint256 _minApprovals) public payable virtual initializer {
        __Owners_init(_owners, _minApprovals);
        __EIP712_init("MrtrSafe", "1.0.0");
        __ERC1155HolderModified_init();
        __ERC721Holder_init();

        factory = IFactory(msg.sender);
        _nonZero(msg.sender);
    }


    function listAsset(address assetAddress, string memory symbol, string memory name, uint256 id) public virtual {
        _whenNotPaused();
        _nonZero(assetAddress);
        _isContract(assetAddress);
        require(!assetExists(assetAddress), "Safe: duplicate asset");
        require(msg.sender == manager || ownerExists(msg.sender), "Safe: unauthorized user");
        require(assetAddress != VCT && assetAddress != AND, "Safe: VCT & AND are listed");
        if(id != 0) {
            require
            (
                keccak256(
                    abi.encodePacked(
                        IERC721Modified(assetAddress).name(id)
                    )
                ) == keccak256(abi.encodePacked(name)),
                "Safe: name of Estate mismatch input entry"
            );
            require
            (
                keccak256(
                    abi.encodePacked(
                        IERC721Modified(assetAddress).symbol(id)
                    )
                ) == keccak256(abi.encodePacked(symbol)),
                "Safe: symbol of Estate mismatch input entry"
            );
            assets[symbol] = Asset(assetAddress, symbol, name, id);
        } else {
            require
            (
                keccak256(
                    abi.encodePacked(
                        ERC20Upgradeable(assetAddress).name()
                    )
                ) == keccak256(abi.encodePacked(name)),
                "Safe: name of vault mismatch input name"
            );
            require
            (
                keccak256(
                    abi.encodePacked(
                        ERC20Upgradeable(assetAddress).symbol()
                    )
                ) == keccak256(abi.encodePacked(symbol)),
                "Safe: symbol of vault mismatch input symbol"
            );
        }
        assets[symbol] = Asset(assetAddress, symbol, name, id);
        exists[assetAddress] = true;
    }



    // function approve(address spender, uint256 amount) public returns(bool) {
    //     return AND.approve(spender, amount);
    // }


    //checks BRCK balance per safe not per address
    function BRCKBalance() public view virtual returns(uint256) {
        return address(this).balance;
    }

    function assetExists(address asset) public view virtual returns(bool) {
        return exists[asset];
    }

    // will be moved to signature
    function transferEstateToken(address contractAddress, address to, uint256 tokenId) public {
        _whenNotPaused();
        IERC721Modified(contractAddress).safeTransferFrom(address(this), to, tokenId);
    }

    // function Transferfractions(address to) public {
    //     _whenNotPaused();
    //     _nonZero(to);
    //     _isContract(to);
    //     require(msg.sender == manager, "Safe: only manager");
    //     IERC20Upgradeable(assets[]).transfer(to, amount);
    // }

    function transferBusiness(address to) public virtual {
        require(msg.sender == manager, "Safe: only manager");
        _nonZero(to);
        _isContract(to);
        IERC1155Modified(VCT).safeTransferFrom(address(this), to, 1, 1, "");
    }


    function transfer(address payable receiver, string calldata symbol, uint256 amount) public virtual onlyOwners {
        _whenNotPaused();
        _nonZero(receiver);
        require(receiver != address(this), "safe: transfer to this safe");
        if(keccak256(bytes(symbol)) == keccak256(bytes("BRCK"))) {
            require(address(this).balance >= amount, "Safe: exceeds available Brick's balance");
        } else {
            keccak256(bytes(symbol)) == keccak256(bytes("AND"));
            //require(AND.balanceOf(address(this)) >= amount, "Safe: exceeds available AND's balance");
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

    function _isContract(address target) private view {
        require(AddressUpgradeable.isContract(target),"Safe: address is not contract");
    }

    function _nonZero(address target) private pure {
        require(target != address(0), "Safe: non zero address only");
    }

}





