module MyModule::SimpleStaking {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::timestamp;

    /// Struct representing a user's staking position
    struct StakePosition has store, key {
        staked_amount: u64,     // Total tokens staked by user
        stake_time: u64,        // Timestamp when tokens were staked
    }

    /// Function to stake tokens - users lock their tokens for rewards
    public fun stake_tokens(user: &signer, amount: u64) acquires StakePosition {
        let user_addr = signer::address_of(user);
        
        // Withdraw tokens from user's account
        let tokens = coin::withdraw<AptosCoin>(user, amount);
        
        // For simplicity, we'll just keep tokens in user's account but track them
        coin::deposit<AptosCoin>(user_addr, tokens);
        
        // Create or update stake position
        if (exists<StakePosition>(user_addr)) {
            let stake = borrow_global_mut<StakePosition>(user_addr);
            stake.staked_amount = stake.staked_amount + amount;
            stake.stake_time = timestamp::now_seconds();
        } else {
            let stake = StakePosition {
                staked_amount: amount,
                stake_time: timestamp::now_seconds(),
            };
            move_to(user, stake);
        };
    }

    /// Function to unstake tokens - users withdraw their staked tokens
    public fun unstake_tokens(user: &signer, amount: u64) acquires StakePosition {
        let user_addr = signer::address_of(user);
        let stake = borrow_global_mut<StakePosition>(user_addr);
        
        // Ensure user has enough staked tokens
        assert!(stake.staked_amount >= amount, 1);
        
        // Update staked amount
        stake.staked_amount = stake.staked_amount - amount;
        
        // Tokens are already in user's account, just update the tracking
        // In a real implementation, you might transfer from a staking pool
    }
}