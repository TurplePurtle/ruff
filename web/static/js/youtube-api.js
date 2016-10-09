const apiReadyPromise = new Promise(function(ok, err) {
  window.onYouTubeIframeAPIReady = () => ok(YT);
});

const SCRIPT_TAG_ID = "YT-API-script";

function load() {
  if (!document.getElementById(SCRIPT_TAG_ID)) {
    var tag = document.createElement("script");
    tag.id = SCRIPT_TAG_ID;
    tag.src = "https://www.youtube.com/iframe_api";
    document.head.appendChild(tag);
  }

  return apiReadyPromise;
}

export default {
  load,
  ready: apiReadyPromise,
};
