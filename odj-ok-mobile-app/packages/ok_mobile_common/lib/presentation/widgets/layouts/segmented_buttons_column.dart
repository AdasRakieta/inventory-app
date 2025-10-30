part of '../../../ok_mobile_common.dart';

class SegmentedButtonsColumn extends StatelessWidget {
  const SegmentedButtonsColumn({
    required this.buttonsSegments,
    required this.segmentTitles,
    super.key,
  });

  final List<List<Widget>> buttonsSegments;
  final List<Widget> segmentTitles;

  @override
  Widget build(BuildContext context) {
    assert(
      buttonsSegments.length == segmentTitles.length,
      'buttonsSegments and segmentTitles must have the same length',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
        buttonsSegments.length,
        (index) => index == buttonsSegments.length - 1
            ? segment(index)
            : Column(children: [segment(index), const SizedBox(height: 12)]),
      ),
    );
  }

  Widget segment(int index) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      segmentTitles[index],
      const SizedBox(height: 8),
      ButtonsColumn(buttons: buttonsSegments[index]),
    ],
  );
}
