import socket from "./socket";
import channel from "./lobby-channel";
import VideoController from "./video-controller";

const _YTPromise = new Promise(function(ok, err) {
  window.onYouTubeIframeAPIReady = () => ok(YT);
});

function loadYouTubeAPI() {
  const tagId = "YT-API-script";
  if (!document.getElementById(tagId)) {
    var tag = document.createElement("script");
    tag.id = tagId;
    tag.src = "https://www.youtube.com/iframe_api";
    document.head.appendChild(tag);
  }

  return _YTPromise;
}

function initVideoController(videoPlayer) {
  return loadYouTubeAPI().then(YT => {
    return new Promise((ok, err) => {
      new YT.Player(videoPlayer, {
        width: "640",
        height: "390",
        events: {
          onReady: e => ok(e),
          onError: e => err(e),
        },
      });
    });
  }).then(playerReadyEvent => {
    return new VideoController(playerReadyEvent.target);
  });
}

function initVideoBox() {
  const videoPlayer = document.querySelector("#video-player");
  const videoForm = document.querySelector("#video-form");
  const videoInput = document.querySelector("#video-input");

  if (!videoPlayer) {
    return Promise.reject(new Error("Video player element not found"));
  }

  return initVideoController(videoPlayer).then(vc => {
    const expected = {};

    videoForm.addEventListener("submit", e => {
      e.preventDefault();
      if (!videoInput.value) return;
      vc.load(videoInput.value);
    });

    vc.onStateChange = e => {
      const state = e.data;
      switch (state) {
      case "loading":
        if (expected[state] > 0) { expected[state]--; break; }
        channel.push("video_state", { state: "loading", url: e.target.getUrl() });
        break;
      case "paused":
        if (expected[state] > 0) { expected[state]--; break; }
        channel.push("video_state", { state: "paused", time: e.target.getCurrentTime() });
        break;
      case "playing":
        if (expected[state] > 0) { expected[state]--; break; }
        channel.push("video_state", { state: "playing", time: e.target.getCurrentTime() });
        break;
      }
    };

    channel.on("video_state", payload => {
      if (payload.userId === userId) return;

      const state = payload.state;
      switch (state) {
      case "loading":
        expected[state] = (expected[state]||0) + 1;
        vc.load(payload.url);
        videoInput.value = payload.url;
        break;
      case "paused":
        expected[state] = (expected[state]||0) + 1;
        vc.pause();
        break;
      case "playing":
        expected[state] = (expected[state]||0) + 1;
        vc.seek(payload.time);
        vc.play();
        break;
      }
    });

    return vc;
  });
}

const video = initVideoBox();

export default video;
