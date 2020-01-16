pragma solidity >=0.4.21 <=0.6.0;
pragma experimental ABIEncoderV2;

// contract Tender {
//     constructor(uint _tenderID, string[] memory _requirments) public {}
// }

contract MainContract {

	enum privilege { normal, bidder, admin}	// Three Types of user
	mapping(address => privilege) public userType; // Stores the privilege of users
	mapping(uint => address) Tenders;	// tenderID => tenderContractAddress
	uint[] tenderID;	// Stores the unique tender ID deployed

	constructor() public {
		userType[msg.sender] = privilege.admin;
	}

	modifier onlyAdmin() {
		require(userType[msg.sender] == privilege.admin, "Only Admin can call this function.");
		_;
	}

	function approveBidder(address[] calldata _newBidder) external onlyAdmin {
		for(uint i = 0; i < _newBidder.length ; ++i)
		{
			userType[_newBidder[i]] = privilege.bidder;
		}
	}

	function approveAdmin(address[] calldata _newAdmin) external onlyAdmin {
		for(uint i = 0; i < _newAdmin.length ; ++i)
		{
			userType[_newAdmin[i]] = privilege.admin;
		}
	}

	/// @dev Creates a new tender contract
	function createTender(uint _tenderID, uint _bidTime, string[] calldata _req) external onlyAdmin returns(address) {
		require(Tenders[_tenderID ] == address(0), "A Tender already exists with the given tender ID");

		Tender tender = new Tender(_tenderID, _bidTime, _req);
		Tenders[_tenderID] = address(tender);
		tenderID.push(_tenderID);
		return Tenders[_tenderID];
	}

	/// returns the contract address of the tender with the given tenderID
	function getTender(uint _tenderID) external view returns(address) {
		require( Tenders[_tenderID] != address(0), "No Tender Found!");
		return Tenders[_tenderID];
	}

	function getAllTenders() external view returns(address[] memory) {
	    address[] memory tender = new address[](tenderID.length);
		for(uint i = 0; i < tenderID.length; ++i)
		{
			tender[i] = Tenders[tenderID[i]];
		}
		return tender;
	}

	/// @param
	/// _mode := 0 To return Active Tenders
	/// _mode := 1 To return Closed Tenders
	/// @dev Can be made more flexible
	function getTendersByStatus(uint8 _mode) external view returns(address[] memory) {
		address[] memory tender = new address[](tenderID.length);
		for(uint i = 0, uint idx = 0; i < tenderID.length; ++i)
		{
			if ( (Tender(Tenders[tenderID[i]]).isActive()^_mode) == 1)	// isActive() to be implemented!!!
			{
				tender[idx++] = Tenders[tenderID[i]];
			}
		}
		return tender;
	}
}