pragma solidity >=0.4.0 <0.6.0;
pragma experimental ABIEncoderV2;
import "./User.sol";

contract Tender {
	uint tenderID;
	uint public endTime;
	Status status;
	string title;
	string desc;

	string item;
	uint qty;

	Bid public bestBid;
	Bid[] bids;
	User database;

	enum Status {open,shipping,payment,closed,cancel}

	struct Bid {
		address bidder;
		uint price;
	}

	event bidAlert(uint _tenderID, uint bidNumber, address bidder);
	event newEndTime(uint _tenderID, uint _newEndTime);
	event Winner(uint _tenderID, address indexed winner, uint _lowestPrice);

	constructor(uint _tenderID, uint _bidTime,string memory _title,string memory _desc, address _database, string memory _item, uint _qty) public {
		tenderID = _tenderID;
		endTime = now + _bidTime;
		database = User(_database);
		title = _title;
		desc = _desc;
		item = _item;
		qty = _qty;
	}

	modifier onlyAdmin() {
		require(database.getUserType(msg.sender) == 2, "Only Admin can call this function");
		_;
	}

	modifier onlyBidder() {
		require(database.getUserType(msg.sender) == 1, "Only bidder can call this function");
		_;
	}

	modifier beforeEndTime() {			// Adding Text leads to deployment error
		require(now < endTime);
		_;
	}

	modifier afterEndTime() {			// Adding Text leads to deployment error
		require(now > endTime);
		_;
	}
	
	function isActive() external view returns(uint8) {
		if (status < Status.closed) return 1;
		return 0;
	}

	/// Simple one product model
	/// @param _price -> overall bid
	function makeBid(uint _price) external onlyBidder beforeEndTime {
        require(_price > 0,"Price cannot be non-positive");
        Bid memory myBid = Bid(msg.sender, _price);
        bids.push(myBid);
		emit bidAlert(tenderID, bids.length, msg.sender);
	}

	function getBidByID(uint _bidNumber) external view returns(address,uint) {
		require(_bidNumber >=1 && _bidNumber <= bids.length,"Invalid Bid Number");
		if (database.getUserType(msg.sender) != 2)
		{
			require(bids[_bidNumber-1].bidder == msg.sender,"Not Allowed");
		}
		Bid memory bid = bids[_bidNumber-1];
		return(bid.bidder,bid.price);
	}

	// Helper Function
	function currentStatus() internal view returns(string memory) {
		string[5] memory statusType = ["Open","Shipping","Payment","Closed","Cancel"];
		return statusType[uint(status)];
	}

	/// @dev Maybe separate req[] to another function
	function displayTenderDetails() external view returns(uint,uint,string memory,string memory,string memory,string memory, uint) {
		return (tenderID, endTime, title, desc, currentStatus(), item, qty);
	}

	/// Extends the endTime by _val seconds
	function extendEndTime(uint _val) external onlyAdmin beforeEndTime {
		require(_val > 0, "endTime cannot be extended by non-positive value");
		endTime += _val;
		emit newEndTime(tenderID,endTime);
	}

	/// Selects the first bid with smallest bid amount
	function getWinner() external onlyAdmin afterEndTime returns(bool) {
		require(status == Status.open, "Winner already selected");

		if (bids.length == 0)
		{
			status = Status.closed;
			return false;
		}

		bestBid = bids[0];
		for(uint i = 1; i < bids.length; ++i)
		{
			if(bestBid.price > bids[i].price)
			{
				bestBid = bids[i];
			}
		}

		status = Status.shipping;
		emit Winner(tenderID, bestBid.bidder, bestBid.price);
		return true;
	}

	function getAllBids() external view onlyAdmin returns(Bid[] memory)
	{
		// Bid[] memory tmpBid = new Bid[](bids.length);
		// for(uint i = 0; i < bids.length; ++i)
		// {
		// 	tmpBid[i] = bids[i];
		// }
		// return tmpBid;
		return bids;
	}

	function getMyBids() external view onlyBidder returns(uint[] memory){
		uint[] memory myBids = new uint[](bids.length);
		uint idx = 0;
		for(uint i = 0; i < bids.length; ++i)
		{
			if(bids[i].bidder == msg.sender)
			{
				myBids[idx++] = bids[i].price;
			}
		}
		return myBids;
	}

	function timeLeft() external view returns(uint) {
		if (now >= endTime) return 0;
		return endTime - now;
	}
}