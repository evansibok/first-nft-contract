// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import {Base64} from "./libraries/Base64.sol";

contract SenseiNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("SenseiNFT", "SENSEI") {
        console.log("SenseiNFT Contract initialized");
    }

    uint256 totalNfts = _tokenIds.current();
    // We split the SVG at the part where it asks for the background color.
    string svgPartOne =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartTwo =
        "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
    string baseSvg =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = [
        "Army",
        "Significance",
        "Guitar",
        "Preparation",
        "Drawer",
        "Football",
        "Way",
        "Selection",
        "Surgery",
        "Mom",
        "Skill",
        "Hat"
    ];
    string[] secondWords = [
        "Memory",
        "Arrival",
        "Cousin",
        "Proposal",
        "Song",
        "Meaning",
        "Promotion",
        "Tongue",
        "Power",
        "Replacement",
        "Society",
        "Candidate"
    ];
    string[] thirdWords = [
        "Birthday",
        "Gene",
        "Definition",
        "Chemistry",
        "Guest",
        "Airport",
        "Bathroom",
        "Speaker",
        "Series",
        "Development",
        "Foundation",
        "Enthusiasm"
    ];
    // Get fancy with it! Declare a bunch of colors.
    string[] colors = [
        "#7d0225",
        "#08C2A8",
        "#e0bcb8",
        "yellow",
        "#4498ff",
        "#1dee78",
        "#b17ce0"
    ];

    event NewSenseiNFTMinted(address sender, uint256 tokenId);
    event TotalNFTMinted(uint256 totalNfts);

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function pickRandFirstWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId)))
        );
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandSecondWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId)))
        );
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandThirdWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId)))
        );
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    // Same old stuff, pick a random color.
    function pickRandomColor(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        uint256 rand = random(
            string(abi.encodePacked("COLOR", Strings.toString(tokenId)))
        );
        rand = rand % colors.length;
        return colors[rand];
    }

    function makeSenseiNFT() public {
        uint256 newItemId = _tokenIds.current();
        totalNfts = newItemId + 1;
        require(
            totalNfts <= 50,
            "Maximum number of token minted!\nPlease wait for the next collection to be exhibited!"
        );

        string memory first = pickRandFirstWord(newItemId);
        string memory second = pickRandSecondWord(newItemId);
        string memory third = pickRandThirdWord(newItemId);
        string memory combinedWord = string(
            abi.encodePacked(first, second, third)
        );

        // Add the random color in.
        string memory randomColor = pickRandomColor(newItemId);
        string memory finalSvg = string(
            abi.encodePacked(
                svgPartOne,
                randomColor,
                svgPartTwo,
                combinedWord,
                "</text></svg>"
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        combinedWord,
                        '", "description": "A highly valued collection of Sensei words.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n------------");
        console.log(finalTokenUri);
        console.log("------------\n");

        _safeMint(msg.sender, newItemId);

        _setTokenURI(newItemId, finalTokenUri);

        _tokenIds.increment();

        console.log(
            "An NFT with ID %s has been minted to %s",
            newItemId,
            msg.sender
        );

        emit NewSenseiNFTMinted(msg.sender, newItemId);
        emit TotalNFTMinted(totalNfts);
    }

    function getTotalNFTS() public view returns (uint256) {
        return totalNfts;
    }
}
