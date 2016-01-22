function VC(player) {
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

VC.youTubeStateToString = {
  "-1": "loading",
  "0": "ended",
  "1": "playing",
  "2": "paused",
  "3": "buffering",
  "5": "cued",
};

VC.getYouTubeId = function(url) {
  const regex = /^.*(?:youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/i;
  const match = url.match(regex);
  return match ? match[1] : null;
};

VC.prototype.load = function(url, time) {
  this.player.loadVideoById(VC.getYouTubeId(url), time);
  return this;
};

VC.prototype.cue = function(url, time) {
  this.player.cueVideoById(VC.getYouTubeId(url), time);
  return this;
};

VC.prototype.play = function() {
  this.player.playVideo();
  return this;
};

VC.prototype.pause = function() {
  this.player.pauseVideo();
  return this;
};

VC.prototype.stop = function() {
  this.player.stopVideo();
  return this;
};

VC.prototype.seek = function(time) {
  this.player.seekTo(time);
};

VC.prototype.getCurrentTime = function() {
  return this.player.getCurrentTime();
};

VC.prototype.getUrl = function() {
  return this.player.getVideoUrl();
};

export default VC;
