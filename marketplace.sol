pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PhoneMarketplace {
    // Define the ERC20 token that will be used for payment
    IERC20 public token;

    // Define a struct to represent a phone for sale
    struct Phone {
        address seller;
        string name;
        string model;
        uint256 price;
        bool sold;
    }

    // Define an array to store all phones for sale
    Phone[] public phones;

    // Define an event that will be emitted when a phone is sold
    event PhoneSold(uint256 indexed index, address indexed seller, address indexed buyer, string name, string model, uint256 price);

    // Constructor function to set the ERC20 token
    constructor(IERC20 _token) {
        token = _token;
    }

    // Function to add a phone for sale
    function addPhone(string memory name, string memory model, uint256 price) external {
        // Transfer the phone to the marketplace contract
        token.transferFrom(msg.sender, address(this), price);

        // Add the phone to the array of phones for sale
        phones.push(Phone({
            seller: msg.sender,
            name: name,
            model: model,
            price: price,
            sold: false
        }));
    }

    // Function to get the number of phones for sale
    function getPhoneCount() external view returns (uint256) {
        return phones.length;
    }

    // Function to get the details of a phone for sale by index
    function getPhone(uint256 index) external view returns (address, string memory, string memory, uint256, bool) {
        require(index < phones.length, "Invalid index");

        Phone memory phone = phones[index];
        return (phone.seller, phone.name, phone.model, phone.price, phone.sold);
    }

    // Function to buy a phone by index
    function buyPhone(uint256 index) external {
        require(index < phones.length, "Invalid index");

        Phone storage phone = phones[index];
        require(!phone.sold, "Phone already sold");

        // Transfer the payment to the seller
        token.transfer(phone.seller, phone.price);

        // Mark the phone as sold
        phone.sold = true;

        // Emit the PhoneSold event
        emit PhoneSold(index, phone.seller, msg.sender, phone.name, phone.model, phone.price);
    }
}
