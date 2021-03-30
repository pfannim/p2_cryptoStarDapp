pragma solidity >=0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {

    struct Star {
        string name;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo;
    mapping(uint256 => uint256) public starsForSale;

    constructor(string memory _name, string memory _symbol) 
    ERC721(_name, _symbol) {

    }

    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        Star memory newStar = Star(_name); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale the Star you don't owned");
        starsForSale[_tokenId] = _price;
    }


    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        // return address(uint160(x));
        return payable(x);
    }

    function buyStar(uint256 _tokenId) public  payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        _transfer(ownerAddress, msg.sender, _tokenId); // We can't use _addTokenTo or_removeTokenFrom functions, now we have to use _transferFrom
        address payable ownerAddressPayable = _make_payable(ownerAddress); // We need to make this conversion to be able to use transfer() function to transfer ethers
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
            payable(msg.sender).transfer(msg.value - starCost);
        }
    }

    // Look up star by token ID
    function lookUptokenIdToStarInfo(uint256 _tokenId) public view returns (string memory) {
        Star memory star = tokenIdToStarInfo[_tokenId];
        return star.name;
    }

    // Exchange stars between two users
    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        address ownerAddress1 = ownerOf(_tokenId1);
        address ownerAddress2 = ownerOf(_tokenId2);
        require((ownerAddress1 == msg.sender || ownerAddress2 == msg.sender), "One of the owners needs to be sender");
        _transfer(ownerAddress1, ownerAddress2, _tokenId1);
        _transfer(ownerAddress2, ownerAddress1, _tokenId2); 
    }

    // Transfer a star
    function transferStar(address _to, uint256 _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "You must own the star");
        _transfer(msg.sender, _to, _tokenId);
    }

}