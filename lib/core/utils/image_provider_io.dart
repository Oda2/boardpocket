import 'dart:io';

import 'package:flutter/widgets.dart';

import 'image_paths.dart';

/// Resolves a stored cover path into something Flutter can render.
///
/// Returns `null` when the path cannot be displayed (empty, or a local file
/// path while running somewhere without a filesystem).
ImageProvider? resolveImageProvider(String path) {
  if (path.isEmpty) return null;
  if (isRemoteImagePath(path)) return NetworkImage(path);
  return FileImage(File(path));
}
