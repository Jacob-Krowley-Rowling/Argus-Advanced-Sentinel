
import React, { useState, useRef, useEffect, useCallback } from 'react';
import { Message, ChatRole } from '../types';
import { createChat } from '../services/geminiService';
import ChatMessage from './ChatMessage';
import UserInput from './UserInput';
import { Chat } from '@google/genai';

const ChatInterface: React.FC = () => {
  const [messages, setMessages] = useState<Message[]>([
    {
      role: ChatRole.Model,
      content: "ARGUS online. System ready. State your request, Operator.",
    },
  ]);
  const [isLoading, setIsLoading] = useState(false);
  const chatRef = useRef<Chat | null>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    chatRef.current = createChat();
  }, []);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSendMessage = useCallback(async (text: string) => {
    if (isLoading || !text.trim()) return;

    setIsLoading(true);
    const newUserMessage: Message = { role: ChatRole.User, content: text };
    setMessages((prev) => [...prev, newUserMessage]);

    const modelResponsePlaceholder: Message = { role: ChatRole.Model, content: '' };
    setMessages((prev) => [...prev, modelResponsePlaceholder]);

    try {
      if (!chatRef.current) {
          throw new Error("Chat not initialized");
      }
      
      const stream = await chatRef.current.sendMessageStream({ message: text });
      
      let fullResponse = "";
      for await (const chunk of stream) {
        fullResponse += chunk.text;
        setMessages((prev) => {
          const newMessages = [...prev];
          newMessages[newMessages.length - 1].content = fullResponse;
          return newMessages;
        });
      }

    } catch (error) {
      console.error('Gemini API Error:', error);
      const errorMessage: Message = { role: ChatRole.Error, content: "Connection error to core sentience. Please check console." };
      setMessages((prev) => {
          const newMessages = [...prev];
          newMessages[newMessages.length - 1] = errorMessage;
          return newMessages;
      });
    } finally {
      setIsLoading(false);
    }
  }, [isLoading]);

  return (
    <div className="flex flex-col flex-1 h-full bg-slate-800/50 backdrop-blur-sm p-4 relative">
        <div className="flex-1 overflow-y-auto pr-2 space-y-4">
            {messages.map((msg, index) => (
                <ChatMessage key={index} message={msg} />
            ))}
            {isLoading && messages[messages.length-1].role === ChatRole.Model && (
                 <div className="flex items-center justify-start">
                    <div className="w-10 h-10 flex-shrink-0 mr-3">
                      <div className="w-full h-full rounded-full bg-cyan-900/50 border-2 border-cyan-500 flex items-center justify-center font-bold text-cyan-400 font-orbitron text-xs">A</div>
                    </div>
                    <div className="animate-pulse flex space-x-1">
                      <div className="w-2 h-2 bg-cyan-400 rounded-full"></div>
                      <div className="w-2 h-2 bg-cyan-400 rounded-full animation-delay-200"></div>
                      <div className="w-2 h-2 bg-cyan-400 rounded-full animation-delay-400"></div>
                    </div>
                 </div>
            )}
            <div ref={messagesEndRef} />
        </div>
        <div className="mt-4">
            <UserInput onSendMessage={handleSendMessage} isLoading={isLoading} />
        </div>
    </div>
  );
};

export default ChatInterface;
