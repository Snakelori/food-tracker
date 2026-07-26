// Service Worker — cache applicatif (coquille hors-ligne)
// Les données Supabase ne sont jamais mises en cache (toujours en réseau).
const CACHE = "journal-v1";
const ASSETS = [
  "./",
  "./index.html",
  "./css/styles.css",
  "./config.js",
  "./js/app.js",
  "./js/supabase.js",
  "./manifest.webmanifest",
  "./assets/icons/icon-192.png",
  "./assets/icons/icon-512.png",
];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  const url = new URL(e.request.url);
  // Ne jamais mettre en cache les appels API (Supabase, esm.sh, auth)
  if (url.origin !== location.origin) return;
  if (e.request.method !== "GET") return;

  // Réseau d'abord pour le HTML, cache d'abord pour les assets statiques
  if (e.request.mode === "navigate") {
    e.respondWith(fetch(e.request).catch(() => caches.match("./index.html")));
    return;
  }
  e.respondWith(
    caches.match(e.request).then((cached) => cached || fetch(e.request))
  );
});
