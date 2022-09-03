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

function _sha3(data){
  sha3_data = sha3(data);
  console.log(sha3_data);
  //return sha3_Data;
}

module.exports = {
  decodeParams: _decodeParameters,
  sha3: _sha3,
  bn: _bn,
};
