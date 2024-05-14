// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./openzeppelin/Pausable.sol";

/**
    @title Represents a bridged Centrifuge asset.
    @author ChainSafe Systems.
 */
contract CentrifugeAsset is Pausable {
  mapping (bytes32 => bool) public _assetsStored;

  event AssetStored(bytes32 indexed asset);

  /**
    @notice Marks {asset} as stored.
    @param asset Hash of asset deposited on Centrifuge chain.
    @notice {asset} must not have already been stored.
    @notice Emits {AssetStored} event.
   */
  function store(bytes32 asset) whenNotPaused external {
      require(!_assetsStored[asset], "asset is already stored");

      _assetsStored[asset] = true;
      emit AssetStored(asset);
  }

  function pause() public {
      _pause();
  }

  function unpause() public {
      _unpause();
  }
}