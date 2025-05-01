import 'package:cafe5_mworker/bloc/app_bloc.dart';
import 'package:cafe5_mworker/bloc/date_bloc.dart';
import 'package:cafe5_mworker/screen/app.dart';
import 'package:cafe5_mworker/utils/prefs.dart';
import 'package:cafe5_mworker/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'goods_reserve.model.dart';

class WMGoodsReserve extends WMApp {
  final Map<String, dynamic> info;
  final Map<String, dynamic> store;
  final _model = GoodsReserveModel();

  WMGoodsReserve(this.info, this.store, {super.key, required super.model}) {
    _model.reservationStore = store['f_store'];
    _model.reservationGoods = info['goods']['f_id'];
    _model.reservationBarcode = info['goods']['f_scancode'];
    _model.reservationGoodsName = info['goods']['f_goodsname'];
    _model.maxReserveQty = (double.tryParse(store['f_qty'].toString()) ?? 0) -
        (double.tryParse(store['f_reserve'].toString()) ?? 0) ;
  }

  @override
  String titleText() {
    return model.tr('Reservation');
  }

  @override
  List<Widget> actions() {
    return [
      IconButton(
          onPressed: createReservation, icon: const Icon(Icons.save_outlined))
    ];
  }

  @override
  Widget body() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Styling.text(info['goods']['f_groupname']),
              Styling.rowSpacingWidget(),
              Styling.text(info['goods']['f_goodsname'])
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Styling.text(info['goods']['f_scancode']),
            ],
          ),
          Styling.columnSpacingWidget(),
          Row(
            children: [
              Styling.text(model.tr('Reservation data')),
              Expanded(child: Container()),
              Styling.text(prefs.currentDateText())
            ],
          ),
          Styling.columnSpacingWidget(),
          Row(
            children: [
              Styling.text(model.tr('Reservation expiration')),
              Expanded(child: Container()),
              BlocBuilder<DateBloc, DateState>(builder: (builder, state) {
                return InkWell(
                    onTap: setReservationExpiration,
                    child: Styling.text(
                        prefs.dateText(_model.reservationExpiration)));
              })
            ],
          ),
          Styling.columnSpacingWidget(),
          Row(
            children: [
              Styling.text(model.tr('Store')),
              Expanded(child: Container()),
              Styling.text(store['f_storename'])
            ],
          ),
          Styling.columnSpacingWidget(),
          Row(
            children: [
              Styling.text(model.tr('Available quantity')),
              Expanded(child: Container()),
              Styling.text(prefs.df('${_model.maxReserveQty}'))
            ],
          ),
          Styling.columnSpacingWidget(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Styling.text(model.tr('Quantity')),
              Expanded(child: Container()),
              SizedBox(
                  width: 50,
                  child: TextFormField(
                    onChanged: reserveQtyChanged,
                    textAlign: TextAlign.right,
                    controller: _model.reserveQtyTextController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  ))
            ],
          ),
          Styling.columnSpacingWidget(),
          Styling.textFormField(
              _model.reserveCommentTextController, model.tr('Comment'),
              maxLines: 5)
        ],
      ),
    );
  }
}
