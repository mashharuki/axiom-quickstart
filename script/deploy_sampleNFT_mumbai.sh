source ./.env
forge create src/AxiomSampleNFT.sol:AxiomSampleNFT --private-key $PRIVATE_KEY_GOERLI --rpc-url $PROVIDER_URI_MUMBAI --verify --etherscan-api-key $POLYGONSCAN_API_KEY --constructor-args "0xf15cc7B983749686Cd1eCca656C3D3E46407DC1f" "80001" "0x933ef21f3f91da615fab362ab2b6eedaa201afbe5e7de7c12b358e292c0fbd7c"
