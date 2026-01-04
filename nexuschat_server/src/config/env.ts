import dotenv from 'dotenv';
import { z } from 'zod';

// Load environment variables
dotenv.config();

// Helper to coerce string to number with default
const stringToNumber = (defaultVal: number) =>
    z.string().optional().transform((val) => val ? parseInt(val, 10) : defaultVal);

// Environment schema validation
const envSchema = z.object({
    NODE_ENV: z.enum(['development', 'production', 'test']).optional().default('development'),
    PORT: stringToNumber(3000),

    // MongoDB
    MONGODB_URI: z.string().min(1, 'MongoDB URI is required'),

    // Redis
    REDIS_URL: z.string().min(1, 'Redis URL is required'),

    // JWT
    JWT_ACCESS_SECRET: z.string().min(32, 'JWT access secret must be at least 32 characters'),
    JWT_REFRESH_SECRET: z.string().min(32, 'JWT refresh secret must be at least 32 characters'),
    JWT_ACCESS_EXPIRY: z.string().optional().default('15m'),
    JWT_REFRESH_EXPIRY: z.string().optional().default('7d'),

    // Email (SMTP)
    EMAIL_SERVER_HOST: z.string().optional().default('smtp.gmail.com'),
    EMAIL_SERVER_PORT: z.coerce.number().optional().default(587),
    EMAIL_SERVER_USER: z.string().optional(),
    EMAIL_SERVER_PASSWORD: z.string().optional(),
    EMAIL_FROM: z.string().email().optional().default('noreply@example.com'),

    // CORS
    CORS_ORIGIN: z.string().optional().default('http://localhost:3000'),

    // Rate Limiting
    RATE_LIMIT_WINDOW_MS: stringToNumber(60000),
    RATE_LIMIT_MAX: stringToNumber(100),
});

// Parse and validate environment
const parseEnv = (): z.infer<typeof envSchema> => {
    try {
        return envSchema.parse(process.env);
    } catch (error) {
        if (error instanceof z.ZodError) {
            const issues = error.issues;
            console.error('❌ Environment validation failed:');
            issues.forEach((issue) => {
                console.error(`   - ${issue.path.join('.')}: ${issue.message}`);
            });
            process.exit(1);
        }
        throw error;
    }
};

export const env = parseEnv();

// Type export for environment
export type Env = z.infer<typeof envSchema>;
