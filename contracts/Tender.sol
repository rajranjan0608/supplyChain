pragma solidity >=0.4.21 <0.6.0;
pragma experimental ABIEncoderV2;

contract Tender {

    uint id;
    string name;
    string desc;
    uint256 timestamp;
    uint256 endTime;
    address winner;

    enum Status {OPEN, CLOSED}  // enum
    Status status = Status.OPEN;

    uint bidId = 0;

    struct Bid {
        address bidder;
        string[] data;
    }

    mapping (uint => Bid) public bids;      // array or map
    mapping (address => string) public userType;

    modifier onlyBidder(address _user) {
        require(userType[_user] == "Bidder", "User is not a Bidder");
        _;
    }

    modifier onlyAdmin(address _user) {
        require(userType[_user] == "Admin", "User is not an Admin");
        _;
    }

    modifier beforeEndTime() {
        require(status == Status.OPEN, "Tender has been closed");
        _;
    }

    function makeBid(string[] memory _data) public onlyBidder(msg.sender) beforeEndTime {
        bidId++;
        bids[bidId] = Bid(msg.sender, _data);
    }

    function endBidding() public onlyAdmin(msg.sender) beforeEndTime {
        timestamp = now;
        status = Status.CLOSED;
    }

    function extendEndTime(uint256 _timestamp) public onlyAdmin(msg.sender) {
        endTime = _timestamp;
    }

    function declareWinner() {

    }

}