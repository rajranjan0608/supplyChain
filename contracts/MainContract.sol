pragma solidity >=0.4.0 <0.6.0;
import "./User.sol";
import "./Tender.sol";

contract MainContract {

	uint[] tenderID;	// Stores the unique tender ID deployed
	mapping(uint => address) tenders;	// tenderID => tenderContractAddress
	User database;

	constructor() public {
		database = new User(msg.sender);
	}

	modifier onlyAdmin() {
		require(database.getUserType(msg.sender) == 2, "Only Admin can call this function");
		_;
	}

	/// Gives Bidder privileges to the given addresses
	function approveBidder(address[] calldata _newBidder) external onlyAdmin {
		for(uint i = 0; i < _newBidder.length ; ++i)
		{
			database.setUserType(_newBidder[i], 1);		// Check if implementing function their better?
		}
	}

	/// Gives Admin privileges to the given addresses
	function approveAdmin(address[] calldata _newAdmin) external onlyAdmin {
		for(uint i = 0; i < _newAdmin.length ; ++i)
		{
			database.setUserType(_newAdmin[i], 2);
		}
	}

	/// Returns the user level
	function getUserType(address _node) external view returns(uint8) {
		return database.getUserType(_node);
	}

	/// @dev Creates a new tender contract and returns its address
	function createTender(uint _tenderID, uint _bidTime,string calldata _title,string calldata _desc, string calldata _item, uint _qty) external onlyAdmin returns(address) {
		require(tenders[_tenderID ] == address(0), "A Tender already exists with the given tender ID");
        Tender tender = new Tender(_tenderID, _bidTime, _title, _desc, address(database), _item, _qty);
		tenders[_tenderID] = address(tender);
		tenderID.push(_tenderID);
		return tenders[_tenderID];
	}

	/// returns the contract address of the tender with the given tenderID
	function getTenderByID(uint _tenderID) external view returns(address) {
		require(tenders[_tenderID] != address(0), "No Tender Found!");
		return tenders[_tenderID];
	}

	/// returns an array of all the tender contract's address deployed
	function getAllTenders() external view returns(address[] memory) {
	    address[] memory tender = new address[](tenderID.length);
		for(uint i = 0; i < tenderID.length; ++i)
		{
			tender[i] = tenders[tenderID[i]];
		}
		return tender;
	}

	/// @param
	/// _mode := 0 To return Active Tenders
	/// _mode := 1 To return Closed Tenders
	/// @dev Can be made more flexible
	function getTendersByStatus(uint _mode) external view returns(address[] memory) {
		address[] memory tender = new address[](tenderID.length);
		uint idx = 0;
		for(uint i = 0; i < tenderID.length; ++i)
		{
			if ( (Tender(tenders[tenderID[i]]).isActive()^_mode) == 1)
			{
				tender[idx++] = tenders[tenderID[i]];
			}
		}
		return tender;
	}
}