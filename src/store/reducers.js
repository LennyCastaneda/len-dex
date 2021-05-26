import { combineReducers } from 'redux';

// When the action comes in it handles WEB3_LOADED, updates state, returns connection key with Web3 connection
function web3(state = {}, action) {
  switch (action.type) {
    case 'WEB3_LOADED':
      // update state; return new object containing existing state and extends it
      return { ...state, connection: action.connection }
    case 'WEB3_ACCOUNT_LOADED':
      return { ...state, account: action.account }
    default:
      return state
  }
}

function token(state = {}, action) {
  switch (action.type) {
    case 'TOKEN_LOADED':
      return { ...state, loaded: true, contract: action.contract }
    case 'TOKEN_BALANCE_LOADED':
      return { ...state, balance: action.balance }
    default:
      return state
  }
}

const rootReducer = combineReducers({
  web3,
  token
})

export default rootReducer