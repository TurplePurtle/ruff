import socket from "./socket";
const channel = socket.channel("rooms:lobby", {});
export default channel;
