class VideoController {
  constructor(player) {
    this.player = player;
    this.onStateChange = null;

    player.addEventListener("onStateChange", e => {
      if (typeof this.onStateChange === "function") {
        const state = VideoController.youTubeStateToString[e.data];
        this.onStateChange({
          data: state,
          target: this,
        });
      }
    });
  }

  static getYouTubeId(url) {
    const a = document.createElement('a');
    a.href = url;
    if (/youtube\.com$/.test(a.hostname)) {
      const params = a.search.slice(1).split('&').reduce((params, x) => {
        const [name, value] = x.split('=');
        params[name] = value;
        return params;
      }, {});
      return params.v;
    } else if (/youtu\.be$/.test(a.hostname)) {
      return a.pathname.slice(1);
    } else {
      return '';
    }
  }

  load(url, time) {
    this.player.loadVideoById(VideoController.getYouTubeId(url), time);
    return this;
  }

  cue(url, time) {
    this.player.cueVideoById(VideoController.getYouTubeId(url), time);
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
  "-1": "loading",
  "0": "ended",
  "1": "playing",
  "2": "paused",
  "3": "buffering",
  "5": "cued",
};

export default VideoController;
