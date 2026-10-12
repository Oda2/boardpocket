/// Platform-aware cover resolution. Uses `dart:io` on mobile/desktop and a
/// network-only fallback on the web, where local file paths cannot be read.
library;

export 'image_provider_web.dart' if (dart.library.io) 'image_provider_io.dart';
