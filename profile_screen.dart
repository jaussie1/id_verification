void _upgradeRole(UserRole targetRole) {
    final isBusiness = targetRole == UserRole.businessSeller;
    context.push('/verify-id?flow=${isBusiness ? "business" : "individual"}');
  }

  Widget _buildSellerUpgradeSection(UserModel user, Color themeColor) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, color: themeColor),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Start Selling on Osomba',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose your seller tier. Both options require a quick identity verification.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            
            // Option 1: Individual
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : () => _upgradeRole(UserRole.seller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Become Individual Seller'),
              ),
            ),
            const SizedBox(height: 12),
            
            // Option 2: Business
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : () => _upgradeRole(UserRole.businessSeller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Become Business Seller'),
              ),
            ),
          ],
        ),
      ),
    );
  }
