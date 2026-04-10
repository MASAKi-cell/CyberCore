import Versions from './components/Versions'

function App(): React.JSX.Element {
  return (
    <>
      <div className="creator">Powered by Tauri + React</div>
      <div className="text">
        Build a Tauri app with <span className="react">React</span>
        &nbsp;and <span className="ts">TypeScript</span>
      </div>
      <p className="tip">
        Please try pressing <code>F12</code> to open the devTool
      </p>
      <Versions />
    </>
  )
}

export default App
