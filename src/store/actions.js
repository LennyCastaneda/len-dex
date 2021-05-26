export function web3Loaded(connection) {
  return {
    type: 'WEB3LOADED',
    connection  // sames as connection = connection
  }
}

export function web3AccountLoaded(account) {
  return {
    type: 'WEB3_ACCOUNT_LOADED',
    account
  }
}

  export function tokenLoaded(contract) {
    return {
      type: 'TOKEN_LOADED',
      contract
    }
  }