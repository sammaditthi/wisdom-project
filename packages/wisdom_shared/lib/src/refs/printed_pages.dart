import '../constants/tipitaka_node_keys.dart';

/// The printed page of each side of one BJT source page.
typedef PrintedPages = ({int pali, int? sinhala});

/// BJT prints the Pali on an even left page and its Sinhala on the facing odd
/// one, so [pageNum] is the Pali page. Null for commentaries and treatises,
/// whose `pageNum`s match no printed page we can check. `sinhala` is null on a
/// page with no Sinhala (Paṭṭhāna). The source's `pageOffset` only locates scan
/// images and is never part of the printed number.
PrintedPages? printedPages(
  String fileId,
  int? pageNum, {
  required bool hasSinhala,
}) {
  if (pageNum == null ||
      fileId.startsWith(TipitakaNodeKeys.commentary) ||
      fileId.startsWith(TipitakaNodeKeys.treatises)) {
    return null;
  }
  return (pali: pageNum, sinhala: hasSinhala ? pageNum + 1 : null);
}
