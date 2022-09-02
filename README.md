# Set up
## Install nodeJS packages
    npm install

## Install ruby gem
    gem install digest-sha3
    gem install test-unit
    gem install open3

## Please install it separately if you find any packages are not install

# Test
just execute test.rb, it has 3 test cases, to test decode of normal data, data has array and data has tuple.

# Clarifications
## ExecJs and commonjs
I only could execute pure simple javascript codes, but it always could not require other packages in JS file(I am not quite sure if I implemented it in a correct way). 

In addition, The version of my MacOS is 10.13.6, and it always fail while I want to upgrade my ruby version to greater than 2.6.0. It really block me to install some gem file which I found from internet

## Currect solution to excute JS function from Ruby
use node command line to execute node JS specific function:
    node -e "require('#{jsFilePath}').decodeParams('#{ipts}', '#{data}')"

It will call the function "decodeParams" which in specific JS file, and this function has 2 input parameters.

Then I use gem package "open3" to execute command line from Ruby codes; Then parse its output to regualar Ruby data structure with customized fucntions.

## The functions which I called from node JS
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

## The pure Ruby codes is possible if I could understand the logic of encode and decode of ABi
It could be done if really need the version of pure ruby. but I really not good at Ruby, and cost most of time to learn the syntax. So current solution is a kind of workaround. 


## The detailed codes you can find in index.rb