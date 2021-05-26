import Web3 from 'web3'
import {
  web3Loaded,
  web3AccountLoaded,
  tokenLoaded
} from "./actions"
import Token from '../abis/Token.json'

// Trigger an action and dispatch it with Redux, dispatch will be injected into reducer to update state
export const loadWeb3 = async (dispatch) => {
  
  // Modern DApp Browsers
  if (typeof window.ethereum !== 'undefined') {
    const web3 = new Web3(window.ethereum)
    try {
      // User has allowed account access to DApp...
        window.ethereum.enable().then(function () {
      });
    } catch (error) {
      // User has denied account access to DApp...
      console.log(error)
    }  
    // Send this action: 'web3Loaded' to Redux
    dispatch(web3Loaded(web3))
    return web3

  } else {
    // Non-DApp Browsers
    window.alert('Please install MetaMask')
    window.location.assign("https://metamask.io/")
  }
}

export const loadAccount = async (web3, dispatch) => {
    const accounts = await web3.eth.getAccounts()
    const account = accounts[0]
    dispatch(web3AccountLoaded(account))
    return account
}

export const loadToken = async (web3, networkId, dispatch) => {
  try {
    const token = new web3.eth.Contract(Token.abi, Token.networks[networkId].address)
    dispatch(tokenLoaded(token))
    return token
  } catch (error) {
      window.alert('Contract not deployed to the current network. Please select another network with Metamask.')
      return null
  }
}