import './App.css';
import { ethers } from "ethers";
import Web3Modal from "web3modal";
import WalletConnectProvider from "@walletconnect/web3-provider";
import { use } from 'chai';
import { useState } from 'react';

import gen from './Gen.json'

//import {CoinbaseWalletSDK} from "@coinbase/wallet-sdk";

const genAddress = '0x5f095d8F0Bb3BFC75355Be996E8aAFD5ad95B3a8';


const providerOptions = {
  
  walletconnect: {
    package: WalletConnectProvider, // required
    options: {
      infuraId: "8231230ce0b44ec29c8682c1e47319f9" // required
    }
  }
  /*
  walletconnect: {
    package: CoinbaseWalletSDK, // required
    options: {
      infuraId: "8231230ce0b44ec29c8682c1e47319f9" // required
    }
  }
  */
};

function App() {

  const [web3Provider, setWeb3Provider] = useState(null)

  const handleConnect = async () => { 
    try {
      const web3Modal = new Web3Modal({
        cacheProvider: false, // optional
        providerOptions // required
      });
      const instance = await web3Modal.connect();
      const provider = new ethers.providers.Web3Provider(instance);
      console.log(provider)
      //const signer = provider.getSigner();
      if(provider) {
        setWeb3Provider(provider)
      }

    } catch (error) {
      console.error(error)
    }
  }

  async function getTotalSupply() {
        
    const provider = web3Provider;
    const signer = provider.getSigner();
    const contract = new ethers.Contract(
        genAddress,
        gen.abi,
        signer
    );
    try {
        const response = await contract.totalSupply();
        alert(`${response}/3333 Crazy Tigers have been MInted!`);
        console.log('response: ', response)
    } 
    catch (err) {
        console.log('error', err )
    }

}
  return (
    <div className="App">
      {
        web3Provider == null ? (
          <button onClick={handleConnect}>connect</button>
        ) : (
          <div>
          <p>connected</p>
          <p>Address: {web3Provider.provider.selectedAddress}</p>
          <button onClick={getTotalSupply}>supply</button>
          </div>
        )
      }
      
    </div>
  );
}

export default App;
