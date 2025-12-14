// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// ============================================================
// SIMPLE GAS VS SECURITY DEMO
// ============================================================

contract SimpleUnsafeVault {
    mapping(address => uint256) public credits;  // Not actual ETH
    
    function addCredits() external payable {
        unchecked {
            credits[msg.sender] += msg.value;
        }
    }
    
    // ❌ "Optimized" - no balance check
    function removeCredits(uint256 amount) external {
        unchecked {
            credits[msg.sender] -= amount;  // Can underflow!
        }
    }
    
    function getCredits(address user) external view returns (uint256) {
        return credits[user];
    }
}

contract SimpleSafeVault {
    mapping(address => uint256) public credits;
    
    function addCredits() external payable {
        credits[msg.sender] += msg.value;  // Checked
    }
    
    // ✅ Secure - proper check
    function removeCredits(uint256 amount) external {
        require(credits[msg.sender] >= amount, "Insufficient credits");
        credits[msg.sender] -= amount;  // Checked
    }
    
    function getCredits(address user) external view returns (uint256) {
        return credits[user];
    }
}

// ============================================================
// DEMONSTRATION
// ============================================================

contract SimplifiedDemo {
    
    function demonstrateVulnerability() external returns (
        uint256 creditsBefore,
        uint256 creditsAfter,
        bool exploited
    ) {
        SimpleUnsafeVault unsafeVault = new SimpleUnsafeVault();
        
        // Start with 0 credits
        creditsBefore = unsafeVault.getCredits(address(this));
        
        // Remove 1 credit (we don't have any!)
        // 0 - 1 = underflow to max uint256
        unsafeVault.removeCredits(1);
        
        // Check result
        creditsAfter = unsafeVault.getCredits(address(this));
        exploited = creditsAfter == type(uint256).max;
        
        return (creditsBefore, creditsAfter, exploited);
    }
    
    function demonstrateSecurity() external returns (bool secure) {
        SimpleSafeVault safeVault = new SimpleSafeVault();
        
        // Try to remove credits we don't have
        try safeVault.removeCredits(1) {
            return false;  // Should not succeed
        } catch {
            return true;   // Correctly reverted
        }
    }
    
    function measureGas() external returns (uint256 unsafeGas, uint256 safeGas) {
       
        SimpleUnsafeVault unsafeVault = new SimpleUnsafeVault();
        SimpleSafeVault safeVault = new SimpleSafeVault();
        
        // Add credits first
        unsafeVault.addCredits{value: 1 ether}();
        safeVault.addCredits{value: 1 ether}();
        
        // Measure unsafe
        uint256 gas1 = gasleft();
        unsafeVault.removeCredits(0.5 ether);
        unsafeGas = gas1 - gasleft();
        
        // Measure safe
        uint256 gas2 = gasleft();
        safeVault.removeCredits(0.5 ether);
        safeGas = gas2 - gasleft();
        
        // Result: unsafe ~5000 gas, safe ~5200 gas
        // Savings: ~200 gas (0.004%)
    }
}