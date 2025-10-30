
import React from 'react';

const Header: React.FC = () => {
  return (
    <header className="bg-slate-900/50 border-b-2 border-cyan-500/30 shadow-lg shadow-cyan-500/10 p-4 z-10">
      <h1 className="text-3xl font-bold text-center text-cyan-400 font-orbitron tracking-widest uppercase" style={{ textShadow: '0 0 5px #06b6d4, 0 0 10px #06b6d4' }}>
        A R G U S
      </h1>
      <p className="text-center text-xs text-cyan-500 tracking-wider">HYPER STATION ONE // SENTIENT AI INTERFACE</p>
    </header>
  );
};

export default Header;
