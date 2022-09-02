require 'test/unit'
require File.dirname(__FILE__) + '/index.rb'

class TestDecoder < Test::Unit::TestCase
  def test_decode_data
    testABI = [{"inputs"=> [{"type"=> "address", "name"=> ""}], "constant"=> true, "name"=> "isInstantiation", "payable"=> false, "outputs"=> [{"type"=> "bool", "name"=> ""}], "type"=> "function"}, {"inputs"=> [{"type"=> "address[]", "name"=> "_owners"}, {"type"=> "uint256", "name"=> "_required"}, {"type"=> "uint256", "name"=> "_dailyLimit"}], "constant"=> false, "name"=> "create", "payable"=> false, "outputs"=> [{"type"=> "address", "name"=> "wallet"}], "type"=> "function"}, {"inputs"=> [{"type"=> "address", "name"=> ""}, {"type"=> "uint256", "name"=> ""}], "constant"=> true, "name"=> "instantiations", "payable"=> false, "outputs"=> [{"type"=> "address", "name"=> ""}], "type"=> "function"}, {"inputs"=> [{"type"=> "address", "name"=> "creator"}], "constant"=> true, "name"=> "getInstantiationCount", "payable"=> false, "outputs"=> [{"type"=> "uint256", "name"=> ""}], "type"=> "function"}, {"inputs"=> [{"indexed"=> false, "type"=> "address", "name"=> "sender"}, {"indexed"=> false, "type"=> "address", "name"=> "instantiation"}], "type"=> "event", "name"=> "ContractInstantiation", "anonymous"=> false}]

    testData = "0x53d9d9100000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000a6d9c5f7d4de3cef51ad3b7235d79ccc95114de5000000000000000000000000a6d9c5f7d4de3cef51ad3b7235d79ccc95114daa"

    addABI(testABI)
    result = decodeMethod(testData)

    assert_equal("create", result['name'], 'Incorrect')
    assert_equal(Array, result['params'].class, 'Incorrect')
    assert_equal("_owners", result['params'][0]['name'], 'Incorrect')
    assert_equal(
      ["0xa6d9c5f7d4de3cef51ad3b7235d79ccc95114de5", "0xa6d9c5f7d4de3cef51ad3b7235d79ccc95114daa"], result['params'][0]['value'], 'Incorrect')
    assert_equal("address[]", result['params'][0]['type'], 'Incorrect')
    assert_equal("_required", result['params'][1]['name'], 'Incorrect')
    assert_equal("1", result['params'][1]['value'], 'Incorrect')
    assert_equal("uint256", result['params'][1]['type'], 'Incorrect')
    assert_equal("_dailyLimit", result['params'][2]['name'], 'Incorrect')
    assert_equal("0", result['params'][2]['value'], 'Incorrect')
    assert_equal("uint256", result['params'][2]['type'], 'Incorrect')
    #assert_equal (14,n.add(4),'This test about add is failure!')
  end

  def test_decode_data_with_array
    testData = "0x3727308100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003"

    testArrNumbersABI = [{"constant"=>false,"inputs"=>[{"name"=>"n","type"=>"uint256[]"}],"name"=>"numbers","outputs"=>[{"name"=>"","type"=>"uint256"}],"payable"=>false,"stateMutability"=>"nonpayable","type"=>"function"}]

    addABI(testArrNumbersABI)
    result = decodeMethod(testData)

    assert_equal("numbers", result['name'], 'Incorrect')
    assert_equal(Array, result['params'].class, 'Incorrect')
    assert_equal("n", result['params'][0]['name'], 'Incorrect')
    assert_equal(["1", "2", "3"], result['params'][0]['value'], 'Incorrect')
    assert_equal("uint256[]", result['params'][0]['type'], 'Incorrect')

  end

  def test_decode_data_with_tuple
    testData = "0xd4f8f1310000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000022000000000000000000000000000000000000000000000000000000000000002a000000000000000000000000000000000000000000000000000000000000000a000000000000000000000000050a5cf333fc36a18c8f96b1d1e7a2b013c6267ac000000000000000000000000000000000000000000000000000000000000000000000000000000000000000046dccf96fe3f3beef51c72c68a1f3ad9183a6561000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000254dffcd3277c0b1660f6d42efbb754edababc2b00000000000000000000000000000000000000000000000000000000000f4240000000000000000000000000000000000000000000000000000000059682f000000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000642ac0df260000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000b68656c6c6f20776f726c640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000411de3d1ce0d680d92171da7852a1df1a655280126d809b6f10d046a60e257c187684da02cf3fb67e6939ac48459e26f6c0bfdedf70a1e8f6921a4a0ff331448641b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
    abiV2 = [{"constant"=>false,"inputs"=>[{"components"=>[{"components"=>[{"internalType"=>"address","name"=>"target","type"=>"address"},{"internalType"=>"uint256","name"=>"gasLimit","type"=>"uint256"},{"internalType"=>"uint256","name"=>"gasPrice","type"=>"uint256"},{"internalType"=>"bytes","name"=>"encodedFunction","type"=>"bytes"}],"internalType"=>"struct EIP712Sig.CallData","name"=>"callData","type"=>"tuple"},{"components"=>[{"internalType"=>"address","name"=>"senderAccount","type"=>"address"},{"internalType"=>"uint256","name"=>"senderNonce","type"=>"uint256"},{"internalType"=>"address","name"=>"relayAddress","type"=>"address"},{"internalType"=>"uint256","name"=>"pctRelayFee","type"=>"uint256"}],"internalType"=>"struct EIP712Sig.RelayData","name"=>"relayData","type"=>"tuple"}],"internalType"=>"struct EIP712Sig.RelayRequest","name"=>"relayRequest","type"=>"tuple"},{"internalType"=>"bytes","name"=>"signature","type"=>"bytes"},{"internalType"=>"bytes","name"=>"approvalData","type"=>"bytes"}],"name"=>"relayCall","outputs"=>[],"payable"=>false,"stateMutability"=>"nonpayable","type"=>"function"}]
    
    addABI(abiV2)
    result = decodeMethod(testData)

    assert_equal("relayCall", result['name'], 'Incorrect')
    assert_equal(Array, result['params'].class, 'Incorrect')
    assert_equal("relayRequest", result['params'][0]['name'], 'Incorrect')
    assert_equal("tuple", result['params'][0]['type'], 'Incorrect')
    assert_equal("signature", result['params'][1]['name'], 'Incorrect')
    assert_equal("bytes", result['params'][1]['type'], 'Incorrect')
    assert_equal("0x1de3d1ce0d680d92171da7852a1df1a655280126d809b6f10d046a60e257c187684da02cf3fb67e6939ac48459e26f6c0bfdedf70a1e8f6921a4a0ff331448641b", result['params'][1]['value'], 'Incorrect')
    assert_equal(nil, result['params'][2]['value'], 'Incorrect')
    assert_equal("approvalData", result['params'][2]['name'], 'Incorrect')
    assert_equal("bytes", result['params'][2]['type'], 'Incorrect')
  end
  
end
