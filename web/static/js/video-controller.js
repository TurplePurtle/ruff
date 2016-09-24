class VC {
  constructor(player) {
    this.player = player;
    this.onStateChange = null;

    player.addEventListener("onStateChange", e => {
      if (typeof this.onStateChange === "function") {
        const state = VC.youTubeStateToString[e.data];
        this.onStateChange({
          data: state,
          target: this,
        });
      }
    });
  }

  static getYouTubeId(url) {
    const match = url.match(VC.youTubeIdRegex);
    return match ? match[1] : null;
  }

  load(url, time) {
    this.player.loadVideoById(VC.getYouTubeId(url), time);
    return this;
  }

  cue(url, time) {
    this.player.cueVideoById(VC.getYouTubeId(url), time);
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

VC.youTubeIdRegex = /^.*(?:youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/i;

VC.youTubeStateToString = {
  "-1": "loading",
  "0": "ended",
  "1": "playing",
  "2": "paused",
  "3": "buffering",
  "5": "cued",
};

export default VC;
