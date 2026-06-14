import { useEffect, useState } from 'react'

function App() {
  const [health, setHealth] = useState(null)
  const [apiInfo, setApiInfo] = useState(null)

  useEffect(() => {
    fetch('/health')
      .then(res => res.json())
      .then(data => setHealth(data))
      .catch(() => setHealth({ status: 'erro' }))

    fetch('/api')
      .then(res => res.json())
      .then(data => setApiInfo(data))
      .catch(() => setApiInfo(null))
  }, [])

  return (
    <div style={{ fontFamily: 'sans-serif', padding: '2rem' }}>
      <h1>DashLab</h1>
      <p>Painel de monitoramento da aplicação</p>

      <div style={{ marginTop: '2rem', padding: '1rem', background: '#f0f0f0', borderRadius: '8px' }}>
        <h3>Status do Backend</h3>
        {health ? (
          <>
            <p>Status: <strong>{health.status}</strong></p>
            <p>Timestamp: {health.timestamp}</p>
            <p>Version: <strong>{apiInfo?.version ?? '-'}</strong></p>
          </>
        ) : (
          <p>Carregando...</p>
        )}
      </div>
    </div>
  )
}

export default App