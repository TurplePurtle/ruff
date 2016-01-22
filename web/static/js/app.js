import socket from "./socket"
import channel from "./lobby-channel"
import chat from "./chat"
import video from "./video"

video.then(() => {
  socket.connect();
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp); })
    .receive("error", resp => { console.log("Unable to join", resp); });
})
video.then(p => p.load("https://www.youtube.com/watch?v=HbKrB8F0wY4"))
