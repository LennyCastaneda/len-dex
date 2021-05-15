export function web3Loaded(connection) {
  return {
    type: 'WEB3LOADED',
    connection  // sames as connection = connection
  }
}