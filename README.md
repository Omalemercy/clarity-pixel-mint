# PixelMint
A platform for minting pixel art NFTs on the Stacks blockchain.

## Features
- Mint pixel art NFTs with customizable attributes
- Store pixel art data on-chain
- Transfer NFTs between accounts
- View NFT metadata and ownership information
- Maximum pixel art size: 32x32 pixels

## Setup and Installation
1. Clone the repository
2. Install Clarinet (if not already installed)
3. Run `clarinet check` to verify the contract
4. Run `clarinet test` to run the test suite

## Usage Examples
```clarity
;; Mint a new pixel art NFT
(contract-call? .pixel-mint mint-pixel-art 
  "My Pixel Art" 
  {width: u32, height: u32, pixels: "0xFF..."} 
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; Transfer NFT
(contract-call? .pixel-mint transfer 
  u1 
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM 
  'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)

;; Get NFT metadata
(contract-call? .pixel-mint get-token-metadata u1)
```

## Dependencies
- Clarity language
- Clarinet for testing and deployment
