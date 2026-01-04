import mongoose from 'mongoose';
import dotenv from 'dotenv';
import User from '../src/models/User';

dotenv.config();

const seed = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI as string);
        console.log('Connected to MongoDB');

        const dummyUser = {
            email: 'demo@nexuschat.com',
            username: 'demouser',
            passwordHash: '$2b$12$eX8.P0.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X.X', // Dummy hash
            displayName: 'Demo User',
            bio: 'I am a demo user for testing.',
            isActive: true,
            isVerified: true
        };

        const existing = await User.findOne({ email: dummyUser.email });
        if (existing) {
            console.log('Dummy user already exists');
        } else {
            // We need to hash password properly or just use a known hash if we don't login as them
            // For now let's create it with the model which handles hashing in pre-save if we set 'passwordHash' field?
            // Wait, the model pre-save hooks on 'passwordHash' modification.
            // Let's just create it directly.

            // Actually, better to use the create method but we need to bypass typescript complaining about private fields if any.
            // We need a raw create or just new User();

            const user = new User(dummyUser);
            user.passwordHash = 'password123'; // The pre-save hook will hash this
            await user.save();
            console.log('Dummy user created: demouser');
        }

        process.exit(0);
    } catch (error) {
        console.error('Seeding failed:', error);
        process.exit(1);
    }
};

seed();
