const MainContract = artifacts.require("MainContract");
const Tender = artifacts.require("Tender");

module.exports = function(deployer) {
	deployer.deploy(MainContract);
	deployer.deploy(Tender, 0, 1, 'This is title', 'This is Description', '0xEBcf3B237ee3E641B66d4044E5A19f3b8A994aA4', 'Product', 0);
};