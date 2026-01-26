const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Simple GET endpoint
app.get('/api/data', (req, res) => {
  res.json({
    message: 'Hello from Backend!',
    timestamp: new Date().toISOString(),
    data: [
      { id: 1, name: 'Item 1', description: 'Deskripsi item pertama' },
      { id: 2, name: 'Item 2', description: 'Deskripsi item kedua' },
      { id: 3, name: 'Item 3', description: 'Deskripsi item ketiga' }
    ]
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'Backend is running!' });
});

// Start server
app.listen(PORT, () => {
  console.log(`Backend server running on http://localhost:${PORT}`);
  console.log(`API endpoint: http://localhost:${PORT}/api/data`);
});
