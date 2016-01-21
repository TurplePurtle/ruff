import socket from "./socket";

function timestamp() {
  var date = new Date();
  return date.toLocaleTimeString();
}

function initChat() {
  let chatInput = document.querySelector("#chat-input");
  let chatMessages = document.querySelector("#chat-messages");
  let chatForm = document.querySelector("#chat-form");

  if (!(chatInput && chatMessages && chatForm)) {
    return null;
  }

  let channel = socket.channel("rooms:lobby", {});

  chatForm.addEventListener("submit", e => {
    e.preventDefault();
    channel.push("new_msg", { body: chatInput.value });
    chatInput.value = "";
  });

  channel.on("new_msg", payload => {
    var message = document.createElement("div");
    message.textContent = `${timestamp()} - ${payload.body}`;
    chatMessages.insertBefore(message, chatMessages.firstChild);
  });

  socket.connect();
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp); })
    .receive("error", resp => { console.log("Unable to join", resp); });

  return {};
}

var chat = initChat();

export default chat;
