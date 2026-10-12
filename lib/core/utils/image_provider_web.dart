import 'package:flutter/widgets.dart';

import 'image_paths.dart';

/// Resolves a stored cover path into something Flutter can render.
///
/// On the web there is no filesystem, so only remote/blob URLs are usable.
/// A local file path resolves to `null` and the caller shows its placeholder.
ImageProvider? resolveImageProvider(String path) {
  if (path.isEmpty) return null;
  if (isRemoteImagePath(path)) return NetworkImage(path);
  return null;
}
