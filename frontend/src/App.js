import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // --- KUNCI KEBERHASILAN ---
  // Kita pakai URL Backend IBM Cloud kamu secara langsung agar tidak "nyasar" ke localhost
  const BACKEND_URL = process.env.REACT_APP_BACKEND_URL || "https://nyoba-cicd-joy-backend.25vc8mhbgyki.us-south.codeengine.appdomain.cloud";

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);

      // Memanggil endpoint /api/data yang sudah kita buat di server.js
      const response = await fetch(`${BACKEND_URL}/api/data`);
      
      if (!response.ok) {
        throw new Error(`Gagal mengambil data (Status: ${response.status})`);
      }
      
      const result = await response.json();
      setData(result);
    } catch (error) {
      setError(error.message);
      console.error('Fetch error:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>IBM Cloud Fullstack App</h1>
        <div className="status-badge">
          {loading ? "🔄 Memasangkan koneksi..." : "✅ Connected to Cloud"}
        </div>
      </header>

      <main className="container">
        <section className="backend-info">
          <h2>Data dari Backend</h2>
          <p className="url-label">Endpoint: <code>{BACKEND_URL}/api/data</code></p>
          
          <button onClick={fetchData} className="btn-refresh" disabled={loading}>
            {loading ? 'Sabar ya...' : 'Refresh Data'}
          </button>
        </section>

        <section className="display-area">
          {loading && <div className="loader">Sedang mengambil data dari IBM...</div>}
          
          {error && (
            <div className="error-card">
              <h3>⚠️ Koneksi Gagal</h3>
              <p>{error}</p>
              <p><small>Tips: Pastikan Backend sudah nyala dan CORS sudah di-set ke '*'</small></p>
            </div>
          )}

          {data && (
            <div className="result-card">
              <div className="card-header">
                <h3>{data.message}</h3>
                <span className="timestamp">{new Date(data.timestamp).toLocaleTimeString()}</span>
              </div>
              
              <div className="items-grid">
                {data.data.map((item) => (
                  <div key={item.id} className="item-box">
                    <h4>{item.name}</h4>
                    <p>{item.description}</p>
                  </div>
                ))}
              </div>
            </div>
          )}
        </section>
      </main>
    </div>
  );
}

export default App;