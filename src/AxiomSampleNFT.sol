// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {AxiomV2Client} from "axiom-v2-contracts/contracts/client/AxiomV2Client.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AxiomSampleNFT is AxiomV2Client, ERC721 {
    /// @dev The unique identifier of the circuit accepted by this contract.
    bytes32 immutable QUERY_SCHEMA;
    /// @dev The chain ID of the chain whose data the callback is expected to be called from.
    uint64 immutable SOURCE_CHAIN_ID;
    uint256 private _nextTokenId;

    /// @notice Construct a new AxiomNonceIncrementor contract.
    /// @param  _axiomV2QueryAddress The address of the AxiomV2Query contract.
    /// @param  _callbackSourceChainId The ID of the chain the query reads from.
    constructor(
      address _axiomV2QueryAddress, 
      uint64 _callbackSourceChainId,
      bytes32 _querySchema
    )
      AxiomV2Client(_axiomV2QueryAddress)
      ERC721("AxiomSampleNFT", "ASNFT")
    {
      QUERY_SCHEMA = _querySchema;
      SOURCE_CHAIN_ID = _callbackSourceChainId;
    }

    /// @inheritdoc AxiomV2Client
    function _validateAxiomV2Call(
      AxiomCallbackType, // callbackType,
      uint64 sourceChainId,
      address, // caller,
      bytes32 querySchema,
      uint256, // queryId,
      bytes calldata // extraData
    ) internal view override {
      require(sourceChainId == SOURCE_CHAIN_ID, "Source chain ID does not match");
      require(querySchema == QUERY_SCHEMA, "Invalid query schema");
    }

    /// @inheritdoc AxiomV2Client
    function _axiomV2Callback(
      uint64, // sourceChainId,
      address, // caller,
      bytes32, // querySchema,
      uint256, // queryId,
      bytes32[] calldata axiomResults,
      bytes calldata // extraData
    ) internal override {
      address userAddress = address(uint160(uint256(axiomResults[2])));
      uint256 value = uint256(axiomResults[3]);

      // check
      require(value > 0, "minter must have Link Token!!");

      uint256 tokenId = _nextTokenId++;
      _safeMint(userAddress, tokenId);
    }
}
