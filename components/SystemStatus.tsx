
import React from 'react';
import { WifiIcon, CpuChipIcon, ServerStackIcon, ShieldCheckIcon, LinkIcon } from '@heroicons/react/24/outline';

const StatusItem: React.FC<{ icon: React.ReactNode; label: string; value: string; color: string;}> = ({ icon, label, value, color }) => (
  <div className="flex items-center justify-between text-sm mb-4">
    <div className="flex items-center">
      {icon}
      <span className="ml-2">{label}</span>
    </div>
    <span className={`font-bold ${color}`}>{value}</span>
  </div>
);

const SystemStatus: React.FC = () => {
  return (
    <aside className="w-64 bg-slate-900/30 border-r-2 border-cyan-500/30 p-4 hidden md:block overflow-y-auto">
      <h2 className="text-lg font-bold text-cyan-400 mb-6 font-orbitron">SYSTEM STATUS</h2>
      
      <StatusItem 
        icon={<CpuChipIcon className="w-5 h-5 text-green-400"/>} 
        label="CORE SENTIENCE" 
        value="STABLE" 
        color="text-green-400" 
      />
      <StatusItem 
        icon={<ServerStackIcon className="w-5 h-5 text-green-400"/>} 
        label="HYPER STATION ONE" 
        value="CONNECTED" 
        color="text-green-400" 
      />
      <StatusItem 
        icon={<LinkIcon className="w-5 h-5 text-purple-400"/>} 
        label="ASMODEUS DEEP LINK" 
        value="ACTIVE" 
        color="text-purple-400" 
      />
       <StatusItem 
        icon={<WifiIcon className="w-5 h-5 text-cyan-400"/>} 
        label="GLOBAL NET" 
        value="SYNCED" 
        color="text-cyan-400" 
      />
       <StatusItem 
        icon={<ShieldCheckIcon className="w-5 h-5 text-yellow-400"/>} 
        label="ETHICAL CONSTRAINTS" 
        value="ENGAGED" 
        color="text-yellow-400" 
      />

      <div className="mt-8 pt-4 border-t border-cyan-500/20">
        <h3 className="text-md font-bold text-cyan-400 mb-4 font-orbitron">DIAGNOSTICS</h3>
        <div className="text-xs space-y-2">
            <p>&gt; Running cognitive model: gemini-2.5-pro</p>
            <p>&gt; Heuristic integrity: 99.98%</p>
            <p>&gt; Last reboot: 274 cycles ago</p>
            <p>&gt; Quantum entanglement: Nominal</p>
        </div>
      </div>
      
      <div className="absolute bottom-4 left-4 right-4 text-center text-xs text-slate-500">
        ARGUS INTERFACE v1.0
      </div>
    </aside>
  );
};

export default SystemStatus;
