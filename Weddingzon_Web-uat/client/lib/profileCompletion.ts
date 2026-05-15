/**
 * Calculate profile completion percentage based on user data
 * @param user - User object from the database
 * @returns Completion percentage (0-100)
 */
export function calculateProfileCompletion(user: any): number {
    if (!user) return 0;

    // Define required fields for different user roles
    const basicFields = [
        'first_name',
        'last_name',
        'dob',
        'gender',
        'phone',
        'email',
    ];

    const profileFields = [
        'bio',
        'profilePhoto',
        'height',
        'marital_status',
        'mother_tongue',
        'country',
        'state',
        'city',
    ];

    const familyFields = [
        'father_name',
        'mother_name',
        'father_status',
        'mother_status',
        'family_type',
        'family_values',
    ];

    const educationCareerFields = [
        'highest_education',
        'occupation',
        'employed_in',
        'personal_income',
    ];

    const religiousFields = [
        'religion',
        'community',
    ];

    const lifestyleFields = [
        'eating_habits',
        'smoking_habits',
        'drinking_habits',
    ];

    const astroFields = [
        'manglik_status',
        'time_of_birth',
        'place_of_birth',
    ];

    // Combine all fields based on role
    let allRequiredFields = [
        ...basicFields,
        ...profileFields,
        ...familyFields,
        ...educationCareerFields,
        ...religiousFields,
        ...lifestyleFields,
    ];

    // Add astro fields for matrimony users
    if (['member', 'bride', 'groom'].includes(user.role)) {
        allRequiredFields = [...allRequiredFields, ...astroFields];
    }

    // Calculate completion
    let completedFields = 0;
    let totalFields = allRequiredFields.length;

    allRequiredFields.forEach(field => {
        const value = user[field];

        // Check if field has a meaningful value
        if (value !== null && value !== undefined && value !== '' && value !== "Don't Know") {
            // For arrays, check if they have at least one item
            if (Array.isArray(value)) {
                if (value.length > 0) {
                    completedFields++;
                }
            } else {
                completedFields++;
            }
        }
    });

    // Score from text fields (Max 80%)
    const fieldPercentage = totalFields > 0 ? (completedFields / totalFields) * 80 : 0;

    // Score from photos (Max 20%)
    // Each photo gives 5%, so 4 photos needed for full 20%
    let photoScore = 0;
    if (user.photos && Array.isArray(user.photos)) {
        photoScore = Math.min(user.photos.length * 5, 20);
    }

    // Total Score
    const totalScore = Math.round(fieldPercentage + photoScore);
    return Math.min(totalScore, 100);
}

/**
 * Get missing fields for profile completion
 * @param user - User object from the database
 * @returns Array of missing field names
 */
export function getMissingProfileFields(user: any): string[] {
    if (!user) return [];

    const fieldLabels: Record<string, string> = {
        first_name: 'First Name',
        last_name: 'Last Name',
        dob: 'Date of Birth',
        gender: 'Gender',
        phone: 'Phone Number',
        email: 'Email',
        bio: 'Bio',
        profilePhoto: 'Profile Photo',
        height: 'Height',
        marital_status: 'Marital Status',
        mother_tongue: 'Mother Tongue',
        country: 'Country',
        state: 'State',
        city: 'City',
        father_name: 'Father Name',
        mother_name: 'Mother Name',
        father_status: 'Father Status',
        mother_status: 'Mother Status',
        family_type: 'Family Type',
        family_values: 'Family Values',
        highest_education: 'Highest Education',
        occupation: 'Occupation',
        employed_in: 'Employed In',
        personal_income: 'Personal Income',
        religion: 'Religion',
        community: 'Community',
        eating_habits: 'Eating Habits',
        smoking_habits: 'Smoking Habits',
        drinking_habits: 'Drinking Habits',
        manglik_status: 'Manglik Status',
        time_of_birth: 'Time of Birth',
        place_of_birth: 'Place of Birth',
    };

    const allFields = Object.keys(fieldLabels);
    const missingFields: string[] = [];

    allFields.forEach(field => {
        const value = user[field];
        if (value === null || value === undefined || value === '' || value === "Don't Know") {
            missingFields.push(fieldLabels[field]);
        }
    });

    return missingFields;
}
