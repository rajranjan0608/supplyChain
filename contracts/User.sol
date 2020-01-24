pragma solidity >=0.4.0 <0.6.0;

contract User{
	// 0 -> Normal User
	// 1 -> Bidder
	// 2 -> Admin
	mapping(address => uint8) userType; // Stores the privilege of users

	constructor(address _creator) public {
		userType[_creator] = 2;
		userType[msg.sender] = 2; // Giving MainContract Admin Right too!
	}

	modifier onlyAdmin(){		// What if contract makes a call?
		require(userType[msg.sender] == 2);
		_;
	}

	function getUserType(address _node) external view returns(uint8) {
		return userType[_node];
	}

	function setUserType(address _node,uint8 _val) external onlyAdmin {
		userType[_node] = _val;
	}
}