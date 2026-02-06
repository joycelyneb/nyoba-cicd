import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const BACKEND_URL = (window._env_ && window._env_.REACT_APP_BACKEND_URL) || process.env.REACT_APP_BACKEND_URL || "http://localhost:5000";

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
        <h1>Nyoba CICD</h1>
        <p>Status: {loading ? "Loading..." : "Ready"}</p>
      </header>
      <main className="container content">
        {error && (
          <div className="error">
            <strong>Error:</strong> {error}
          </div>
        )}

        {loading && (
          <div className="message-box">
            <h3>Loading...</h3>
            <p>Fetching data from backend...</p>
          </div>
        )}

        {data && !loading && (
          <div className="data-container">
            <div className="message-box">
              <h3>{data.message}</h3>
              <p><strong>Timestamp:</strong> {data.timestamp}</p>
            </div>

            {data.data && data.data.length > 0 && (
              <div className="items-list">
                <h3>Items from Backend:</h3>
                <ul>
                  {data.data.map((item) => (
                    <li key={item.id} className="item">
                      <strong>ID: {item.id} - {item.name}</strong>
                      <p>{item.description}</p>
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>
        )}
      </main>
    </div>
  );
}

export default App;