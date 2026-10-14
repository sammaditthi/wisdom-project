import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// The emblem, as the install screens and the reader's first-run hint show it.
/// `#boot` in web/index.html shows the same file at the same size.
class AppEmblem extends StatelessWidget {
  const AppEmblem({super.key});

  static const double size = 96;

  /// Made by assets/icons/make_icons.sh, with 2.0x/, 3.0x/ and 4.0x/ copies.
  static const String asset = 'assets/icons/emblem.webp';

  /// Picks the copy for the screen's density, drawn 1:1 on 1x–4x screens:
  /// shrinking one large copy leaves jagged edges. main.dart starts loading it
  /// early on web.
  static const ImageProvider image = AssetImage(asset);

  @override
  Widget build(BuildContext context) {
    return _SnapToPixels(
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      child: Image(
        image: image,
        width: size,
        height: size,
        excludeFromSemantics: true,
        // A failed load leaves the space empty, so nothing around it moves.
        errorBuilder: (context, error, stackTrace) =>
            const SizedBox.square(dimension: size),
      ),
    );
  }
}

/// Paints its child on whole screen pixels, as browsers do with images.
/// Flutter paints at the exact layout position, so when the layout puts the
/// emblem part of a pixel off, each of its pixels is blended over two.
class _SnapToPixels extends SingleChildRenderObjectWidget {
  const _SnapToPixels({required this.devicePixelRatio, super.child});

  final double devicePixelRatio;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSnapToPixels(devicePixelRatio);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSnapToPixels renderObject,
  ) {
    renderObject.devicePixelRatio = devicePixelRatio;
  }
}

class _RenderSnapToPixels extends RenderProxyBox {
  _RenderSnapToPixels(this._devicePixelRatio);

  double _devicePixelRatio;
  set devicePixelRatio(double value) {
    if (value == _devicePixelRatio) return;
    _devicePixelRatio = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Offset onScreen = localToGlobal(Offset.zero);
    double nudge(double x) =>
        (x * _devicePixelRatio).roundToDouble() / _devicePixelRatio - x;
    super.paint(
        context, offset + Offset(nudge(onScreen.dx), nudge(onScreen.dy)));
  }
}
