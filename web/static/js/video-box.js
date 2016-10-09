import socket from "./socket";
import channel from "./lobby-channel";
import VideoController from "./video-controller";

function initVideoBox() {
  const videoPlayer = document.querySelector("#video-player");
  const videoForm = document.querySelector("#video-form");
  const videoInput = document.querySelector("#video-input");

  if (!videoPlayer) {
    return Promise.reject(new Error("Video player element not found"));
  }

  return new VideoController(videoPlayer).ready.then(vc => {
    videoForm.addEventListener("submit", e => {
      e.preventDefault();
      if (videoInput.value) vc.load(videoInput.value);
    });

    const incomingStateHandlers = {
      unstarted: payload => {
        vc.load(payload.url);
        videoInput.value = payload.url;
      },
      paused: payload => {
        vc.pause();
      },
      playing: payload => {
        vc.seek(payload.time);
        vc.play();
      },
    };

    const outgoingStateHandlers = {
      unstarted: ({target: video}) => {
        channel.push("video_state", { state: "unstarted", url: video.getUrl() });
      },
      paused: ({target: video}) => {
        channel.push("video_state", { state: "paused", time: video.getCurrentTime() });
      },
      playing: ({target: video}) => {
        channel.push("video_state", { state: "playing", time: video.getCurrentTime() });
      },
    };

    channel.on("video_state", payload => {
      const handler = incomingStateHandlers[payload.state];
      if (handler) handler(payload);
    });

    vc.onStateChange = e => {
      const handler = outgoingStateHandlers[e.data];
      if (handler) handler(e);
    };

    return vc;
  });
}

const videoBox = initVideoBox();

export default videoBox;
