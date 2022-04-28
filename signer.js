require('dotenv').config()
const ethers = require('ethers');
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY)// const wallet = new ethers.Wallet(process.env.KEY);
async function signTransaction(senderAddress, receiverAddress,action,timestamp,bankBalance,amount) {
  const domain = {
    name: "COBE",
    version: "1",
    chainId: 80001, //put the chain id
    verifyingContract: "0xe0DAf75dED0D95d3D8ECc479D0A83e9FB8E7DC77" //contract address
  }

  const types ={

    BackendSigner: [
      {name: 'senderAddress', type: 'address'},
      {name: 'receiverAddress', type: 'address'},
      {name: 'action', type: 'bool'},
      {name: 'timestamp', type: 'uint256'},
      {name: 'bankBalance', type: 'uint256'},
      {name: 'amount', type: 'uint256'},
    ]
  }

  const value = {
    senderAddress: senderAddress,
    receiverAddress: receiverAddress,
    action: action,
    timestamp: timestamp,
    bankBalance: bankBalance,
    amount: amount,
  };

  const sign = await wallet._signTypedData(domain,types,value)
  console.log(sign);
}
signTransaction("0xeBA41eAa32841629B1d4F64852d0dadf70b0c665","0x79BF6Ab2d78D81da7d7E91990a25A81e93724a60", true,127,2000000000000000,500000000000000)

module.exports = { signTransaction };

//["0x79BF6Ab2d78D81da7d7E91990a25A81e93724a60",502,"0x51e67d0779ce45bf9402af999c68478a89e6f6e03140417877d8a8c01eec421c69deddbd8a9ed9704958b8e9b50806e6bfd3a2dd60d3ca13fa606c42adc6c64e1b"]
["0xeBA41eAa32841629B1d4F64852d0dadf70b0c665","0x79BF6Ab2d78D81da7d7E91990a25A81e93724a60", true,127,2000000000000000,500000000000000,"0xe3d5ee0e7edfcc4ea8acc25abc0bc04f906f279f0f539f2dcb07c059de10761360ed1e73704a1c7a4ed9622c946cadeaad70a351c670ab6f6c7d61049f8a5a001b"]