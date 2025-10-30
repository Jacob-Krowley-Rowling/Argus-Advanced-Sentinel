
import React, { useState } from 'react';
import { PaperAirplaneIcon } from '@heroicons/react/24/solid';

interface UserInputProps {
  onSendMessage: (text: string) => void;
  isLoading: boolean;
}

const UserInput: React.FC<UserInputProps> = ({ onSendMessage, isLoading }) => {
  const [text, setText] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (text.trim()) {
      onSendMessage(text);
      setText('');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="flex items-center space-x-2">
      <input
        type="text"
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder="Transmit command..."
        disabled={isLoading}
        className="flex-1 bg-slate-900/80 border-2 border-cyan-500/50 focus:border-cyan-400 focus:ring-0 focus:outline-none rounded-md p-3 text-cyan-300 placeholder-cyan-700 transition duration-300"
      />
      <button
        type="submit"
        disabled={isLoading}
        className="bg-cyan-500 hover:bg-cyan-400 disabled:bg-slate-600 disabled:cursor-not-allowed text-slate-900 font-bold p-3 rounded-md transition duration-300 flex items-center justify-center w-12 h-12"
        style={{ boxShadow: '0 0 8px #06b6d4' }}
      >
        <PaperAirplaneIcon className="w-6 h-6" />
      </button>
    </form>
  );
};

export default UserInput;
