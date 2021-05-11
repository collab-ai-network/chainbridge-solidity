pragma solidity 0.6.4;
pragma experimental ABIEncoderV2;

contract PhalaBTCLottery {
    address nftAdmin;
    address genericHandler;
    mapping(uint32 => mapping(uint32 => bool)) public openedBox;
    mapping(uint32 => mapping(uint32 => bool)) public storedTx;
    mapping(uint32 => mapping(uint32 => bytes)) public txStorage;

    event NewRound(uint32 roundId, uint32 totalCount, uint32 winnerCount);
    event OpenLottery(uint32 roundId, uint32 tokenId, string btcAddr);
    event SignedTxStored(uint32 roundId, uint32 tokenId, bytes signedTx);
    event DebugDeposit(bytes metadata);
    event DebugProposal(bytes metadata);

    modifier onlyNFT() {
        require(
            msg.sender == genericHandler,
            "Permission Denied: Message Sender should be GenericHandler contract"
        );
        require(
            tx.origin == nftAdmin,
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

    constructor(
        address _nftContract,
        address _bridge,
        address _genericHandler
    ) public {
        nftAdmin = _nftContract;
        genericHandler = _genericHandler;
    }

    /**
        @notice As a hook function when deposit() was invoked in generic handler contract.
        @notice Data passed into the function should be constructed as follows:
        op                                     uint8      bytes  0  - 1
		if (op == 0):
        	roundId                            uint32     bytes  1 - 5
			totalCount                         uint32     bytes  5 - 9
			winnerCount                        uint32     bytes  9 - END
		else if (op == 1):
		    roundId                            uint32     bytes  1 - 5
			tokenId                            uint32     bytes  5 - 9
			btcAddress                         bytes      bytes  9 - END
		else
		    invalid
     */
    function depositHandler(bytes calldata data) external {
        bytes memory metaData;
        assembly {
            metaData := mload(0x40)
            let lenMeta := calldataload(0x44)
            mstore(0x40, add(0x60, add(metaData, lenMeta)))

            calldatacopy(metaData, 0x44, lenMeta)
        }

        emit DebugDeposit(metaData);

        // uint8 op = abi.decode(data[:1], (uint8));
        // if (op == 0) {
        // 	uint32 roundId = abi.decode(data[1:5], (uint32));
        // 	uint32 totalCount = abi.decode(data[5:9], (uint32));
        // 	uint32 winnerCount = abi.decode(data[9:], (uint32));
        // 	_newRound(roundId, totalCount, winnerCount);
        // } else if (op == 1) {
        // 	uint32 roundId = abi.decode(data[1:5], (uint32));
        // 	uint32 tokenId = abi.decode(data[5:9], (uint32));
        // 	string memory btcAddress = abi.decode(data[9:], (string));
        // 	_open(roundId, tokenId, btcAddress);
        // } else {
        // 	// do nothing
        // }
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
        @notice Data passed into the function should be constructed as follows:
		roundId                            uint32     bytes  0 - 4
		tokenId                            uint32     bytes  4 - 8
		signedTx                           bytes      bytes  8 - END
     */
    function recordSignedBTCTx(bytes calldata data)
        external
        onlyGenericHandler
    {
        bytes memory metaData;
        assembly {
            metaData := mload(0x40)
            let lenMeta := calldataload(0x44)
            mstore(0x40, add(0x60, add(metaData, lenMeta)))

            calldatacopy(metaData, 0x44, lenMeta)
        }

        emit DebugProposal(metaData);

        // uint32 roundId = abi.decode(data[:4], (uint32));
        // uint32 tokenId = abi.decode(data[4:8], (uint32));
        // bytes memory signedTx = abi.decode(data[8:], (bytes));

        // _recordSignedBTCTx(roundId, tokenId, signedTx);
    }

    function _newRound(
        uint32 roundId,
        uint32 totalCount,
        uint32 winnerCount
    ) private onlyNFT {
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

    function _recordSignedBTCTx(
        uint32 roundId,
        uint32 tokenId,
        bytes memory signedTx
    ) private {
        require(!storedTx[roundId][tokenId], "Invalid Call: Tx already stored");

        storedTx[roundId][tokenId] = true;
        txStorage[roundId][tokenId] = signedTx;

        emit SignedTxStored(roundId, tokenId, signedTx);
    }
}
