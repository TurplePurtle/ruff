import socket from "./socket";
import channel from "./lobby-channel";
import chat from "./chat";
import videoBox from "./video-box";

videoBox.then(() => {
  socket.connect();
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp); })
    .receive("error", resp => { console.log("Unable to join", resp); });
})
