/// Helpers for interpreting the single `Game.imagePath` field.
///
/// A game cover can come from three places:
///  * a remote URL (Openverse / Wikimedia Commons search result) -> `https://...`
///  * a browser blob URL (image picked through the web file input) -> `blob:...`
///  * a real file on disk (image picked on mobile/desktop)      -> `/data/...`
library;

/// Whether [path] points at something the platform can load over the network.
bool isRemoteImagePath(String path) {
  final lower = path.toLowerCase();
  return lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.startsWith('blob:') ||
      lower.startsWith('data:');
}
