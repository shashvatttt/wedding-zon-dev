class ProfileHelpers {
  ProfileHelpers._();

  static String getManagedByText(String? createdFor) {
    if (createdFor == null || createdFor.isEmpty) {
      return 'Self';
    }

    final normalized = createdFor.trim().toLowerCase();

    switch (normalized) {
      case 'parent':
      case 'parents':
        return 'Children';

      case 'son':
      case 'daughter':
      case 'child':
      case 'children':
        return 'Parents';

      case 'brother':
      case 'sister':
      case 'sibling':
        return 'Sibling';

      case 'self':
        return 'Self';

      case 'friend':
        return 'Friend';

      case 'relative':
      case 'family':
        return 'Family';

      case 'guardian':
        return 'Guardian';

      default:
        return createdFor[0].toUpperCase() + createdFor.substring(1);
    }
  }

  static String getProfileManagedByText(String? createdFor) {
    return 'Profile managed by ${getManagedByText(createdFor)}';
  }
}
