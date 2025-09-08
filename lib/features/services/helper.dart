import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

Widget buildServiceImage({
  File? file,
  Uint8List? bytes,
  String? url,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  if (file != null) {
    return Image.file(file, height: height, fit: fit);
  } else if (bytes != null) {
    return Image.memory(bytes, height: height, fit: fit);
  } else if (url != null && url.isNotEmpty && url.startsWith('http')) {
    return Image.network(
      url,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
    );
  } else {
    return const Icon(Icons.image, size: 40, color: Colors.grey);
  }
}
