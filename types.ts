
export enum ChatRole {
  User = 'user',
  Model = 'model',
  Error = 'error',
}

export interface Message {
  role: ChatRole;
  content: string;
}
