UserRole _selectedRole = UserRole.buyer;

Future<void> _submitOnboarding() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSubmitting = true);

  try {
    final data = {
      'full_name': _fullNameController.text.trim(),
      'user_name': _userNameController.text.trim(),
      'phone_number': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'country': _countryController.text.trim(),
      'bio': _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      'role': _selectedRole.name.toUpperCase(),
    };

    await context.read<UserProvider>().onboardUser(data);

    if (mounted) {
      if (_selectedRole == UserRole.seller || _selectedRole == UserRole.businessSeller) {
        final isBusiness = _selectedRole == UserRole.businessSeller;
        context.go('/verify-id?flow=${isBusiness ? "business" : "individual"}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Onboarding complete! Welcome to Osomba.')),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}

Widget _buildRoleTile({
  required UserRole role,
  required String title,
  required String subtitle,
  IconData? icon,
}) {
  final selected = _selectedRole == role;
  final activeColor = Theme.of(context).colorScheme.primary;
  return ListTile(
    onTap: () => setState(() => _selectedRole = role),
    leading: icon != null
        ? Icon(icon, color: selected ? activeColor : Colors.grey)
        : Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? activeColor : Colors.grey,
          ),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    subtitle: Text(subtitle),
    trailing: selected ? Icon(Icons.check_circle, color: activeColor) : null,
  );
}

const Text(
  'Choose Your Role',
  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
const Text('Select your primary way of using Osomba.'),
const SizedBox(height: 8),

Card(
  child: Column(
    children: [
      _buildRoleTile(
        role: UserRole.buyer,
        title: 'Buyer',
        subtitle: 'I want to browse and purchase items.',
      ),
      const Divider(height: 1),
      _buildRoleTile(
        role: UserRole.seller,
        title: 'Individual Seller',
        subtitle: 'I want to list items and create auctions. (Includes Buyer access)',
      ),
      const Divider(height: 1),
      _buildRoleTile(
        role: UserRole.businessSeller,
        title: 'Business Seller',
        subtitle: 'Scale your business with higher listing limits. (Includes Buyer access)',
      ),
    ],
  ),
),
