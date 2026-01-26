import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      // Memanggil backend API
      const response = await fetch('http://localhost:5000/api/data');
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      const result = await response.json();
      setData(result);
    } catch (error) {
      setError(error.message);
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>Nyoba dulu</h1>
        <p>Nyoba dulu guys</p>
      </header>

      <main>
        <div className="content">
          <h2>Data dari Backend</h2>
          <button onClick={fetchData} className="btn-refresh">
            Refresh Data
          </button>

          {loading && <p className="status">Loading...</p>}
          {error && <p className="error">Error: {error}</p>}

          {data && (
            <div className="data-container">
              <div className="message-box">
                <h3>{data.message}</h3>
                <p>Waktu: {new Date(data.timestamp).toLocaleString()}</p>
              </div>

              <div className="items-list">
                <h3>Data Items:</h3>
                <ul>
                  {data.data.map((item) => (
                    <li key={item.id} className="item">
                      <strong>{item.name}</strong>
                      <p>{item.description}</p>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

export default App;
