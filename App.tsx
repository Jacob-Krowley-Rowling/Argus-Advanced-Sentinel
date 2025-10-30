
import React from 'react';
import Header from './components/Header';
import ChatInterface from './components/ChatInterface';
import SystemStatus from './components/SystemStatus';

const App: React.FC = () => {
  return (
    <div className="flex flex-col h-screen bg-slate-900 text-cyan-300 font-mono overflow-hidden">
      <Header />
      <div className="flex flex-1 overflow-hidden">
        <SystemStatus />
        <main className="flex-1 flex flex-col">
          <ChatInterface />
        </main>
      </div>
    </div>
  );
};

export default App;
