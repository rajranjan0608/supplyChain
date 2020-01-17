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
	Step[] history;
	User database;

	enum Status {open,shipping,payment,closed,cancel}

	// Structs 

	struct Bid {
		address bidder;
		uint price;
	}

	// SupplyChain entity
	struct Step{
		address curOwner;
		address newOwner;
		string memo;
	}

	// Events

	event bidAlert(uint _tenderID, uint bidNumber, address bidder);
	event newEndTime(uint _tenderID, uint _newEndTime);
	event Winner(uint _tenderID, address indexed winner, uint _lowestPrice);
	event transit(uint tenderID, address indexed _curOwner, address indexed _newOwner);

	constructor(uint _tenderID, uint _bidTime,string memory _title,string memory _desc, address _database, string memory _item, uint _qty) public {
		tenderID = _tenderID;
		endTime = now + _bidTime;
		database = User(_database);
		title = _title;
		desc = _desc;
		item = _item;
		qty = _qty;
	}

	// Modifier Section

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
	
	// Tender Attr Section

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

	// Bidding Section

	/// Simple one product model
	/// @param _price -> overall bid
	function makeBid(uint _price) external onlyBidder beforeEndTime {
        require(_price > 0,"Price cannot be non-positive");
        Bid memory myBid = Bid(msg.sender, _price);
        bids.push(myBid);
		emit bidAlert(tenderID, bids.length, msg.sender);
	}

	/// @dev Not Working with Web3
	function getAllBids() external view returns(Bid[] memory)
	{
		return bids;
	}

	/// Returns the price bidded by the bidder
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

	/// Returns bidder address and price bidded
	/// @param _bidNumber : 1-based indexing in bids[]
	function getBidByID(uint _bidNumber) external view returns(address,uint) {
		require(_bidNumber >=1 && _bidNumber <= bids.length,"Invalid Bid Number");
		if (database.getUserType(msg.sender) != 2)
		{
			require(bids[_bidNumber-1].bidder == msg.sender,"Not Allowed");
		}
		Bid memory bid = bids[_bidNumber-1];
		return(bid.bidder,bid.price);
	}

	// Misc Section

	/// Returns the time left before the bidding period ends
	function timeLeft() external view returns(uint) {
		if (now >= endTime) return 0;
		return endTime - now;
	}

	/// Returns 0 if tender is closed/cancelled
	/// Otherwise returns 1
	function isActive() external view returns(uint8) {
		if (status < Status.closed) return 1;
		return 0;
	}

	/// Returns the phase the tender is in
	function currentStatus() public view returns(string memory) {
		string[5] memory statusType = ["Open","Shipping","Payment","Closed","Cancel"];
		return statusType[uint(status)];
	}


	// SuplyChain Section

	/// Records a transition made in suppy-chain
	function transferOwnership(address _newOwner, string calldata _memo) external {
		require(status == Status.shipping,"Not in shipment phase");

		if (history.length == 0)
		{
			require(bestBid.bidder == msg.sender,"Only selected bidder can init the Supply");
		}
		else
		{
			address curOwner = history[history.length-1].newOwner;
			require(curOwner == msg.sender, "You don't have the history of the good");
		}

		Step memory shift = Step(msg.sender, _newOwner, _memo);
		history.push(shift);
		emit transit(tenderID, msg.sender, _newOwner);

		if (database.getUserType(_newOwner) == 2)
		{
			status = Status.payment;
		}
	}

	/// Admin either accepts or rejects the item received
	function makePayment(bool _success) external onlyAdmin {
		require(status == Status.payment,"Not in payment mode");

		if(_success)
		{
			Step memory paid = Step(msg.sender, bestBid.bidder, "Payment Initiated");
			history.push(paid);
			status = Status.closed;
		}
		else
		{
			Step memory reject = Step(msg.sender, bestBid.bidder, "Order Rejected!");
			history.push(reject);
			status = Status.cancel;
		}

	}

	/// Returns the address of owner with current possession of item
	function getCurrentOwner() external view returns(address) {
		require(status == Status.shipping, "Not in shipping phase");
		if (history.length == 0) 
		{
			return bestBid.bidder;
		}
		return history[history.length-1].newOwner;
	}

	/// Returns the number of transitions happened in supply-chain
	function getHistorySize() external view returns(uint) {
		return history.length;
	}

	/// Returns the record of _id-TH transition
	function getHistoryByID(uint _id) external view returns(Step memory) {
		require(_id >= 1 && _id <= history.length, "Invalid history id");
		return history[_id-1];
	}

}