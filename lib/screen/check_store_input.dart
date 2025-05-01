import 'package:cafe5_mworker/bloc/app_bloc.dart';
import 'package:cafe5_mworker/model/model.dart';
import 'package:cafe5_mworker/utils/prefs.dart';
import 'package:cafe5_mworker/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';

part 'check_store_input.model.dart';

class WMCheckStoreInput extends WMApp {
  final _model = CheckStoreInputModel();
  WMCheckStoreInput({super.key, required super.model});

  @override
  String titleText() {
    return model.tr('Check store input');
  }

  @override
  List<Widget> menuWidgets() {
    return [
      Styling.menuButton(showAllCheckStoreInput, 'allcheckstoreinput',
          locale().showAll),
    ];
  }

  @override
  Widget body() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: Styling.textFormField(
                    _model.scancodeTextController, model.tr('Barcode'),
                    onSubmit: searchBarcodeStoreInput,
                    autofocus: true,
                    focusNode: _model.scancodeFocus)),
            IconButton(
                onPressed: () {
                  _model.scancodeTextController.clear();
                  _model.scancodeFocus.requestFocus();
                },
                icon: const Icon(Icons.clear_sharp)),
            IconButton(
                onPressed: checkBarcodeStoreInput,
                icon: const Icon(Icons.qr_code))
          ],
        ),
        Row(
          children: [
            WMCheckbox(model.tr('Goods name'), (v) {}, false),
            Expanded(child: Container()),
            Styling.text(model.tr('Qty')),
            Styling.rowSpacingWidget(),
            Container(
                width: 80,
                child: Styling.text(model.tr('Price'), ta: TextAlign.right)),
            Styling.rowSpacingWidget(),
          ],
        ),
        Expanded(
            child: BlocBuilder<AppBloc, AppState>(builder: (builder, state) {
          if (state is AppStateCheckStoreInput) {
            if (state.data.isEmpty) {
              return Container();
            }
            return SingleChildScrollView(
                child: Column(children: [
              for (final e in state.data['result']) ...[
                Row(
                  children: [
                    WMCheckbox(e['f_name'], (p) {
                      checkedStoreInput(e['f_id'], state.data);
                    }, e['f_acc'] != null),
                    Expanded(child: Container()),
                    Styling.text(prefs.df(e['f_qty'].toString())),
                    Styling.rowSpacingWidget(),
                    Container(
                        width: 80,
                        child: Styling.text(prefs.df(e['f_price1'].toString()),
                            ta: TextAlign.right)),
                    Styling.rowSpacingWidget(),
                  ],
                ),
                Styling.columnSpacingWidget(),
              ]
            ]));
          }
          return Container();
        }))
      ],
    );
  }
}
