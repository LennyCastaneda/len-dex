import Web3 from 'web3'
import {
  web3Loaded
} from "./actions"

// Trigger an action and dispatch it with Redux, dispatch will be injected into reducer to update state
export const loadWeb3 = async (dispatch) => {
  if (typeof window.ethereum !== 'undefined') {
    
    const web3 = new Web3(window.ethereum)

    // Send this action: 'web3Loaded' to Redux
    dispatch(web3Loaded(web3))

    return web3
  } else {
    window.alert('Please install MetaMask')
    window.location.assign("https://metamask.io/")
  }
}