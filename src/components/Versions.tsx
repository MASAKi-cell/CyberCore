import { useState, useEffect } from 'react'
import { getVersion } from '@tauri-apps/api/app'

function Versions(): React.JSX.Element {
  const [version, setVersion] = useState('')

  useEffect(() => {
    getVersion().then(setVersion)
  }, [])

  return (
    <ul className="versions">
      <li className="app-version">CyberCore v{version}</li>
    </ul>
  )
}

export default Versions
