// Changing the blockchain's state
const Token = artifacts.require("Token");

module.exports = function(deployer) {
    deployer.deploy(Token);
};