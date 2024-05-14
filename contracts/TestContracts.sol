// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./openzeppelin/Pausable.sol";

contract NoArgument is Pausable {
    event NoArgumentCalled();

    function noArgument() whenNotPaused external {
        emit NoArgumentCalled();
    }  
    
    function pause() public {
      _pause();
    }

    function unpause() public {
      _unpause();
    }
}

contract OneArgument is Pausable {
    event OneArgumentCalled(uint256 indexed argumentOne);

    function oneArgument(uint256 argumentOne) whenNotPaused external {
        emit OneArgumentCalled(argumentOne);
    }
        
    function pause() public {
      _pause();
    }

    function unpause() public {
      _unpause();
    }
}

contract TwoArguments is Pausable {
    event TwoArgumentsCalled(address[] argumentOne, bytes4 argumentTwo);

    function twoArguments(address[] calldata argumentOne, bytes4 argumentTwo) whenNotPaused external {
        emit TwoArgumentsCalled(argumentOne, argumentTwo);
    }
        
    function pause() public {
      _pause();
    }

    function unpause() public {
      _unpause();
    }
}

contract ThreeArguments is Pausable {
    event ThreeArgumentsCalled(string argumentOne, int8 argumentTwo, bool argumentThree);

    function threeArguments(string calldata argumentOne, int8 argumentTwo, bool argumentThree) whenNotPaused external {
        emit ThreeArgumentsCalled(argumentOne, argumentTwo, argumentThree);
    }
   
    function pause() public {
      _pause();
    }

    function unpause() public {
      _unpause();
    }
}
