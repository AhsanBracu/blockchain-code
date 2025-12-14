// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SimpleUnsafeVault {
    mapping(address => uint256) public credits;
    
    // No payable - just assigns credits
    function addCredits(uint256 amount) external {
        unchecked {
            credits[msg.sender] += amount;
        }
    }
    
    function removeCredits(uint256 amount) external {
        unchecked {
            credits[msg.sender] -= amount;
        }
    }
    
    function getCredits(address user) external view returns (uint256) {
        return credits[user];
    }
}

contract SimpleSafeVault {
    mapping(address => uint256) public credits;
    
    function addCredits(uint256 amount) external {
        credits[msg.sender] += amount;
    }
    
    function removeCredits(uint256 amount) external {
        require(credits[msg.sender] >= amount, "Insufficient credits");
        credits[msg.sender] -= amount;
    }
    
    function getCredits(address user) external view returns (uint256) {
        return credits[user];
    }
}

contract SimplifiedDemo {
    
    function demonstrateVulnerability() external returns (
        uint256 creditsBefore,
        uint256 creditsAfter,
        bool exploited
    ) {
        SimpleUnsafeVault unsafeVault = new SimpleUnsafeVault();
        
        creditsBefore = unsafeVault.getCredits(address(this));
        
        // Remove 1 credit when we have 0 → underflow!
        unsafeVault.removeCredits(1);
        
        creditsAfter = unsafeVault.getCredits(address(this));
        exploited = creditsAfter == type(uint256).max;
        
        return (creditsBefore, creditsAfter, exploited);
    }
    
    function demonstrateSecurity() external returns (bool secure) {
        SimpleSafeVault safeVault = new SimpleSafeVault();
        
        try safeVault.removeCredits(1) {
            return false;
        } catch {
            return true;
        }
    }
    
    function measureGas() external returns (uint256 unsafeGas, uint256 safeGas) {
        SimpleUnsafeVault unsafeVault = new SimpleUnsafeVault();
        SimpleSafeVault safeVault = new SimpleSafeVault();
        
        // Add 100 credits (no ETH needed)
        unsafeVault.addCredits(100);
        safeVault.addCredits(100);
        
        // Measure unsafe
        uint256 gas1 = gasleft();
        unsafeVault.removeCredits(50);
        unsafeGas = gas1 - gasleft();
        
        // Measure safe
        uint256 gas2 = gasleft();
        safeVault.removeCredits(50);
        safeGas = gas2 - gasleft();
        
        return (unsafeGas, safeGas);
    }
    
    function showGasDifference() external returns (
        uint256 unsafeGas,
        uint256 safeGas,
        uint256 gasSaved,
        string memory conclusion
    ) {
        (unsafeGas, safeGas) = this.measureGas();
        
        gasSaved = safeGas > unsafeGas ? safeGas - unsafeGas : 0;
        
        if (gasSaved < 300) {
            conclusion = "Saved less than 300 gas - not worth the risk!";
        } else {
            conclusion = "Significant savings";
        }
        
        return (unsafeGas, safeGas, gasSaved, conclusion);
    }
}