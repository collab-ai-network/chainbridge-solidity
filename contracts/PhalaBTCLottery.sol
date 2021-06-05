pragma solidity 0.7.0;
pragma experimental ABIEncoderV2;

import "./lib/BytesLib.sol";

contract PhalaBTCLottery {

	using BytesLib for bytes;

    address public nftAdmin;
    address public genericHandler;
    address public owner;
    uint public payloadSequence;
    mapping(uint32 => mapping(uint32 => bool)) public openedBox;
    mapping(uint => bytes) public payloadStorage;

    event NewRound(uint32 roundId, uint32 totalCount, uint32 winnerCount);
    event OpenLottery(uint32 roundId, uint32 tokenId, string btcAddr);
    event PayloadStored(bytes payload);

    modifier onlyNFTAdmin() {
        require(
            nftAdmin != address(0) && tx.origin == nftAdmin,
            "Permission Denied: Tx Origin should be NFT contract"
        );
        _;
    }

    modifier onlyGenericHandler() {
        require(
            msg.sender == genericHandler,
            "Permission Denied: Message Sender should be GenericHandler contract"
        );
        _;
    }

        modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Permission Denied: Message Sender should be owner of contract"
        );
        _;
    }

    constructor(
        address _genericHandler
    ) public {
        nftAdmin = address(0);
        genericHandler = _genericHandler;
        owner = msg.sender;
    }

    function setNFTAdmin(address _nftAdmin) public onlyOwner {
        require(_nftAdmin != address(0), "Invalid NFT admin address");
        nftAdmin = _nftAdmin;
    }

    function setOwner(address _owner) public onlyOwner {
        require(_owner != address(0), "Invalid owner address");
        owner = _owner;
    }

	/**
	@notice As a hook function when deposit() was invoked in generic handler contract.
	@notice Data passed into the function should be constructed as follows:
		op								uint8	bytes	0  - 1
		if (op == 0):
			roundId						uint32	bytes	1 - 5
			totalCount					uint32	bytes	5 - 9
			winnerCount					uint32	bytes	9 - END
		else if (op == 1):
			roundId						uint32	bytes	1 - 5
			tokenId						uint32	bytes	5 - 9
            btcAddressLen				uint32	bytes	9 - 13
			btcAddress					bytes	bytes	13 - END
		else
			invalid
	*/
    function depositHandler(bytes memory data) public {
		uint8 op = data.toUint8(0);
        if (op == 0) {
			uint32 roundId = data.toUint32(1);
			uint32 totalCount = data.toUint32(5);
			uint32 winnerCount = data.toUint32(9);
        	_newRound(roundId, totalCount, winnerCount);
        } else if (op == 1) {
			uint32 roundId = data.toUint32(1);
			uint32 tokenId = data.toUint32(5);
            uint32 len = data.toUint32(9);
			string memory btcAddress = string(data.slice(13, len));
        	_open(roundId, tokenId, btcAddress);
        } else {
        	// do nothing
        }
    }

    function isLotteryOpened(uint32 roundId, uint32 tokenId)
        public
        view
        returns (bool)
    {
        return openedBox[roundId][tokenId];
    }

	/**
	@notice As a hook function when executeProposal() was invoked in generic handler contract.
	@notice Data was encoded by parity-scale-codec
	*/
    function executeHandler(bytes memory data)
        public
        onlyGenericHandler
    {
        _storePayload(data);
    }

    function _newRound(
        uint32 roundId,
        uint32 totalCount,
        uint32 winnerCount
    ) private onlyNFTAdmin {
        emit NewRound(roundId, totalCount, winnerCount);
    }

    function _open(
        uint32 roundId,
        uint32 tokenId,
        string memory btcAddress
    ) private {
        require(
            !openedBox[roundId][tokenId],
            "Invalid Call: BTC box already opened"
        );

        openedBox[roundId][tokenId] = true;
        emit OpenLottery(roundId, tokenId, btcAddress);
    }

    function _storePayload(
        bytes memory payload
    ) private {
        payloadStorage[payloadSequence++] = payload;
        emit PayloadStored(payload);
    }
}
