module.exports = {
  globDirectory: 'build/web/',
  globPatterns: [
    '**/*.{js,css,html,png,svg,ico,woff2}',
  ],
  globIgnores: [
    'flutter_service_worker.js',
  ],
  swSrc: 'web/sw.js',
  swDest: 'build/web/sw.js',
};
