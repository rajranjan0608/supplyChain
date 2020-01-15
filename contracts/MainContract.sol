pragma solidity ^0.6.0;

contract MainContract {

	enum userChoice {normal,bidder,admin};
	mapping(address => userChoice) userType;
	mapping(uint256 => address) Tenders;	// Key := tenderID
	uint256[] tenderID;

	constructor(){
		userType[msg.sender] = userChoice.admin;
	}


	modifier onlyAdmin() {
		require( userType[msg.sender] == userChoice.admin , "Only Admin can call this function.");
		_;
	}


	function approveBidder(address[] memory _newBidder) external onlyAdmin {

		for(uint i = 0; i < _newBidder.length ; ++i)
		{
			userType[ _newBidder[i] ] = userChoice.bidder;
		}
	}


	function approveAdmin(address[] memory _newAdmin) external onlyAdmin {

		for(uint i = 0; i < _newAdmin.length ; ++i)
		{
			userType[ _newAdmin[i] ] = userChoice.admin;
		}
	}


	function createTender(uint256 _tenderID, string[] memory _requirments) external onlyAdmin returns(address) {
		require(Tenders[ _tenderID ] == address(0), "A Tender already exists with the given tender ID");
		Tenders[ _tenderID ] = Tender( _tenderID, _requirments);
		tenderID.push( _tenderID );
		return Tenders[ _bidID ];
	}


	function getTender(uint256 _tenderID) external view returns(address) {
		require( Tenders[ _tenderID ] != address(0), "No Tender Found!");
		return Tender[ _tenderID ];
	}
}