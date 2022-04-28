require('dotenv').config()
const ethers = require('ethers');
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY)// const wallet = new ethers.Wallet(process.env.KEY);
async function signTransaction(receiverAddress,action,timestamp,bankBalance,amount) {
  const domain = {
    name: "COBE_CBS",
    version: "1",
    chainId: 80001, //put the chain id
    verifyingContract: "0x28FBC173F6efDa61C0F0f297e251de73aC741129" //contract address
  }

  const types ={

    BackendSigner: [
      {name: 'receiverAddress', type: 'address'},
      {name: 'action', type: 'bool'},
      {name: 'timestamp', type: 'uint256'},
      {name: 'bankBalance', type: 'uint256'},
      {name: 'amount', type: 'uint256'},
    ]
  }

  const value = {
    receiverAddress: receiverAddress,
    action: action,
    timestamp: timestamp,
    bankBalance: bankBalance,
    amount: amount,
  };

  const sign = await wallet._signTypedData(domain,types,value)
  console.log(sign);
}
signTransaction("0xeBA41eAa32841629B1d4F64852d0dadf70b0c665", true,129,9000000000000000,5000000000000000)

module.exports = { signTransaction };

//["0x79BF6Ab2d78D81da7d7E91990a25A81e93724a60",502,"0x51e67d0779ce45bf9402af999c68478a89e6f6e03140417877d8a8c01eec421c69deddbd8a9ed9704958b8e9b50806e6bfd3a2dd60d3ca13fa606c42adc6c64e1b"]
["0xeBA41eAa32841629B1d4F64852d0dadf70b0c665", true,129,9000000000000000,5000000000000000,"0xd32e5cb6a1f91d694718786289cc7939d4e63422f04f5f5c733d9c7f14b18a673e389b3b9affa7e3a934fe3aa86bac06486d8ef6c6460540d0715607163b33471b"]