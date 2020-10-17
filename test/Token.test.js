const { result } = require('lodash');

const Token = artifacts.require("./Token");

require('chai')
  .use(require('chai-as-promised'))
  .should()

contracts_build_directory('Token', (accounts) => {

  describe('deployment', () => {
    it('tracks the name', async () => {

      // Read token name here...
      const token = await Token.new()

      // Token name is "LenCoin"
      const result = await token.name()

      // Check the token name is 'LenCoin'
      result.should.equal('LenCoin')
    })
  })
})