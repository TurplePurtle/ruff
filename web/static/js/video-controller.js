import ytApi from "./youtube-api";

class VideoController {
  constructor(videoPlayer, width = 640, height = Math.ceil(9/16*width)) {
    this.player = null;
    this.onStateChange = null;
    this.apiReady = ytApi.load();
    this.playerReady = this.initPlayer(videoPlayer, width, height);
    this.ready = this.playerReady.then(() => this);

    this.addPlayerEventListener();
  }

  static getYouTubeId(url) {
    if (/^[\w\-]{11}$/.test(url)) {
      return url;
    }
    const urlParser = document.createElement('a');
    urlParser.href = url;
    if (/youtube\.com$/.test(urlParser.hostname)) {
      const params = urlParser.search.slice(1).split('&').reduce((params, x) => {
        const [name, value] = x.split('=');
        params[name] = value;
        return params;
      }, {});
      return params.v;
    } else if (/youtu\.be$/.test(urlParser.hostname)) {
      return urlParser.pathname.slice(1);
    } else {
      return '';
    }
  }

  addPlayerEventListener() {
    this.playerReady.then(player => {
      player.addEventListener("onStateChange", e => {
        if (typeof this.onStateChange === "function") {
          const state = VideoController.youTubeStateToString[e.data];
          this.onStateChange({ data: state, target: this });
        }
      })
    });
  }

  initPlayer(videoPlayer, width, height) {
    return this.apiReady.then(YT => {
      return new Promise((ok, err) => {
        new YT.Player(videoPlayer, {
          width: width,
          height: height,
          events: {
            onReady: ok,
            onError: err,
          },
        });
      });
    }).then(playerReadyEvent => {
      return this.player = playerReadyEvent.target;
    });
  }

  load(url, time) {
    const videoId = VideoController.getYouTubeId(url);
    if (videoId) this.player.loadVideoById(videoId, time);
    return this;
  }

  cue(url, time) {
    const videoId = VideoController.getYouTubeId(url);
    if (videoId) this.player.cueVideoById(videoId, time);
    return this;
  }

  play() {
    this.player.playVideo();
    return this;
  }

  pause() {
    this.player.pauseVideo();
    return this;
  }

  stop() {
    this.player.stopVideo();
    return this;
  }

  seek(time) {
    this.player.seekTo(time);
    return this;
  }

  getCurrentTime() {
    return this.player.getCurrentTime();
  }

  getUrl() {
    return this.player.getVideoUrl();
  }
}

VideoController.youTubeStateToString = {
  "-1": "unstarted",
  "0": "ended",
  "1": "playing",
  "2": "paused",
  "3": "buffering",
  "5": "cued",
};

export default VideoController;
