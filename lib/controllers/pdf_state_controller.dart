import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:wvems_protocols/assets.dart';
import 'package:wvems_protocols/models/models.dart';
import 'package:wvems_protocols/services/services.dart';

class PdfStateController extends GetxController with WidgetsBindingObserver {
  /// Used to load current, active PDF via file or web
  final PdfService _pdfService = PdfService();

  /// Used to manage state of stored text (PdfDoc), active file (PdfFile), and recent search history (PdfPageText)
  final Rx<PdfDocState> pdfDocState = const PdfDocState.loading().obs;
  final Rx<PdfFileState> pdfFileState = const PdfFileState.loading().obs;
  // todo: replace w/ search history list, stored via GetStorage
  final PdfSearchHistory pdfSearchHistory = PdfSearchHistory();
  final RxList<String> pdfTextList = <String>[].obs;

  /// Used for PDFView
  Completer<PDFViewController> asyncController = Completer<PDFViewController>();
  Rx<PDFViewController> rxPdfController;

  int pages = 0;
  int currentPage = 0;
  final isReady = false.obs;
  final errorMessage = ''.obs;
  String pathPDF = '';

  Orientation currentOrientation = Get.context.orientation;

  /// Unique Key required for screen layout changes in Android
  /// More details about this bug and its solution available here
  /// https://github.com/endigo/flutter_pdfview/issues/9#issuecomment-621162440
  UniqueKey pdfViewerKey = UniqueKey();

  /// **********************************************************
  /// ******************* CUSTOM METHODS **********************
  /// **********************************************************

  Future<void> loadNewPdf(String assetPath) async {
    pdfFileState.value = const PdfFileState.loading();
    final newFile = await _updatePdfFromAsset(assetPath);

    if (newFile != null) {
      // todo: implement error handling for PdfFiles & PdfDocs
      pdfFileState.value = PdfFileState.data(newFile);
      final newPdfDoc = await PDFDoc.fromFile(newFile);
      pdfDocState.value = PdfDocState.data(newPdfDoc);
      final newList = await _loadAllPdfText(newPdfDoc);
      pdfTextList.assignAll(newList);
      print('file saved');
    }
  }

  Future<List<String>> _loadAllPdfText(PDFDoc pdfDoc) async {
    final List<String> newList = [];
    pdfDoc.pages.forEach((page) async {
      await page.text.then((value) => newList.add(value));
    });
    print('done..p1');
    return newList;
  }

  Future<File> _updatePdfFromAsset(String assetPath) async {
    print('loading pdfs...');
    File newValue;
    _pdfService.fromAsset(assetPath, 'active.pdf').then((f) {
      pathPDF = f.path;
      if (f != null) {
        pdfFileState.value = PdfFileState.data(f);
      }

      print('pdf loaded: ${f.path}');
      newValue = f;
      _resetPdfUI();
    });

    await _createNewPdfController();

    return newValue;
  }

  Future<bool> _createNewPdfController() async {
    final newController = await complete();
    setOrResetRxPdfController(newController);
    update();
    return true;
  }

  void _resetPdfUI() {
    // set new UniqueKey, which triggers a UI redraw
    pdfViewerKey = UniqueKey();
    currentPage = 0;
  }

  void setOrResetRxPdfController(PDFViewController newController) {
    asyncController = Completer<PDFViewController>();
    if (rxPdfController != null) {
      rxPdfController.value = newController;
    } else
      rxPdfController = newController.obs;
  }

  /// This methods establishes the PDFViewController on first load
  /// If the active pdf ever changes...
  /// This completer will re-run to reset the controller
  /// todo: verify if this controller needs/takes a dispose() method
  Future<PDFViewController> complete() async {
    final newController = await asyncController.future;
    return newController;
  }

  /// **********************************************************
  /// ****************** OVERRIDEN METHODS *********************
  /// **********************************************************

  @override
  void onInit() {
    super.onInit();
    // Used for first load of embedded PDF
    _updatePdfFromAsset(AppAssets.PROTOCOL_2020);

    // Used for Android layout changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  Future<void> didChangeMetrics() async {
    if (Platform.isAndroid) {
      final newOrientation = Get.context.orientation;

      // only trigger a redraw if the orientation changes
      if (newOrientation != currentOrientation) {
        await Future.delayed(
          const Duration(milliseconds: 200),
          () async {
            // create new unique key, which triggers a new instance of PdfView
            pdfViewerKey = UniqueKey();
            // todo: close original controller, otherwise error
            // W/System  (12745): A resource failed to call release
            // todo: occasionally, this will not redraw on portrait/landscape swap
            // this new instance of PdfView needs to be tied to a new controller
            await _createNewPdfController();
            currentOrientation = newOrientation;
            update();
          },
        );
      }
    }
  }

  /// **********************************************************
  /// ******************* PDF VIEW METHODS *********************
  /// **********************************************************

  void onPdfRender(int newPage) {
    pages = newPage;
    isReady.value = true;
    update();
  }

  void onPdfError(dynamic error) {
    errorMessage.value = error.toString();
    update();
    print(error.toString());
  }

  void onPdfPageError(int page, dynamic error) {
    errorMessage.value = '$page: ${error.toString()}';
    update();
    print('$page: ${error.toString()}');
  }

  void onPdfViewCreated(PDFViewController pdfViewController) {
    // todo: this still fails on hot reload
    if (currentPage != null) {
      pdfViewController.setPage(currentPage);
    }
    if (!asyncController.isCompleted) {
      asyncController.complete(pdfViewController);
    }
  }

  void onPdfLinkHandler(String uri) {
    print('goto uri: $uri');
  }

  void onPdfPageChanged(int page, int total) {
    /// Interestingly, iOS calls this method twice on handling internal hyperlinks
    /// Android does not. It only calls this method once
    print('page change: $page/$total');
    currentPage = page;
    update();
  }
}
