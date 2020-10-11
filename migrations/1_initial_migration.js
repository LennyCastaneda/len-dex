// Changing the blockchain's state
const Migrations = artifacts.require("Migrations");

module.exports = function(deployer) {
    deployer.deploy(Migrations);
};