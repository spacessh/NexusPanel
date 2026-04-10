import { createClient } from 'redis';
import dotenv from 'dotenv';

dotenv.config();

export const redisClient = createClient({
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
  password: process.env.REDIS_PASSWORD || undefined,
});

export async function initializeRedis() {
  try {
    await redisClient.connect();
    console.log('✓ Redis connected');
  } catch (error) {
    console.error('Redis connection failed:', error);
    throw error;
  }
}

export default redisClient;