const express = require('express');
const cors = require('cors');

const app = express();
// Di Cloud, port akan diberikan secara otomatis melalui environment variable
const PORT = process.env.PORT || 5000;

// --- 1. Middleware CORS yang Diperkuat ---
app.use(cors({
  origin: '*', 
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// --- 2. Endpoint Tambahan untuk "/" ---
// Supaya tidak muncul "Cannot GET /" saat URL utama dibuka
app.get('/', (req, res) => {
  res.json({ 
    message: 'IBM Code Engine Backend is Live!',
    health_check: '/health',
    api_endpoint: '/api/data'
  });
});

// Simple GET endpoint
app.get('/api/data', (req, res) => {
  console.log('API /api/data called');
  res.json({
    message: 'Hello from Backend!',
    timestamp: new Date().toISOString(),
    data: [
      { id: 1, name: 'Item 1', description: 'pertama' },
      { id: 2, name: 'Item 2', description: 'kedua' },
      { id: 3, name: 'Item 3', description: 'ketiga' }
    ]
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'Backend is running!' });
});

// --- 3. Start Server dengan Binding 0.0.0.0 ---
// PENTING: Di Cloud/Docker, server harus mendengarkan di 0.0.0.0 bukan localhost
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend server running on port ${PORT}`);
  console.log(`PORT env: ${process.env.PORT}`);
});