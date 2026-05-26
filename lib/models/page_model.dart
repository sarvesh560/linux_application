class PdfPageModel {
  int pageNumber;
  bool selected;

  PdfPageModel({
    required this.pageNumber,
    this.selected=false,
  });

  PdfPageModel copy() {
    return PdfPageModel(
      pageNumber: pageNumber,
      selected: selected,
    );
  }
}