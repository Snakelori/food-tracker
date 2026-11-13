// Enregistrement du service worker (sorti de index.html pour permettre une CSP stricte)
if ("serviceWorker" in navigator) {
  window.addEventListener("load", () =>
    navigator.serviceWorker.register("sw.js").catch(() => {}));
}
