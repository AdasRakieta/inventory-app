part of '../../../../ok_mobile_scanner.dart';

class CameraScannerOverlay extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  CameraScannerOverlay scale(double t) => this;

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = AppColors.green
      ..strokeWidth = 2.0;

    const margin = 12.0;
    final adjustedRect = Rect.fromLTRB(
      rect.left + margin,
      rect.top + margin,
      rect.right - margin,
      rect.bottom - margin,
    );

    canvas
      //external border
      ..drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint..style = PaintingStyle.stroke,
      )
      // inside decoration
      ..drawLine(
        Offset(adjustedRect.left, adjustedRect.top),
        Offset(adjustedRect.left + 30, adjustedRect.top),
        paint,
      )
      ..drawLine(
        Offset(adjustedRect.left, adjustedRect.top),
        Offset(adjustedRect.left, adjustedRect.top + 30),
        paint,
      )
      ..drawLine(
        Offset(adjustedRect.right, adjustedRect.top),
        Offset(adjustedRect.right - 30, adjustedRect.top),
        paint,
      )
      ..drawLine(
        Offset(adjustedRect.right, adjustedRect.top),
        Offset(adjustedRect.right, adjustedRect.top + 30),
        paint,
      )
      ..drawLine(
        Offset(adjustedRect.left, adjustedRect.bottom),
        Offset(adjustedRect.left + 30, adjustedRect.bottom),
        paint,
      )
      ..drawLine(
        Offset(adjustedRect.left, adjustedRect.bottom),
        Offset(adjustedRect.left, adjustedRect.bottom - 30),
        paint,
      )
      ..drawLine(
        Offset(adjustedRect.right, adjustedRect.bottom),
        Offset(adjustedRect.right - 30, adjustedRect.bottom),
        paint,
      )
      ..drawLine(
        Offset(adjustedRect.right, adjustedRect.bottom),
        Offset(adjustedRect.right, adjustedRect.bottom - 30),
        paint,
      );
  }
}
