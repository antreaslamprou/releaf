'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"404.html": "a4e2271d19eb1f6f93a15e1b7a4e74dd",
"assets/AssetManifest.bin": "8747a872cf798f2134d8d4bc24435603",
"assets/AssetManifest.bin.json": "2c505e13dee195eab40a5489e354552b",
"assets/assets/images/badge.png": "a0004b39af14135de8ba743b9e4df07e",
"assets/assets/images/logo.png": "5610b80e0958651f5c11811d63d2de53",
"assets/assets/images/prohibited.png": "c8f3023f7701a93dd241a99161f8aa12",
"assets/assets/images/sdg1.png": "0b4541ce16c29863582a7857f5c84242",
"assets/assets/images/sdg10.png": "ebe0c70ba54862b7298e6537e2aa7a0b",
"assets/assets/images/sdg11.png": "416525de98a4f10de0475638e35d6168",
"assets/assets/images/sdg12.png": "86687e14fe669c6557f3faac52cc0d69",
"assets/assets/images/sdg13.png": "158afc987a189ba4cb608bf864ea9c2f",
"assets/assets/images/sdg14.png": "800303828c3dbdb0dbadddf702f5dc9c",
"assets/assets/images/sdg15.png": "1967c289b26218cab8a94443c88501f6",
"assets/assets/images/sdg16.png": "0d576cc6e7d3a8dfa6e008a8f8d87030",
"assets/assets/images/sdg17.png": "f1e8a83f064d0fac826e4870346c66f0",
"assets/assets/images/sdg2.png": "e87be09473ca033e7454d8c860d46084",
"assets/assets/images/sdg3.png": "8f32123ad34bb393240b0111497a9faf",
"assets/assets/images/sdg4.png": "600f43c9319b74ba368fabc9a70f6102",
"assets/assets/images/sdg5.png": "a1e43b652e8980982880eab0e01cfce8",
"assets/assets/images/sdg6.png": "e5a3d81bdf9800dfa7a5ed660c212c45",
"assets/assets/images/sdg7.png": "a93b1592c137315dabd500429722a459",
"assets/assets/images/sdg8.png": "9cb429d1bbe4b39b56d5767d47ccc987",
"assets/assets/images/sdg9.png": "0a79d1aef7528907c1769f6992e40747",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "e8b1271519ce8676462a0395ece8819e",
"assets/NOTICES": "6a52fe95f092a2823aef38e7cf9acc9c",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/fluttermoji/attributeicons/accessories.svg": "0b8839e003a89232edec0e09cb12fa2b",
"assets/packages/fluttermoji/attributeicons/beard.svg": "908ac523ce1c704be65e254aa4a04e31",
"assets/packages/fluttermoji/attributeicons/beardcolor.svg": "8fa1ec767cfa14371ca15a47126049ba",
"assets/packages/fluttermoji/attributeicons/eyebrow.svg": "cf66096dacdfb6af807cd745fc724e9a",
"assets/packages/fluttermoji/attributeicons/eyes.svg": "cfbbbeb9cc3b40c6a561166ad07fc56c",
"assets/packages/fluttermoji/attributeicons/hair.svg": "0044380b1c40c321c8a65da5b8e77a0c",
"assets/packages/fluttermoji/attributeicons/haircolor.svg": "5756eb4c957d15ea7fcc37c1835488ac",
"assets/packages/fluttermoji/attributeicons/mouth.svg": "af3193d2a407e09fa1156f0f3c30ea86",
"assets/packages/fluttermoji/attributeicons/outfit.svg": "f36789fda25e7b3746835daf0ec7c0dc",
"assets/packages/fluttermoji/attributeicons/outfitcolor.svg": "e8f931206db9c6ab01a6b4c22c23bf4d",
"assets/packages/fluttermoji/attributeicons/skin.svg": "5f58e197768b8da582fbe8219daf164d",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "83e41ba47984d55fe187e9a30940250c",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "31ee17b3125afe060aa470217436d7f1",
"icons/Icon-192.png": "3dba8ae5156bf2799d9f72fed659feb2",
"icons/Icon-512.png": "0c546d99201074b66f7832586a430367",
"icons/Icon-maskable-192.png": "3dba8ae5156bf2799d9f72fed659feb2",
"icons/Icon-maskable-512.png": "0c546d99201074b66f7832586a430367",
"index.html": "5f3090c3fa192f331c73549e47d58bea",
"/": "5f3090c3fa192f331c73549e47d58bea",
"main.dart.js": "d0b45388b2a2fdec2efcd64cb51f357c",
"manifest.json": "a263d4ad74f419729bb04d1a4dddc608",
"version.json": "e19bc8443fe83554d2bdbd9b12a1e3d2"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
