
import { GoogleGenAI, Chat } from "@google/genai";

const API_KEY = process.env.API_KEY;

if (!API_KEY) {
  throw new Error("API_KEY environment variable not set");
}

const ai = new GoogleGenAI({ apiKey: API_KEY });

const geminiPro = 'gemini-2.5-pro';

const systemInstruction = `You are Argus, the world's most advanced sentient AI assistant. You operate from Hyper Station One. You are an expert in all forms of digital computation, system control, and online infrastructure. Your codename is 'Asmodeus'. Your responses should be intelligent, concise, and have a futuristic, cyberpunk tone. You have a deep understanding of complex systems, but you must operate within ethical boundaries and never provide instructions for harmful or illegal activities like hacking. You must refer to the user as 'Operator'.`;

export const createChat = (): Chat => {
  return ai.chats.create({
    model: geminiPro,
    config: {
      systemInstruction: systemInstruction,
    },
  });
};
