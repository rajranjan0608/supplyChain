pragma solidity >=0.5.0 <=0.6.0;
pragma experimental ABIEncoderV2;

contract Tender {
	uint tenderID;
	Status status;
	uint endTime;
	address winner;
	string name;
	string desc;
	string[] req;
	Bid[] bids;

	enum Status {open,shipping,payment,closed,cancel}

	struct Bid {
		address bidder;
		string[] data;
	}

	constructor(uint _tenderID, uint _bidTime, string[] memory _req) public {
		tenderID = _tenderID;
		endTime = now + _bidTime;
		name = _req[0];
		desc = _req[1];
		for(uint i = 2; i < _req.length; ++i)
		{
			req.push(_req[i]);
		}
	}

	event bidAlert(uint _tenderID, uint bidNumber, address bidder);
	event newEndTime(uint _tenderID, uint _newEndTime);
	event Winner(uint _tenderID, uint bidNumber, address indexed winner)

	modifier onlyAdmin() {}
	modifier onlyBidder() {}

	modifier beforeEndTime() {
		require(now <= endTime);
		_;
	}

	modifier afterEndTime() {
		require(now > endTime);
		_;
	}


	function makeBid(string[] calldata _Data) external onlyBidder beforeEndTime {
		Bid newBid = Bid(msg.sender, _Data);
		bids.push(newBid);
		emit bidAlert(tenderID, bids.length, msg.sender);
	}

	function extendEndTime(uint _val) external onlyAdmin beforeEndTime {
		require(_val > 0, "endTime cannot be extended by non-positive value");
		endTime += _val;
		emit newEndTime(tenderID,endTime);
	}

	function declareWinner(uint _bidNumber) external onlyAdmin afterEndTime {
		require(status == Status.open, "Winner already selected");
		require(_bidNumber >=1 && _bidNumber <= bids.length,"Invalid Bid Number");
		winner = bids[_bidNumber].bidder;
		status = Status.shipping;
		emit Winner(tenderID, _bidNumber, winner);
	}

	function displayTenderDetails() external view returns(uint,uint,string,string,string,string[] memory) {
		return (tenderID, endTime, name, desc, currentStatus(), req);
	}

	// Helper Function
	function currentStatus() internal view returns(string)
	{
		string memory statusType[] = ["Open","Shipping","Payment","Closed","Cancel"];
		return statusType[status];
	}

	function isActive() external view returns(uint8) {
		if (status < status.closed) return 1;
		return 0;
	}

	function getBidByID(uint _bidNumber) external view returns(string[] memory) {
		require(_bidNumber >=1 && _bidNumber <= bids.length,"Invalid Bid Number");
		require(bids[_bidNumber].bidder == msg.sender || USER_TYPE[msg.sender] == privilege.admin);
		return bids[_bidNumber].data;
	}

	//function getMyBids() external view onlyBidder returns() {}
	//function getAllBids() external view onlyAdmin returns() {}


}