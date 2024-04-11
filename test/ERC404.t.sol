// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Digits} from "../src/ERC404.sol";
import "forge-std/console.sol";

contract DigitsTest is Test {
    Digits public digits;
    address acc1 = vm.addr(1); // 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf
    address acc2 = vm.addr(2); // 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF
    address acc3 = vm.addr(3); // 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69
    address currentOwner = address(0);
    uint256 decimals = 10 ** 18;
    uint256 totalSupply = 1000;

    function setUp() public {
        digits = new Digits(acc1);
        currentOwner = digits.owner();
    }

    function test_TokenURI() public {
        assertEq(digits.tokenURI(1), "data:application/json;utf8,{\"name\": \"Awesome numbers#1\",\"description\":\"A collection of 1000 numbers\",\"external_url\":\"https://dummyNumbers.xyz\",\"image\":\"6.gif\",\"attributes\":[{\"trait_type\":\"Number\",\"value\":\"6\"}]}", "tokenId 1 should be 6");
    }

    function test_OwnerBalance() public {
        uint256 ownerBalance = digits.balanceOf(currentOwner);
        console.log("Owner Balance: %s", ownerBalance / decimals);
        assertEq(ownerBalance, totalSupply * decimals);

        uint256 mintedTokens = digits.minted();
        console.log("Minted Tokens: %s", mintedTokens);
        assertEq(mintedTokens, 0);
    }

    function test_CurrentOwner() public {
        assertEq(
            currentOwner,
            acc1,
            "Owner address should be 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf"
        );
        console.log("Owner is 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf");
    }

    function test_WhitelistTheOwner() public {
        vm.startPrank(currentOwner);
        digits.setWhitelist(currentOwner, true);
        bool isWhitelisted = digits.whitelist(currentOwner);
        assertEq(isWhitelisted, true, "Owner should be whitelisted");
        console.log("Owner is whitelisted");
    }

    function test_FirstTransfersToAcc2AndAcc3() public {
        vm.startPrank(currentOwner);
        digits.setWhitelist(currentOwner, true);

        digits.transfer(acc2, 10 * decimals + 500);
        console.log("Owner transferred 10.5 ERC404 to acc2");

        digits.transfer(acc3, 1 * decimals - 500);
        console.log("Owner transferred 0.50 ERC404 to acc3");

        uint256 ownerBalance = digits.balanceOf(currentOwner);
        assertEq(
            ownerBalance,
            (totalSupply - 11) * decimals,
            "Owner balance should be 989E18"
        );
        console.log("Owner Balance: %s", ownerBalance);

        uint256 mintedTokens = digits.minted();
        assertEq(mintedTokens, 10, "Minted tokens should be 10");
        console.log("Minted Tokens: %s", mintedTokens);

        uint256 acc2Balance = digits.balanceOf(acc2);
        assertEq(acc2Balance / decimals, 10, "Acc2 tokens should be 9");
        console.log("Acc2 Balance: %s", acc2Balance);
        console.log("Acc2 Tokens: %s", acc2Balance / decimals);

        uint256 acc3Balance = digits.balanceOf(acc3);
        assertEq(acc3Balance / decimals, 0, "Acc3 tokens should be 0");
        console.log("Acc3 Balance: %s", acc3Balance);
        console.log("Acc3 Tokens: %s", acc3Balance / decimals);
    }

    function test_Acc2Transfers05ToAcc3() public {
        vm.startPrank(currentOwner);
        digits.setWhitelist(currentOwner, true);
        digits.transfer(acc2, 10 * decimals + 500);
        digits.transfer(acc3, 1 * decimals - 500);

        vm.startPrank(acc2);
        digits.transfer(acc3, 500);
        console.log("Acc2 transferred 0.50 ERC404 to acc3");

        uint256 mintedTokens = digits.minted();
        assertEq(mintedTokens, 11, "Minted tokens should be 11");
        console.log("Minted Tokens: %s", mintedTokens);

        uint256 acc3Balance = digits.balanceOf(acc3);
        assertEq(acc3Balance / decimals, 1, "Acc3 tokens should be 1");
        console.log("Acc3 Balance: %s", acc3Balance);
        console.log("Acc3 Tokens: %s", acc3Balance / decimals);

        address ownerTokenId10 = digits.ownerOf(10);
        assertEq(
            ownerTokenId10,
            acc2,
            "Owner of token10 should be 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF"
        );
        console.log("Owner TokenId 10: %s, acc2", ownerTokenId10);

        address ownerTokenId11 = digits.ownerOf(11);
        assertEq(
            ownerTokenId11,
            acc3,
            "Owner of token11 should be 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69"
        );
        console.log("Owner TokenId 11: %s, acc3", ownerTokenId11);

        // address ownerTokenId12 = digits.ownerOf(12);
        // console.log("Owner TokenId 12: %s", ownerTokenId12);
    }

    function test_Acc2Transfer05Again() public {
        vm.startPrank(currentOwner);
        digits.setWhitelist(currentOwner, true);
        digits.transfer(acc2, 10 * decimals + 500);
        digits.transfer(acc3, 1 * decimals - 500);
        vm.startPrank(acc2);
        digits.transfer(acc3, 500);

        digits.transfer(acc3, 500);
        console.log("Acc2 transferred 0.50 ERC404 to acc3");

        uint256 mintedTokens = digits.minted();
        assertEq(mintedTokens, 11, "Minted tokens should be 11");
        console.log("Minted Tokens: %s", mintedTokens);

        uint256 acc2Balance = digits.balanceOf(acc2);
        assertEq(acc2Balance / decimals, 9, "Acc2 tokens should be 9");
        console.log("Acc2 Balance: %s", acc2Balance);
        console.log("Acc2 Tokens: %s", acc2Balance / decimals);

        uint256 acc3Balance = digits.balanceOf(acc3);
        assertEq(acc3Balance / decimals, 1, "Acc3 tokens should be 1");
        console.log("Acc3 Balance: %s", acc3Balance);
        console.log("Acc3 Tokens: %s", acc3Balance / decimals);

        // address ownerTokenId10 = digits.ownerOf(10);
        // console.log("Owner TokenId 10: %s", ownerTokenId10);

        address ownerTokenId11 = digits.ownerOf(11);
        assertEq(
            ownerTokenId11,
            acc3,
            "Owner of token11 should be 0x6813Eb9362372EEF6200f3b1dbC3f819671cBA69"
        );
        console.log("Owner TokenId 11: %s, acc3", ownerTokenId11);

        // address ownerTokenId12 = digits.ownerOf(12);
        // console.log("Owner TokenId 12: %s", ownerTokenId12);
    }

    function test_Acc3TransferNFT11ToAcc2() public {
        vm.startPrank(currentOwner);
        digits.setWhitelist(currentOwner, true);
        digits.transfer(acc2, 10 * decimals + 500);
        digits.transfer(acc3, 1 * decimals - 500);
        vm.startPrank(acc2);
        digits.transfer(acc3, 500);
        digits.transfer(acc3, 500);

        vm.startPrank(acc3);
        digits.transferFrom(acc3, acc2, 11);
        console.log("Acc3 transferred tokenId 11 ERC404 to acc2");
        address ownerTokenId11 = digits.ownerOf(11);
        assertEq(
            ownerTokenId11,
            acc2,
            "Owner of token11 should be 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF"
        );
        console.log("Owner TokenId 11: %s acc2", ownerTokenId11);

        uint256 mintedTokens = digits.minted();
        assertEq(mintedTokens, 11, "Minted tokens should be 11");
        console.log("Minted Tokens: %s", mintedTokens);

        uint256 acc3Balance = digits.balanceOf(acc3);
        assertEq(acc3Balance / decimals, 0, "Acc3 tokens should be 0");
        console.log("Acc3 Balance: %s", acc3Balance);

        uint256 acc2Balance = digits.balanceOf(acc2);
        assertEq(acc2Balance / decimals, 10, "Acc2 tokens should be 10");
        console.log("Acc2 Balance: %s", acc2Balance);
    }

    function test_Acc2WhitelistedTransferToAcc3() public {
        vm.startPrank(currentOwner);
        digits.setWhitelist(currentOwner, true);
        digits.transfer(acc2, 10 * decimals + 500);
        digits.transfer(acc3, 1 * decimals - 500);
        vm.startPrank(acc2);
        digits.transfer(acc3, 500);
        digits.transfer(acc3, 500);
        vm.startPrank(acc3);
        digits.transferFrom(acc3, acc2, 11);

        vm.startPrank(currentOwner);
        digits.setWhitelist(acc2, true);
        bool isWhitelisted = digits.whitelist(acc2);
        assertEq(isWhitelisted, true, "Acc2 should be whitelisted");
        console.log("Acc2 is whitelisted");

        vm.startPrank(acc2);
        uint256 acc2Balance = digits.balanceOf(acc2);
        console.log("Acc2 Balance: %s", acc2Balance);
        console.log("Acc2 Tokens: %s", acc2Balance / decimals);
        address ownerTokenId11 = digits.ownerOf(11);
        console.log("Owner TokenId 11: %s", ownerTokenId11);
        address ownerTokenId9 = digits.ownerOf(9);
        console.log("Owner TokenId 9: %s", ownerTokenId9);
        digits.transfer(acc3, 1 * decimals);
        console.log("Acc2 transferred 1E18 to acc3");

        acc2Balance = digits.balanceOf(acc2);
        console.log("Acc2 Balance: %s", acc2Balance);
        console.log("Acc2 Tokens: %s", acc2Balance / decimals);

        uint256 mintedTokens = digits.minted();
        for (uint256 index = 1; index <= mintedTokens; index++) {
            if (index != 10) {
                address ownerTokenId = digits.ownerOf(index);
                console.log("Owner TokenId %d: %s", index, ownerTokenId);

            } else {
                console.log("Owner TokenId %d: burnt", index);
            }
        }
        assertEq(mintedTokens, 12, "Minted tokens should be 12");
        console.log("Minted Tokens: %s", mintedTokens);
    }

    function test_Extra() public {
        vm.startPrank(currentOwner);
        digits.setWhitelist(currentOwner, true);
        digits.transfer(acc2, 10 * decimals + 500);
        digits.transfer(acc3, 1 * decimals - 500);
        vm.startPrank(acc2);
        digits.transfer(acc3, 500);
        digits.transfer(acc3, 500);
        vm.startPrank(acc3);
        digits.transferFrom(acc3, acc2, 11);
        vm.startPrank(currentOwner);
        digits.setWhitelist(acc2, true);
        digits.whitelist(acc2);
        vm.startPrank(acc2);

        digits.transfer(acc3, 4 * decimals);
        address ownerTokenId11 = digits.ownerOf(11);
        console.log("Owner TokenId 11: %s", ownerTokenId11);
        uint256 acc2Balance = digits.balanceOf(acc2);
        console.log("Acc2 Balance: %s", acc2Balance);
        console.log("Acc2 Tokens: %s", acc2Balance / decimals);

        /**
            acc2 bal 6999999999999999500
            acc2 addr 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF
        **/
        digits.transferFrom(acc2, acc3, 1);
        digits.transferFrom(acc2, acc3, 2);
        digits.transferFrom(acc2, acc3, 3);
        digits.transferFrom(acc2, acc3, 4);
        digits.transferFrom(acc2, acc3, 5);
        digits.transferFrom(acc2, acc3, 6);

        // No more tokens to transfer
        // digits.transferFrom(acc2, acc3, 7);

        acc2Balance = digits.balanceOf(acc2);
        console.log("Acc2 Balance: %s", acc2Balance);
        console.log("Acc2 Tokens: %s", acc2Balance / decimals);
        address ownerTokenId7 = digits.ownerOf(7);
        console.log("Owner TokenId 7: %s, acc2", ownerTokenId7);
    }
}
