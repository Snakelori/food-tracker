// Service Worker — cache applicatif (coquille hors-ligne)
// Stratégie « réseau d'abord » : on récupère toujours la dernière version
// quand la connexion est là, et on retombe sur le cache uniquement hors-ligne.
// Les appels API (Supabase, esm.sh) ne sont jamais interceptés.
const CACHE = "journal-v2";
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
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  const url = new URL(e.request.url);
  // Ne gérer que nos propres fichiers ; laisser passer Supabase / esm.sh / etc.
  if (url.origin !== location.origin) return;
  if (e.request.method !== "GET") return;

  // Réseau d'abord, cache en secours (hors-ligne) — garantit des mises à jour immédiates.
  e.respondWith(
    fetch(e.request)
      .then((res) => {
        const copy = res.clone();
        caches.open(CACHE).then((c) => c.put(e.request, copy)).catch(() => {});
        return res;
      })
      .catch(() =>
        caches.match(e.request).then((cached) =>
          cached || (e.request.mode === "navigate" ? caches.match("./index.html") : Response.error())
        )
      )
  );
});
