require 'digest/sha3'
require 'open3'

# The file path which JS file which contains the functions we need to call
$js_file_path = '/Users/mac/VSCodes/abi-decoder/jscode/index'

$state = {
    "savedABIs"=> [],
    "methodIDs"=> {},
}
  
def _getABIs()
    return $state['savedABIs']
end

# The MethodIDs is a hash, and the hash key(signature) is the first 8 bits of encoded method name.
def _getMethodIDs()
  return $state['methodIDs']
end

# The function to generate params while input type is tuple
def generate_params(input)
  if input['type'] == "tuple"
    return "(" + input['components'].map{|cp| generate_params(cp)}.join(",") + ")"
  end
  return input['type']
end

def addABI(abiArray)
    if abiArray.instance_of? Array
        abiArray.each do |abi|
            if not abi['name'].nil?
              # Concat method name and its parameters
              params = abi['name'] +"(" +abi['inputs'].map{|ipt| generate_params(ipt)}.join(",") +")"
              # Generate sha3 signature of method and its params
              signature = Digest::SHA3.hexdigest(
                params, 
                256
              )
            end
            
            # Add abi hash with method signature
            if abi['type'] == 'event'
              $state['methodIDs'][signature] = abi
            else
              $state['methodIDs'][signature.slice(0, 8)] = abi
            end
        end
        
        # Update saved ABIs
        $state['savedABIs'] = $state['savedABIs'].concat(abiArray)
    else
        raise "Expected ABI array, got #{abiArray.class}"
    end
end

def _removeABI(abiArray)
  if abiArray.instance_of? Array
    abiArray.each do |abi|
        if not abi['name'].nil?
          params = abi['name'] +"(" +abi['inputs'].map{|ipt| generate_params(ipt)}.join(",") +")"
          signature = Digest::SHA3.hexdigest(
            params, 
            256
          )
        end

        if abi['type'] == 'event'
          $state['methodIDs'].delete(signature.slice(2))
        else
          $state['methodIDs'].delete(signature.slice(2, 10))
        end
      end
  else
      raise "Expected ABI array, got #{abiArray.class}"
  end
end

# Execute command line in ruby codes, and return output
def exec_cmd_and_return(cmd)
  stdout,stderr,status = Open3.capture3(cmd)
    STDERR.puts stderr
  if status.success?
    return stdout.strip()
  else
    STDERR.puts "OH NO!"
  end
end

 # call javascript function "decodeParams", and parse result to ruby data structure
def decode_params(jsFilePath, inputs, data) 
  ipts = inputs.to_s.gsub("=>", ":").gsub('"', '\"')
  cmd = "node -e \"require('#{jsFilePath}').decodeParams('#{ipts}', '#{data}')\""
  output = exec_cmd_and_return(cmd)

  result = output.slice(7, output.length).gsub(":", "=>")
  result_split = result.split("=>")
  result_split.each do |spt|
    last_val = spt.split(" ").last
    if (not last_val.include? "'") && (not last_val.include? '"')
       result = result.gsub(last_val + "=>", "\"#{last_val}\"=>")
    end 
  end

  return eval(result.gsub("null", "nil"))
end

# call javascript function "bn", and parse result to ruby data structure
def bn(jsFilePath, value)
  cmd = "node -e \"require('#{jsFilePath}').bn('#{value}')\""
  output = exec_cmd_and_return(cmd)
  return output.to_s
end

# decode data according to the specific abi format
def decodeMethod(data)
  # Get first 8 bits of encoded method data, the fisrt 2 bits "0x" should be ignored
  methodID = data.slice(2, 8); 
  # Get specific abi item according to methodID
  abiItem = $state['methodIDs'][methodID]

  if not abiItem.nil?
    # Get decoded data via call JS fucntion
    decoded = decode_params($js_file_path, abiItem['inputs'], data.slice(10, data.length))
    
    # Init return data
    retData = {
      "name" => abiItem['name'],
      "params" => [],
    }
    
    # process decoded data bases on its length according to different type
    for i in 0..(decoded['__length__'] - 1)
      param = decoded[i.to_s]
      parsedParam = param;
      isUint = abiItem['inputs'][i]['type'].index("uint") === 0
      isInt = abiItem['inputs'][i]['type'].index("int") === 0
      isAddress = abiItem['inputs'][i]['type'].index("address") === 0

      if isUint || isInt
        if param.class == Array
          parsedParam = param.map{|val| bn($js_file_path, val)}     
        else
          parsedParam = bn($js_file_path, param)
        end
      end

      if isAddress
        if param.class == Array
          parsedParam = param.map{|p| p.downcase}
        else
          if param.class == String
            parsedParam = param.downcase
          end
        end
      end
      
      # push processed hash data into array
      retData['params'] << {
        "name"=> abiItem['inputs'][i]['name'],
        "value"=> parsedParam,
        "type"=> abiItem['inputs'][i]['type'],
      }
      
    end

    return retData
  end
end
