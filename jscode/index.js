const { sha3, BN } = require("web3-utils");
const abiCoder = require("web3-eth-abi");


function _decodeParameters(inputs, data){
  decoded = abiCoder.decodeParameters(eval(inputs), data)
  console.log(decoded);
  //decoded;
}

function _bn(val){
  result = new BN(val).toString();
  console.log(result);
  //return result;
}

module.exports = {
  decodeParams: _decodeParameters,
  bn: _bn,
};
