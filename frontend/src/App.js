import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // --- URL FIX DARI IBM CLOUD (Ganti URL ini jika nama project berubah) ---
  const BACKEND_URL = "https://nyoba-cicd-joy2-backend.25vc8mhbgyki.us-south.codeengine.appdomain.cloud";

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      // Panggil Backend
      const response = await fetch(`${BACKEND_URL}/api/data`);
      
      if (!response.ok) {
        throw new Error(`Gagal: ${response.status}`);
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
        <h1>IBM Cloud Fullstack</h1>
        <p>Status: {loading ? "Loading..." : "Ready"}</p>
      </header>
      <main className="container">
         {/* Tampilkan Data */}
         {data && <pre>{JSON.stringify(data, null, 2)}</pre>}
         {error && <p style={{color:'red'}}>{error}</p>}
      </main>
    </div>
  );
}

export default App;