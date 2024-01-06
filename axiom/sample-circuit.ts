import {
  addToCallback,
  CircuitValue,
  getSolidityMapping,
} from "@axiom-crypto/client";

/// For type safety, define the input types to your circuit here.
/// These should be the _variable_ inputs to your circuit. Constants can be hard-coded into the circuit itself.
export interface CircuitInputs {
  blockNumber: CircuitValue;
  tokenAddress: CircuitValue;
  userAddress: CircuitValue;
  slot: CircuitValue;
}

/**
 * Prove a wallet holds an ERC-20 token Circuit
 * @param param0 
 */
export const proveHoldToken = async ({
  blockNumber,
  tokenAddress,
  userAddress,
}: CircuitInputs) => {
  // Since the blockNumber is a variable input, let's add it to the results that will be sent to my callback function:
  addToCallback(blockNumber);
  addToCallback(tokenAddress);
  addToCallback(userAddress);

  const tokenMapping = getSolidityMapping(blockNumber, tokenAddress, 1)
  // userAddress is the name of the key of the mapping
  const val = await tokenMapping.key(userAddress)
  // We add the result to the callback
  addToCallback(val);
  console.log("val:", val)
};
