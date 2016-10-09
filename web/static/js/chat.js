import socket from "./socket";
import channel from "./lobby-channel";

function initChat() {
  const app = new Vue({
    el: "#app",
    data: {
      chatMessage: "",
      chatMessages: [],
      leader: null,
      users: {},
    },
    methods: {
      takeLeader() {
        channel.push("take_leader");
      },
      sendChatMessage() {
        if (!this.chatMessage) return;
        if (!socket.params.token) {
          if (confirm("Sign-up is required to send messages. Sign up now?")) {
            location.href = "/signup";
          }
          return;
        }

        channel.push("new_msg", { body: this.chatMessage });
        this.chatMessage = "";
      },
    },
  });

  channel.on("new_msg", payload => {
    app.chatMessages.push({
      timestamp: new Date().toLocaleString(),
      username: payload.username,
      body: payload.body,
    });
  });

  channel.on("channel_update", payload => {
    app.leader = payload.leader;
    app.users = payload.users;
  });

  return app;
}

var chat = initChat();

export default chat;
