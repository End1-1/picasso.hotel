part of 'check_store_input.dart';

class CheckStoreInputModel {
  final scancodeTextController = TextEditingController();
  final scancodeFocus = FocusNode();
}

class AppStateCheckStoreInput extends AppStateFinished{
  AppStateCheckStoreInput({required super.data});
}

extension WMECheckStoreInput on WMCheckStoreInput {
  void searchBarcodeStoreInput(String b) {
    if (b.isEmpty) {
      return;
    }
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading('Querying', 'engine/worker/store-input-check-barcode.php', {
      'barcode':b,
      'store': Prefs.config['store'] ?? 0,
      'mode': 1
    }, (e, d) {

    }, AppStateCheckStoreInput(data:null)));
  }

  void checkBarcodeStoreInput() {
    model.navigation.readBarcode().then((value) {
      if (value != null) {
        _model.scancodeTextController.text = value;
        searchBarcodeStoreInput(_model.scancodeTextController.text);
      }
    });
  }

  void showAllCheckStoreInput() {
    model.navigation.hideMenu();
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(
        'Querying',
        'engine/worker/store-input-check-barcode.php',
        {'store': Prefs.config['store'] ?? 0, 'mode': 2},
            (e, d) => null, AppStateCheckStoreInput(data:null) ));
  }

  void checkedStoreInput(String s, dynamic d) {
    final a = <String, dynamic>{};
    a.addAll(d);
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(
        'Querying',
        'engine/worker/store-input-check-barcode.php',
        {'store': Prefs.config['store'] ?? 0, 'id': s, 'mode': 3},
            (e, d) {
          if (!e) {
            for (int i = 0;i < a['result'].length; i++) {
              final e = a['result'][i];
              if (e['f_id'] == s){
                e['f_acc'] = d['acc'];
                a['result'][i] = e;
                BlocProvider.of<AppBloc>(prefs.context()).emit(AppStateCheckStoreInput(data: a));
                return;
              }
            }
          }
        }, null));
  }
}