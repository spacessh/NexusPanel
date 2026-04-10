import express, { Express, Request, Response } from 'express';
import dotenv from 'dotenv';
import { WebSocketServer } from 'ws';
import http from 'http';
import winston from 'winston';
import { initializeDatabase } from './database/init.js';
import { initializeRedis } from './redis/init.js';
import apiRoutes from './routes/api.js';
import authRoutes from './routes/auth.js';
import serverRoutes from './routes/servers.js';
import fileRoutes from './routes/files.js';

dotenv.config();

const app: Express = express();
const port = process.env.APP_PORT || 3000;

// Logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

// Middleware
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// CORS
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
  next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/servers', serverRoutes);
app.use('/api/files', fileRoutes);
app.use('/api', apiRoutes);

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Static files
app.use(express.static('public'));

// Create HTTP server
const server = http.createServer(app);

// WebSocket server
const wss = new WebSocketServer({ server });

wss.on('connection', (ws) => {
  logger.info('WebSocket client connected');

  ws.on('message', (data) => {
    logger.info(`Received: ${data}`);
    // Handle messages
  });

  ws.on('close', () => {
    logger.info('WebSocket client disconnected');
  });

  ws.on('error', (error) => {
    logger.error(`WebSocket error: ${error.message}`);
  });
});

// Initialize
async function initialize() {
  try {
    logger.info('Initializing NexusPanel...');
    
    await initializeDatabase();
    logger.info('Database initialized');
    
    await initializeRedis();
    logger.info('Redis initialized');

    server.listen(port, () => {
      logger.info(`🚀 NexusPanel running at http://localhost:${port}`);
    });
  } catch (error) {
    logger.error('Initialization failed:', error);
    process.exit(1);
  }
}

initialize();

export default app;