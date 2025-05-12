// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title QCOM Token
 * @dev ERC20 Token for QuantumDAO, the decentralized organization dedicated to 
 * accelerating quantum communication technology development.
 */
contract QCOMToken is ERC20, ERC20Burnable, Pausable, Ownable {
    // Total supply: 1 billion tokens
    uint256 private constant TOTAL_SUPPLY = 1_000_000_000 * 10**18;
    
    // Distribution allocations
    uint256 private constant ECOSYSTEM_DEVELOPMENT = 300_000_000 * 10**18; // 30%
    uint256 private constant COMMUNITY_TREASURY = 250_000_000 * 10**18;    // 25%
    uint256 private constant INITIAL_CONTRIBUTORS = 150_000_000 * 10**18;  // 15%
    uint256 private constant PUBLIC_SALE = 100_000_000 * 10**18;           // 10%
    uint256 private constant PRIVATE_SALE = 100_000_000 * 10**18;          // 10%
    uint256 private constant LIQUIDITY_PROVISION = 50_000_000 * 10**18;    // 5%
    uint256 private constant AIRDROPS_INCENTIVES = 50_000_000 * 10**18;    // 5%
    
    // Vesting-related addresses
    address public ecosystemDevelopmentWallet;
    address public communityTreasuryWallet;
    address public initialContributorsWallet;
    address public publicSaleWallet;
    address public privateSaleWallet;
    address public liquidityProvisionWallet;
    address public airdropsIncentivesWallet;
    
    // Vesting timestamps
    uint256 public ecosystemVestingStart;
    uint256 public contributorsVestingStart;
    uint256 public privateSaleVestingStart;
    
    // Vesting durations (in seconds)
    uint256 private constant ECOSYSTEM_VESTING_DURATION = 4 * 365 days; // 4 years
    uint256 private constant CONTRIBUTORS_VESTING_DURATION = 3 * 365 days; // 3 years
    uint256 private constant PRIVATE_SALE_VESTING_DURATION = 1 * 365 days; // 1 year
    
    // Cliff periods (in seconds)
    uint256 private constant CONTRIBUTORS_CLIFF = 180 days; // 6 months
    uint256 private constant PRIVATE_SALE_CLIFF = 90 days; // 3 months
    
    // Events
    event TokensReleased(address indexed beneficiary, uint256 amount);
    event VestingScheduleCreated(address indexed beneficiary, uint256 amount, uint256 startTime, uint256 duration, uint256 cliff);

    /**
     * @dev Constructor that initializes the QCOM token and sets up initial allocations
     */
    constructor(
        address _ecosystemWallet,
        address _treasuryWallet,
        address _contributorsWallet,
        address _publicSaleWallet,
        address _privateSaleWallet,
        address _liquidityWallet,
        address _airdropsWallet
    ) ERC20("QuantumDAO Communication Token", "QCOM") {
        require(_ecosystemWallet != address(0), "Ecosystem wallet cannot be zero address");
        require(_treasuryWallet != address(0), "Treasury wallet cannot be zero address");
        require(_contributorsWallet != address(0), "Contributors wallet cannot be zero address");
        require(_publicSaleWallet != address(0), "Public sale wallet cannot be zero address");
        require(_privateSaleWallet != address(0), "Private sale wallet cannot be zero address");
        require(_liquidityWallet != address(0), "Liquidity wallet cannot be zero address");
        require(_airdropsWallet != address(0), "Airdrops wallet cannot be zero address");
        
        ecosystemDevelopmentWallet = _ecosystemWallet;
        communityTreasuryWallet = _treasuryWallet;
        initialContributorsWallet = _contributorsWallet;
        publicSaleWallet = _publicSaleWallet;
        privateSaleWallet = _privateSaleWallet;
        liquidityProvisionWallet = _liquidityWallet;
        airdropsIncentivesWallet = _airdropsWallet;
        
        // Set vesting start times
        ecosystemVestingStart = block.timestamp;
        contributorsVestingStart = block.timestamp;
        privateSaleVestingStart = block.timestamp;
        
        // Mint tokens to respective wallets
        _mint(communityTreasuryWallet, COMMUNITY_TREASURY);
        _mint(publicSaleWallet, PUBLIC_SALE);
        _mint(liquidityProvisionWallet, LIQUIDITY_PROVISION);
        _mint(airdropsIncentivesWallet, AIRDROPS_INCENTIVES);
        
        // Tokens subject to vesting are minted to this contract
        _mint(address(this), ECOSYSTEM_DEVELOPMENT + INITIAL_CONTRIBUTORS + PRIVATE_SALE);
        
        // Set up vesting schedules
        emit VestingScheduleCreated(ecosystemDevelopmentWallet, ECOSYSTEM_DEVELOPMENT, ecosystemVestingStart, ECOSYSTEM_VESTING_DURATION, 0);
        emit VestingScheduleCreated(initialContributorsWallet, INITIAL_CONTRIBUTORS, contributorsVestingStart, CONTRIBUTORS_VESTING_DURATION, CONTRIBUTORS_CLIFF);
        emit VestingScheduleCreated(privateSaleWallet, PRIVATE_SALE, privateSaleVestingStart, PRIVATE_SALE_VESTING_DURATION, PRIVATE_SALE_CLIFF);
    }
    
    /**
     * @dev Pauses all token transfers.
     * Can only be called by the contract owner.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     * Can only be called by the contract owner.
     */
    function unpause() public onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Hook that is called before any transfer of tokens.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
    
    /**
     * @dev Releases vested tokens for ecosystem development.
     */
    function releaseEcosystemTokens() public {
        uint256 releasableAmount = calculateReleasableAmount(
            ECOSYSTEM_DEVELOPMENT,
            ecosystemVestingStart,
            ECOSYSTEM_VESTING_DURATION,
            0
        );
        
        require(releasableAmount > 0, "No tokens available for release");
        
        _transfer(address(this), ecosystemDevelopmentWallet, releasableAmount);
        emit TokensReleased(ecosystemDevelopmentWallet, releasableAmount);
    }
    
    /**
     * @dev Releases vested tokens for initial contributors.
     */
    function releaseContributorsTokens() public {
        uint256 releasableAmount = calculateReleasableAmount(
            INITIAL_CONTRIBUTORS,
            contributorsVestingStart,
            CONTRIBUTORS_VESTING_DURATION,
            CONTRIBUTORS_CLIFF
        );
        
        require(releasableAmount > 0, "No tokens available for release");
        
        _transfer(address(this), initialContributorsWallet, releasableAmount);
        emit TokensReleased(initialContributorsWallet, releasableAmount);
    }
    
    /**
     * @dev Releases vested tokens for private sale participants.
     */
    function releasePrivateSaleTokens() public {
        uint256 releasableAmount = calculateReleasableAmount(
            PRIVATE_SALE,
            privateSaleVestingStart,
            PRIVATE_SALE_VESTING_DURATION,
            PRIVATE_SALE_CLIFF
        );
        
        require(releasableAmount > 0, "No tokens available for release");
        
        _transfer(address(this), privateSaleWallet, releasableAmount);
        emit TokensReleased(privateSaleWallet, releasableAmount);
    }
    
    /**
     * @dev Calculates the amount of tokens that can be released based on vesting schedule.
     */
    function calculateReleasableAmount(
        uint256 totalAllocation,
        uint256 vestingStart,
        uint256 vestingDuration,
        uint256 cliff
    ) internal view returns (uint256) {
        if (block.timestamp < vestingStart + cliff) {
            return 0;
        }
        
        if (block.timestamp >= vestingStart + vestingDuration) {
            return totalAllocation;
        }
        
        uint256 timeElapsed = block.timestamp - vestingStart;
        return (totalAllocation * timeElapsed) / vestingDuration;
    }
    
    /**
     * @dev Returns the amount of tokens that can be released for ecosystem development.
     */
    function getReleasableEcosystemTokens() public view returns (uint256) {
        return calculateReleasableAmount(
            ECOSYSTEM_DEVELOPMENT,
            ecosystemVestingStart,
            ECOSYSTEM_VESTING_DURATION,
            0
        );
    }
    
    /**
     * @dev Returns the amount of tokens that can be released for initial contributors.
     */
    function getReleasableContributorsTokens() public view returns (uint256) {
        return calculateReleasableAmount(
            INITIAL_CONTRIBUTORS,
            contributorsVestingStart,
            CONTRIBUTORS_VESTING_DURATION,
            CONTRIBUTORS_CLIFF
        );
    }
    
    /**
     * @dev Returns the amount of tokens that can be released for private sale participants.
     */
    function getReleasablePrivateSaleTokens() public view returns (uint256) {
        return calculateReleasableAmount(
            PRIVATE_SALE,
            privateSaleVestingStart,
            PRIVATE_SALE_VESTING_DURATION,
            PRIVATE_SALE_CLIFF
        );
    }
}
