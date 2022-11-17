//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "./ReceiveBrick.sol";
import "./Owners.sol";
import "./proxy/Initializable.sol";
import "./cryptography/EIP712Upgradeable.sol";
import "./cryptography/SignatureCheckerUpgradeable.sol";
import "./interfaces/IERC1155Modified.sol";
import "./token/ERC1155HolderModified.sol";
import "./interfaces/IERC20Upgradeable.sol";
import "./interfaces/IERC721Modified.sol";
import "./token/ERC721HolderUpgradeable.sol";
import "./utils/AddressUpgradeable.sol";
import "./token/ERC20Upgradeable.sol";
import "./interfaces/IFactory.sol";

/**
 *@title MrtrSafe
 *@author Sasha Flores
 *@notice safe is designed to hold all assets
 * assets are minted directly to safe.
 * owners are responsible for transferring nft
 * to vault, `BRCK` native coin to safe or address,
 * & approving vault address as a spender 
 * of `AND` collateral token.
 * manager is authorized to transfer fractions,
 * & tranfer business VCTs.
 */

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

    // transfer fractions & VCT business
    address public manager;

    // assets storage
    uint256 private _nonce;
    mapping(address => bool) private exists;
    mapping(string => Asset) private assets;

    struct Asset {
        address assetAddress;
        string symbol;
        string name;
        uint256 id;
    }

    //keccak256("Transfer(address receiver,string symbol,uint256 amount,uint256 id,uint256 nonce)")
    bytes32 private constant TRANSFER_TYPEHASH = 0xb226c456cea1343f3e1288eb20976517dd4037eddc180f552a49dcf42a15d229;

    //keccak256("Approve(address spender,uint256 amount,uint256 nonce)")
    bytes32 private constant APPROVE_TYPEHASH = 0xcc14a4b433c79d829b71a51edd110b7d3541709fe9814a4aed7bc0febdb0353e;
  
    
    
    function __MrtrSafe_init(address[] memory _owners, uint256 _minApprovals) public payable virtual initializer {
        __Owners_init(_owners, _minApprovals);
        __EIP712_init("MrtrSafe", "1.0.0");
        __ERC1155HolderModified_init();
        __ERC721Holder_init();

        factory = IFactory(msg.sender);
        _nonZero(msg.sender);
    }

    function domainSeparator() external virtual view returns(bytes32) {
        return _domainSeparatorV4();
    }

    function getChainId() external virtual view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function protocolName() external virtual view returns(string memory) {
        return string(abi.encodePacked(_EIP712NameHash()));
    }

    function version() external virtual view returns(string memory) {
        return string(abi.encodePacked(_EIP712VersionHash()));
    }

    function NameHash() external virtual view returns(bytes32) {
        return _EIP712NameHash();
    }

    function versionHash() external virtual view returns(bytes32) {
        return _EIP712VersionHash();
    }

    // list assets except for VCT & AND can be done by owners or manager
    function listAsset(address assetAddress, string memory symbol, string memory name, uint256 id) public virtual {
        _whenNotPaused();
        _nonZero(assetAddress);
        _isContract(assetAddress);
        require(!assetExists(assetAddress), "Safe: duplicate asset");
        require(msg.sender == manager || ownerExists(msg.sender), "Safe: unauthorized user");
        require(assetAddress != VCT && assetAddress != AND, "Safe: VCT & AND are listed");
        if(id != 0) {
            require(
                keccak256(
                    bytes(
                        IERC721Modified(assetAddress).name(id)
                    )
                ) == keccak256(bytes(name)),
                "Safe: name of Estate mismatch input entry"
            );
            require(
                keccak256(
                    bytes(
                        IERC721Modified(assetAddress).symbol(id)
                    )
                ) == keccak256(bytes(symbol)),
                "Safe: symbol of Estate mismatch input entry"
            );
        } else {
            require(
                keccak256(
                    bytes(
                        ERC20Upgradeable(assetAddress).name()
                    )
                ) == keccak256(bytes(name)),
                "Safe: name of vault mismatch input name"
            );
            require(
                keccak256(
                    bytes(
                        ERC20Upgradeable(assetAddress).symbol()
                    )
                ) == keccak256(bytes(symbol)),
                "Safe: symbol of vault mismatch input symbol"
            );
        }
        assets[symbol] = Asset(assetAddress, symbol, name, id);
        exists[assetAddress] = true;
    }

    function approveHash(address spender, uint256 amount, uint256 nonce) public virtual view returns(bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(APPROVE_TYPEHASH, spender, amount, nonce)));
    }

    function transferHash(
        address receiver, 
        string memory symbol, 
        uint256 amount, 
        uint256 id, 
        uint256 nonce
    ) public virtual view returns(bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(TRANSFER_TYPEHASH,receiver, symbol, amount, id, nonce)));
    }

    function verifySignature(address signer, bytes32 txHash, bytes memory signature) public virtual view returns(bool) {
        return ownerExists(signer) && SignatureCheckerUpgradeable.isValidSignatureNow(signer, txHash, signature);
    }

    // approve spender to spend amount of AND
    function approve(address spender, uint256 amount, bytes calldata signatures) public virtual returns(bool) {
        bytes32 hash = approveHash(spender, amount, _nonce);
        require(signatures.length >= minApproval, "Safe: min signatures not met");
        require(verifySignature(msg.sender, hash, signatures), "Safe: invalid signature");
        _nonce ++;
        return IERC20Upgradeable(AND).approve(spender, amount);
    }

    // transfer BRCK, AND, Estate token only as fractions & VCT are manager's responsibility
    function transfer(
        address payable receiver, 
        string memory symbol, 
        uint256 amount, 
        uint256 id, 
        bytes calldata signatures
    ) public virtual onlyOwners {
        _whenNotPaused();
        _nonZero(receiver);
        require(receiver != address(this), "safe: transfer to this safe");

        bytes32 hash = transferHash(receiver, symbol, amount, id, _nonce);
        require(verifySignature(msg.sender, hash, signatures), "Safe: invalid signature");
        require(signatures.length >= minApproval, "Safe: min signatures not met");

        if(id != 0) {
            _isContract(receiver);
            require(keccak256(bytes(symbol)) == keccak256(bytes(IERC721Modified(assets[symbol].assetAddress).symbol(id))));
            require(assetExists(address(IERC721Modified(assets[symbol].assetAddress))), "Safe: asset not listed");
            
            IERC721Modified(assets[symbol].assetAddress).safeTransferFrom(address(this), receiver, id, "");

        } else if(keccak256(bytes(symbol)) == keccak256(bytes("BRCK"))) {
            require(address(this).balance >= amount, "Safe: exceeds available Brick's balance");
            
            (bool success, ) = receiver.call{value: amount}("");
            require(success, "Safe: transfer brick failed"); 

        } else if(keccak256(bytes(symbol)) == keccak256(bytes("AND"))) {
            require(
                IERC20Upgradeable(AND).balanceOf(address(this)) >= amount, 
                "Safe: exceeds available AND's balance"
            );
            IERC20Upgradeable(AND).transfer(receiver, amount);
        } else {
            revert("Safe: wrong entry or manager required");
        }

        _nonce ++;
    }

    function currentNonce() public virtual view returns(uint256) {
        return _nonce;
    }

    //checks BRCK balance per safe not per address
    function BRCKBalance() public virtual view  returns(uint256) {
        return address(this).balance;
    }

    // true if asset has been listed
    function assetExists(address asset) public virtual view returns(bool) {
        return exists[asset];
    }

    // accessible by mananger only
    function Transferfractions(string memory symbol, address to) public virtual {
        _whenNotPaused();
        _nonZero(to);
        _isContract(to);
        require(msg.sender == manager, "Safe: only manager");
        require(assetExists(address(ERC20Upgradeable(assets[symbol].assetAddress))), "Safe: asset not listed");
        ERC20Upgradeable(assets[symbol].assetAddress).transfer(to, ERC20Upgradeable(assets[symbol].assetAddress).balanceOf(address(this)));
    }

    // accessible by manager only
    function transferBusiness(address to) public virtual {
        require(msg.sender == manager, "Safe: only manager");
        require(IERC1155Modified(VCT).isVerified(address(this)), "Safe: safe is not verified");
        _nonZero(to);
        _isContract(to);
        IERC1155Modified(VCT).safeTransferFrom(address(this), to, 1, 1, "");
    }
    
    // to set manager for safe
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