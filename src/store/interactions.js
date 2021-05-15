import {
  web3Loaded
} from "./actions"

// Trigger an action and dispatch it with Redux, dispatch will be injected into reducer to update state
export const loadWeb3 = (dispatch) => {
  const web3 = new Web3(window.ethereum)
  dispatch(web3Loaded(web3))
  return web3
}