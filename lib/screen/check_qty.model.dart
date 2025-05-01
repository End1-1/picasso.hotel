part of 'check_qty.dart';

class CheckQtyModel {
  final scancodeTextController = TextEditingController();
  final scancodeFocus = FocusNode();
}

class AppStateCheckQty extends AppStateFinished{
  AppStateCheckQty({required super.data});
}

extension WMECheckQty on WMCheckQty {
  void searchBarcode(String b) {
    if (b.isEmpty) {
      return;
    }
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(
        model.tr('Checking availability'),
        'engine/reports/availability.php',
        {'barcode': b},
            (e, d) {}, AppStateCheckQty(data:null)));
  }

  void replaceBarcodeSize(String ss) {
    String s = _model.scancodeTextController.text;
    if (s.length < 2) {
      return;
    }
    s = s.replaceRange(0, 2, ss);
    _model.scancodeTextController.text = s;
    searchBarcode(s);
  }

  void readBarcode() {
    model.navigation.readBarcode().then((value) {
      if (value != null) {
        _model.scancodeTextController.text = value;
        searchBarcode(_model.scancodeTextController.text);
      }
    });
  }


}