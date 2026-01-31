import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:picassohotel/bloc/app_bloc.dart';
import 'package:picassohotel/bloc/question_bloc.dart';
import 'package:picassohotel/screen/app.dart';
import 'package:picassohotel/utils/prefs.dart';
import 'package:picassohotel/utils/res.dart';
import 'package:picassohotel/utils/styles.dart';

part 'room_reserve.model.dart';

class WMRoomReserve extends WMApp {
  final _model = RoomReserveModel();

  WMRoomReserve({super.key, required super.model, dynamic room, dynamic folio}) {
    _model.room.addAll(room);
    _model.reservation.addAll(folio);
    if (folio.isEmpty && _model.room.isNotEmpty) {
      openRoom();
    } else {
      openFolio();
    }
  }

  @override
  String titleText() {
    return _model.room.isEmpty ? '' :_model.room['f_short'];
  }

  @override
  List<Widget> actions() {
    return [
      if (canCancel())
        IconButton(onPressed: cancel, icon: const Icon(Icons.cancel_outlined)),
      if (canCheckin())
        IconButton(onPressed: checkin, icon: SvgPicture.memory(Res.images['checkin']!, color: Colors.black, height: 24, width: 24,)),
      if (state() == 1)
        IconButton(onPressed: checkOut, icon: const Icon(Icons.departure_board_sharp)),
      IconButton(onPressed: save, icon: const Icon(Icons.save_outlined))
    ];
  }

  @override
  Widget body(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(builder: (builder, state) {
      return SingleChildScrollView(child: reserve());
    });
  }

  Widget reserve() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Row(children: [
        Expanded(
            child: Styling.textCenter(model.tr('Reservation').toUpperCase()))
      ]),
      Row(children: [
        Styling.rowSpacingWidget(),
        Styling.text(model.tr('Created')),
        Expanded(child: Container()),
        Styling.rowSpacingWidget(),
        Styling.text(prefs.dateText(_model.createdDate)),
        Styling.rowSpacingWidget(),
        IconButton(onPressed: () {}, icon: const Icon(Icons.info_outline)),
        Styling.rowSpacingWidget(),
      ]),
      Row(children: [
        Styling.rowSpacingWidget(),
        Styling.text(model.tr('Entry')),
        Expanded(child: Container()),
        Styling.rowSpacingWidget(),
        Styling.text(prefs.dateText(_model.entryDate)),
        IconButton(onPressed: editEntry, icon: const Icon(Icons.edit)),
        Styling.rowSpacingWidget(),
      ]),
      Row(children: [
        Styling.rowSpacingWidget(),
        Styling.text(model.tr('Departure')),
        Expanded(child: Container()),
        Styling.rowSpacingWidget(),
        Styling.text(prefs.dateText(_model.departureDate)),
        IconButton(onPressed: editDeparture, icon: const Icon(Icons.edit)),
        Styling.rowSpacingWidget(),
      ]),
      Row(children: [
        Styling.rowSpacingWidget(),
        Styling.text(model.tr('Price')),
        Expanded(child: Container()),
        SizedBox(
            width: 150,
            child: Styling.textFormFieldNumbers(_model.priceTextController, '',
                onChange: priceChanged))
      ]),
      Styling.columnSpacingWidget(),
      Row(children: [
        Styling.rowSpacingWidget(),
        Styling.text(model.tr('Total')),
        Expanded(child: Container()),
        SizedBox(
            width: 150,
            child: Styling.textFormFieldNumbers(_model.totalTextController, '',
                readOnly: true))
      ]),
      Styling.columnSpacingWidget(),
      Row(children: [
        Expanded(
            child: Styling.textFormField(
                _model.remarksTextController, model.tr('Remarks'),
                maxLines: 4)),
      ]),
      Divider(),
      Row(children: [
        Expanded(child: Styling.textCenter(model.tr('Guests').toUpperCase()))
      ]),
      for (int i = 0; i < _model.guests.length; i++) ...[
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: InkWell(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 20, child: Styling.text('${i + 1}')),
                SizedBox(
                    width: 150,
                    child: Styling.text(_model.guests[i]['f_lastname'])),
                SizedBox(
                    width: 150,
                    child: Styling.text(_model.guests[i]['f_firstname'])),
                SizedBox(
                    width: 150,
                    child: Styling.text(_model.guests[i]['f_tel1'] ?? '')),
              ],
            )))
      ],
      Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: addGuest, icon: Icon(Icons.add_box_outlined))
          ]),
      Divider(),
      Row(children: [
        Expanded(child: Styling.textCenter(model.tr('Folio').toUpperCase()))
      ]),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: addVoucher, icon: Icon(Icons.add_box_outlined))
              ]),
      for (int i = 0; i < _model.folio.length; i++) ...[
        folioRow(i, _model.folio[i]),
        Divider(),
      ],
          Divider(),
          Row(children: [
            SizedBox(width: 270, child: Styling.textBold(model.tr('Balance'))),
            Styling.textBold('${folioBalance()}')
          ],)
    ]);
  }

  Widget folioRow(int i, dynamic f) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: 20, child: Styling.text('${i+1}.')),
            SizedBox(width: 90, child: Styling.text(f['f_wdate'])),
            SizedBox(width: 160, child: Styling.text(f['f_finalname'])),
            SizedBox(width: 80, child: Styling.text('${(double.tryParse(f['f_amountamd'])??0) * f['f_sign']}')),
          ],
        ));
  }
}
