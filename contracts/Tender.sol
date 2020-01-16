pragma solidity >=0.4.0 <0.6.0;
pragma experimental ABIEncoderV2;
import "./MainContract.sol";

contract Tender {
	uint tenderID;
	Status status;
	uint public endTime;
	address factoryAddress;
	string title;
	string desc;
	string[] req;
	Bid public bestBid;
	Bid[] bids;

	enum Status {open,shipping,payment,closed,cancel}

	struct Bid {
		address bidder;
		string[] data;      // possible error
	}

	constructor(uint _tenderID, uint _bidTime, string[] memory _req) public {
		tenderID = _tenderID;
		endTime = now + _bidTime;
		factoryAddress = msg.sender;	// Verify
		title = _req[0];
		desc = _req[1];
// 		for(uint i = 2; i < _req.length; ++i)
// 		{
// 			req.push(_req[i]);
// 		}
	}

	event bidAlert(uint _tenderID, uint bidNumber, address bidder);
	event newEndTime(uint _tenderID, uint _newEndTime);
	event Winner(uint _tenderID, uint bidNumber, address indexed winner);

	modifier onlyAdmin() {
		MainContract factory = MainContract(factoryAddress);
		require(uint8(factory.userType(msg.sender)) == 2, "Only Admin can call this function.");
		_;
	}
	
	modifier onlyBidder() {
		MainContract factory = MainContract(factoryAddress);
		require(uint8(factory.userType(msg.sender)) == 1, "Only Bidder can call this function.");
		_;
	}

	modifier beforeEndTime() {
		require(now <= endTime);
		_;
	}

	modifier afterEndTime() {
		require(now > endTime);
		_;
	}

    /// Problem detected
// 	function makeBid(string[] calldata _Data) external onlyBidder beforeEndTime {

// 		//bids.push( Bid(msg.sender, _Data) );
// 		emit bidAlert(tenderID, bids.length, msg.sender);
// 	}

	function extendEndTime(uint _val) external onlyAdmin beforeEndTime {
		require(_val > 0, "endTime cannot be extended by non-positive value");
		endTime += _val;
		emit newEndTime(tenderID,endTime);
	}

	function declareWinner(uint _bidNumber) external onlyAdmin afterEndTime {
		require(status == Status.open, "Winner already selected");
		require(_bidNumber >=1 && _bidNumber <= bids.length,"Invalid Bid Number");
		bestBid = bids[_bidNumber];
		status = Status.shipping;
		emit Winner(tenderID, _bidNumber, bestBid.bidder);
	}

	function displayTenderDetails() external view returns(uint,uint,string memory,string memory,string memory,string[] memory) {
		return (tenderID, endTime, title, desc, currentStatus(), req);
	}

	// Helper Function
	function currentStatus() internal view returns(string memory) {
		string[5] memory statusType = ["Open","Shipping","Payment","Closed","Cancel"];
		return statusType[uint(status)];
	}

	function isActive() external view returns(uint8) {
		if (status < Status.closed) return 1;
		return 0;
	}

	function getBidByID(uint _bidNumber) external view returns(string[] memory) {
		require(_bidNumber >=1 && _bidNumber <= bids.length,"Invalid Bid Number");

		MainContract factory = MainContract(factoryAddress);
		if (uint8(factory.userType(msg.sender)) != 2)
		{
			require(bids[_bidNumber-1].bidder == msg.sender);
		}

		return bids[_bidNumber-1].data;
	}

}