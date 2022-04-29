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
signTransaction("0xeBA41eAa32841629B1d4F64852d0dadf70b0c665","0x79BF6Ab2d78D81da7d7E91990a25A81e93724a60",true,13422,9000000000000000,3000000000000000)

module.exports = { signTransaction };

//["0xeBA41eAa32841629B1d4F64852d0dadf70b0c665","0x79BF6Ab2d78D81da7d7E91990a25A81e93724a60",true,13422,9000000000000000,3000000000000000,"0xc8c7a5237639237eef5a27b3d3df5083ef786cba1421dd180242a75edc12d6682c84cb98e424cd6cc0a3623946daa7a7d65a929e576e9162f0ac179d8f0b4f941c"]
