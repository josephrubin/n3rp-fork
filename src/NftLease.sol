// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {SafeMath} from "openzeppelin/SafeMath.sol";
// import {PRBMathSD59x18} from "../lib/prb-math/contracts/PRBMathSD59x18.sol";

abstract contract LeaseNFT is ERC721 {

    // Use PRBMathSD59x18 or SafeMath
    using SafeMath for uint256;

    // The address of the original owner
    address payable public immutable lenderAddress;

    // The address of the tempory borrower
    address public immutable borrowerAddress;

    // The ID of the NFT to lend
    uint256 public tokenId;

    // The expiration time of the lease
    uint256 public immutable expiry;

    // The amount of ETH the borrower must pay the lender in order to lease the specified NFT for the specified period
    uint256 public immutable costToLease;

    // The amount of additional ETH the lender requires as collateral
    uint256 public immutable collateral;

    // The interest rate the borrower must pay if the expiration is exceeded
    uint256 public immutable interestRate;

    // Errors
    error InsufficientPayment();
    error FailedToSendEther();

    constructor(
        address payable _lenderAddress,
        address payable _borrowerAddress,
        uint256 _tokenId,
        string memory _name,
        string memory _symbol,
        uint256 _expiry,
        uint256 _costToLease,
        uint256 _collateral,
        uint256 _interestRate
    ) ERC721(_name, _symbol) {
        // TODO: Require that the _lenderAddress owns the _leasedNFT
        require(_expiry > block.timestamp, "Expiry is before current time");
        // TODO: Require that the _borrowerAddress has more than _costToLease + _collateral
        
        lenderAddress = _lenderAddress;
        borrowerAddress = _borrowerAddress;
        tokenId = _tokenId
        expiry = _expiry;
        costToLease = _costToLease;
        collateral = _collateral;
        interestRate = _interestRate;

        _sendInitialPayment();
        _storeCollateral();
        _transfer();
    }

    // Send the initial payment from the borrower to the lender
    function _sendInitialPayment() private {
        (bool sent, ) = msg.sender.call{value: msg.value}("");
        if (!sent) {
            revert FailedToSendEther();
        }
    }

    // Store the required collateral in this contract
    function _storeCollateral() private {

    }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        emit Transfer(_from, _to, _tokenId);
    }

    // Once the collateral is in the contract, the lender approves the tranfer
    function approveTransfer(address _to, uint256 _tokenId) external payable {
        // Note: this function must be called by the lender
        transferFrom(msg.sender, _to, _tokenId);
    }

    // Once the lender has approved the transfer, transfer the NFT to the borrower
    function transferOwnership(address _from, uint256 tokenId) external payable {
        // Note: this function is called by the borrower
        transferFrom(_from, msg.sender, _tokenId);
    }

}


/*
Questions:
    1. Are all my functions/variables properly scoped?
    2. Do I use memory/storage in the correct places?
    3. Which functions need to be payable?
    4. Am I using immutable correctly?
    5. Do I use SafeMath/PRBMathSD59x18 in the correct places?
    6. What license should I use for this? MIT? GPL-3.0? Unliscence?
    7. Are there other error conditions I should consider?
    8. Who calls this contract? How do we make sure both parties consent to this agreement?
    9. What are clearest variable names?
        a. originalOwner vs lenderAddress?
        b. temporaryOwner vs borrowerAddress?
        c. expiry vs expirationTime?
        d. costToLease vs initialPayment?
    10. How can this be exploited?
    11. Should the LeaseNFT contract be abstract or should I implement each of the ERC721 functions?
    11. How could we accept other forms of collateral other than ETH?
*/