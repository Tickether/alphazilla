//SPDX-License-Identifier: MIT
// Art by @walshe_steve // Copyright © Steve Walshe
// Code by @0xGeeLoko

pragma solidity ^0.8.4;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./MerkleDistributor.sol";

contract Alphazilla is ERC721A, MerkleDistributor, Ownable, ReentrancyGuard {
    using Strings for string;

    uint256 public constant maxAlphazilla = 1000;
    uint256 public maxPerWallet = 100;
    bool public allowIsActive = false;
    bool public publicIsActive = false;


    string public baseURI;

    uint256 public mintPrice;




    constructor() ERC721A("Alphazilla Androids", "AZA") {}

    modifier ableToMint(uint256 mintAmount) {
        require(totalSupply() + mintAmount <= maxAlphazilla, 'Max Token Supply');
        _;
    }

    /*
    * Withdraw funds
    */
    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "Zero balance");

        uint256 balance = address(this).balance;
        Address.sendValue(payable(msg.sender), balance);
    }

    /*
    * Set Mint Price
    */
    function setMintPrice(uint256 newPrice) public onlyOwner {
        mintPrice = newPrice;
    }

    function setMintMax(uint256 newMax) public onlyOwner {
        maxPerWallet = newMax;
    }
    //---------------------------------------------------------------------------------
    /*
    * Pause allowlist minting if active, make active if paused
    */
    function flipMintingState() public onlyOwner {
        allowIsActive = !allowIsActive;
    }
    /*
    * Pause minting if active, make active if paused
    */
    function flipPublicState() public onlyOwner {
        publicIsActive = !publicIsActive;
    }

    /**
     * allow list
     */
    function setAllowList(bytes32 merkleRoot) external onlyOwner {
        _setAllowList(merkleRoot);
    }

    /**
     * allow list Mint
     */
    function allowListMint(uint256 mintAmount, bytes32[] memory merkleProof) 
    external
    ableToClaim(msg.sender, merkleProof)
    tokensAvailable(msg.sender, mintAmount, maxPerWallet)
    ableToMint(mintAmount)
    nonReentrant 
    {
        require(allowIsActive, "allow list not active");
        
        _setAllowListMinted(msg.sender, mintAmount);
        _safeMint(msg.sender, mintAmount);
    }

    /**
     * public Mint
     */
    function publicMint(uint256 mintAmount) 
    external
    payable
    ableToMint(mintAmount)
    nonReentrant
    {
        require(publicIsActive, "public not active");
        require(mintAmount <= maxPerWallet, 'over max mint');
        require(mintAmount * mintPrice == msg.value, 'Ether value not correct');

        _safeMint(msg.sender, mintAmount);

    }

    /// ERC721 related
    /**
     * @dev See {ERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "nonexistent token");

        return string(abi.encodePacked(baseURI, Strings.toString(tokenId), '.json'));
    }
    /**
    * Set base URL
    */
    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

}