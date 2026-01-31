import 'package:picassohotel/bloc/app_bloc.dart';
import 'package:picassohotel/screen/app.dart';
import 'package:picassohotel/utils/prefs.dart';
import 'package:picassohotel/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'voucher.model.dart';

class WMVoucher extends WMApp {
  final _model = VoucherModel();

  WMVoucher(
      {required super.model, required String id, required dynamic reservation}) {
    if (id.isEmpty) {
      _model.reservation = {};
      _model.reservation.addAll(reservation);
      getItems();
    } else {
      _model.voucherId = id;
      openVoucher();
    }
  }

  @override
  List<Widget> actions() {
    return [
      if (_model.voucherId.isEmpty)
        IconButton(onPressed: save, icon: Icon(Icons.save_outlined))
    ];
  }

  @override
  Widget body(BuildContext context) {
    return Column(children: [
      Styling.columnSpacingWidget(),
      textFormField(),
      Styling.columnSpacingWidget(),
      suggestWidget(),
      Row(
        children: [
          Expanded(
              child: Styling.textFormFieldNumbers(
                  _model.priceTextController, model.tr('Price')))
        ],
      ),
      Styling.columnSpacingWidget(),
      Row(
        children: [
          Expanded(
              child: Styling.textFormField(
                  _model.commentTextController, model.tr('Comment'),
                  maxLines: 4))
        ],
      )
    ]);
  }

  Widget textFormField() {
    return BlocBuilder<AppBloc, AppState>(
        buildWhen: (p, c) => c is AppStateItemSetItem,
        builder: (builder, state) {
          return Row(children: [
            Expanded(
                child: Styling.textFormField(
                    _model.itemTextController, model.tr('Item'),
                    onChanged: onItemChange, readOnly: _model.item != null)),
            _model.voucherId.isEmpty
                ? IconButton(
                    onPressed: clearItem, icon: Icon(Icons.clear_sharp))
                : Container()
          ]);
        });
  }

  Widget suggestWidget() {
    return BlocBuilder<AppBloc, AppState>(
        buildWhen: (previouse, current) => current is AppStateItemSuggestion,
        builder: (builder, state) {
          if (state is AppStateItemSuggestion) {
            return Container(
                constraints: BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    for (final e in state.data) ...[
                      InkWell(
                          onTap: () {
                            setItem(e);
                          },
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: Row(
                                children: [
                                  Styling.text(e['f_name']),
                                  Styling.columnSpacingWidget()
                                ],
                              )))
                    ]
                  ],
                )));
          }
          return Container();
        });
  }
}
