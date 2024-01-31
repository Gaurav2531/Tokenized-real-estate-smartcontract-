// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RealEstateToken is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
        using Counters for Counters.Counter;

            // Structure to represent a property
                struct Property {
                        string name;
                                string location;
                                        uint256 price;
                                                bool forSale;
                                                    }

                                                        // Mapping from token ID to property details
                                                            mapping(uint256 => Property) public properties;

                                                                // Mapping from token ID to the listing price
                                                                    mapping(uint256 => uint256) public listingPrices;

                                                                        // Counter for property IDs
                                                                            Counters.Counter private propertyIdCounter;

                                                                                // Events
                                                                                    event PropertyCreated(uint256 tokenId, string name, string location, uint256 price);
                                                                                        event PropertyListed(uint256 tokenId, uint256 price);
                                                                                            event PropertySold(uint256 tokenId, address buyer, uint256 price);

                                                                                                constructor() ERC721("RealEstateToken", "RET") {}

                                                                                                    // Function to create a new property token
                                                                                                        function createProperty(
                                                                                                                string memory _name,
                                                                                                                        string memory _location,
                                                                                                                                uint256 _price
                                                                                                                                    ) external onlyOwner {
                                                                                                                                            propertyIdCounter.increment();
                                                                                                                                                    uint256 tokenId = propertyIdCounter.current();
                                                                                                                                                            _mint(msg.sender, tokenId);
                                                                                                                                                                    properties[tokenId] = Property({
                                                                                                                                                                                name: _name,
                                                                                                                                                                                            location: _location,
                                                                                                                                                                                                        price: _price,
                                                                                                                                                                                                                    forSale: false
                                                                                                                                                                                                                            });
                                                                                                                                                                                                                                    emit PropertyCreated(tokenId, _name, _location, _price);
                                                                                                                                                                                                                                        }

                                                                                                                                                                                                                                            // Function to list a property for sale
                                                                                                                                                                                                                                                function listProperty(uint256 _tokenId, uint256 _price) external {
                                                                                                                                                                                                                                                        require(_exists(_tokenId), "Token does not exist");
                                                                                                                                                                                                                                                                require(ownerOf(_tokenId) == msg.sender, "Not the owner");
                                                                                                                                                                                                                                                                        require(_price > 0, "Invalid price");

                                                                                                                                                                                                                                                                                properties[_tokenId].forSale = true;
                                                                                                                                                                                                                                                                                        listingPrices[_tokenId] = _price;
                                                                                                                                                                                                                                                                                                emit PropertyListed(_tokenId, _price);
                                                                                                                                                                                                                                                                                                    }

                                                                                                                                                                                                                                                                                                        // Function to remove a property from sale
                                                                                                                                                                                                                                                                                                            function removePropertyFromSale(uint256 _tokenId) external {
                                                                                                                                                                                                                                                                                                                    require(_exists(_tokenId), "Token does not exist");
                                                                                                                                                                                                                                                                                                                            require(ownerOf(_tokenId) == msg.sender, "Not the owner");

                                                                                                                                                                                                                                                                                                                                    properties[_tokenId].forSale = false;
                                                                                                                                                                                                                                                                                                                                            delete listingPrices[_tokenId];
                                                                                                                                                                                                                                                                                                                                                }

                                                                                                                                                                                                                                                                                                                                                    // Function to buy a property token
                                                                                                                                                                                                                                                                                                                                                        function buyProperty(uint256 _tokenId) external payable {
                                                                                                                                                                                                                                                                                                                                                                require(_exists(_tokenId), "Token does not exist");
                                                                                                                                                                                                                                                                                                                                                                        require(properties[_tokenId].forSale, "Property not for sale");
                                                                                                                                                                                                                                                                                                                                                                                require(msg.value >= listingPrices[_tokenId], "Insufficient funds");

                                                                                                                                                                                                                                                                                                                                                                                        address seller = ownerOf(_tokenId);
                                                                                                                                                                                                                                                                                                                                                                                                address buyer = msg.sender;
                                                                                                                                                                                                                                                                                                                                                                                                        uint256 price = listingPrices[_tokenId];

                                                                                                                                                                                                                                                                                                                                                                                                                // Transfer ownership
                                                                                                                                                                                                                                                                                                                                                                                                                        _transfer(seller, buyer, _tokenId);
                                                                                                                                                                                                                                                                                                                                                                                                                                properties[_tokenId].forSale = false;
                                                                                                                                                                                                                                                                                                                                                                                                                                        delete listingPrices[_tokenId];

                                                                                                                                                                                                                                                                                                                                                                                                                                                // Transfer funds to the seller
                                                                                                                                                                                                                                                                                                                                                                                                                                                        (bool success, ) = payable(seller).call{value: price}("");
                                                                                                                                                                                                                                                                                                                                                                                                                                                                require(success, "Transfer failed");
                                                                                                                                                                                                                                                                                                                                                                                                                                                                        emit PropertySold(_tokenId, buyer, price);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                            }
                                                                                                                                                                                                                                                                                                                                                                                                                                                                            }
                                                                                                                                                                                                                                                                                                                                                                                                                                                                            