part of 'voucher.dart';

class VoucherModel {
  final itemTextController = TextEditingController();
  final priceTextController = TextEditingController();
  final commentTextController = TextEditingController();
  dynamic? reservation;
  var voucherId = '';
  final items = [];
  dynamic? item;
}

class AppStateItemSuggestion extends AppStateFinished{
  AppStateItemSuggestion(dynamic data) : super(data: data);
}
class AppStateItemSetItem extends AppStateFinished {
  AppStateItemSetItem({required super.data});

}

extension WMEVoucher on WMVoucher {
  void getItems() {
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(
        model.tr('Loading items'),
        '/engine/hotel/get-invoice-items.php',
        {},
        (e, d) {
          if (e) {
            return;
          }
          _model.items.clear();
          _model.items.addAll(d['items']);
        },
        AppStateFinished(data: null)));
  }

  void openVoucher() {
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(model.tr('Open voucher'), '/engine/hotel/open-voucher.php',
        {'id': _model.voucherId}, (e, d) {
          if (e){
            return;
          }
        }, AppStateFinished(data : null)));
  }

  void setItem(dynamic? item) {
    _model.item = item;
    _model.itemTextController.text = item['f_name'];
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading('', '', {}, null, AppStateItemSetItem(data: null)));
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading('', '', {}, null, AppStateItemSuggestion([])));
  }

  void clearItem() {
    _model.item = null;
    _model.itemTextController.clear();
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading('', '', {}, null, AppStateItemSetItem(data:null)));
  }

  void onItemChange(String s) {
    final items = [];
    if (s.isEmpty) {
      BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading('', '', {}, null, AppStateItemSuggestion(items)));
    }
    for (final e in _model.items) {
      if (e['f_name'].toLowerCase().contains(s.toLowerCase())) {
        items.add(e);
      }
    }
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading('', '', {}, null, AppStateItemSuggestion(items)));
  }

  void save() {
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(model.tr('Saving'), '/engine/hotel/save-voucher.php', {
      'id': _model.voucherId,
      'reservation': _model.reservation,
      'item': _model.item,
      'wdate': prefs.string('workingday'),
      'comment': _model.commentTextController.text,
      'price': double.tryParse(_model.priceTextController.text) ?? 0
    }, (e, p1) {
      if (e) {
        return;
      }
      Navigator.pop(prefs.context(), true);
    }, AppStateFinished(data: null)));
  }
}
