import { io } from "socket.io-client";

// Same-origin in dev (vite proxies /socket.io to the backend) and in a
// built/served-together deployment.
export const socket = io({ autoConnect: true });
