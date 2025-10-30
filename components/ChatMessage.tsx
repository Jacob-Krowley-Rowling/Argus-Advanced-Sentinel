
import React from 'react';
import { Message, ChatRole } from '../types';

interface ChatMessageProps {
  message: Message;
}

const ChatMessage: React.FC<ChatMessageProps> = ({ message }) => {
  const isUser = message.role === ChatRole.User;
  const isModel = message.role === ChatRole.Model;
  const isError = message.role === ChatRole.Error;

  const wrapperClasses = `flex items-start ${isUser ? 'justify-end' : 'justify-start'}`;
  const bubbleClasses = `max-w-xl p-3 rounded-lg shadow-md text-sm md:text-base ${
    isUser
      ? 'bg-slate-700 text-slate-100 rounded-br-none'
      : isModel
      ? 'bg-slate-900/70 border border-cyan-500/30 text-cyan-300 rounded-bl-none'
      : 'bg-red-900/70 border border-red-500/50 text-red-300 rounded-bl-none'
  }`;

  const UserAvatar: React.FC = () => (
    <div className="w-10 h-10 flex-shrink-0 ml-3">
        <div className="w-full h-full rounded-full bg-slate-600 border-2 border-slate-400 flex items-center justify-center font-bold text-slate-300 font-orbitron text-xs">OP</div>
    </div>
  );

  const ModelAvatar: React.FC = () => (
    <div className="w-10 h-10 flex-shrink-0 mr-3">
        <div className="w-full h-full rounded-full bg-cyan-900/50 border-2 border-cyan-500 flex items-center justify-center font-bold text-cyan-400 font-orbitron text-xs">A</div>
    </div>
  );

  return (
    <div className={wrapperClasses}>
      {!isUser && <ModelAvatar />}
      <div className={bubbleClasses}>
        <p className="whitespace-pre-wrap">{message.content}</p>
      </div>
      {isUser && <UserAvatar />}
    </div>
  );
};

export default ChatMessage;
