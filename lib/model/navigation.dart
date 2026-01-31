import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picassohotel/bloc/app_bloc.dart';
import 'package:picassohotel/bloc/question_bloc.dart';
import 'package:picassohotel/main.dart';
import 'package:picassohotel/mobiles_scanner/barcode_reader.dart';
import 'package:picassohotel/model/model.dart';
import 'package:picassohotel/screen/check_room_availability.dart';
import 'package:picassohotel/screen/config.dart';
import 'package:picassohotel/screen/hotel_inventory.dart';
import 'package:picassohotel/screen/reports/elina/day_end.dart';
import 'package:picassohotel/screen/room_chart.dart';
import 'package:picassohotel/screen/room_reserve.dart';
import 'package:picassohotel/screen/rooms.dart';
import 'package:picassohotel/screen/voucher.dart';
import 'package:picassohotel/utils/prefs.dart';

class Navigation {
  final WMModel model;

  Navigation(this.model);

  Future<void> config() {
    return Navigator.push(prefs.context(),
        MaterialPageRoute(builder: (builder) => WMConfig(model: model)));
  }

  Future<void> checkRoomAvailability() {
    hideMenu();
    return Navigator.push(prefs.context(), MaterialPageRoute(builder: (builder) => WMCheckRoomAvaiability(model: model)));
  }

  Future<void> rooms() {
    hideMenu();
    return Navigator.push(prefs.context(), MaterialPageRoute(builder: (builder) => WMRoomsScreen(model: model, entry: DateTime.now(), departure: DateTime.now())));
  }

  Future<void> dayEnd() {
    hideMenu();
    return Navigator.push(prefs.context(), MaterialPageRoute(builder: (builder) => WMDayEnd(model: model)));
  }

  Future<void> settings() {
    hideMenu();
    model.serverTextController.text = prefs.string('serveraddress');
    model.serverUserTextController.clear();
    model.serverPasswordTextController.clear();
    return Navigator.push(prefs.context(), MaterialPageRoute(builder: (builder) => WMConfig(model: model)));
  }

  void logout() {
    hideMenu();
    BlocProvider.of<QuestionBloc>(prefs.context()).add(QuestionEventRaise(model.tr('Logout?'), (){
      BlocProvider.of<QuestionBloc>(Prefs.navigatorKey.currentContext!)
          .add(QuestionEvent());
      BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(model.tr('Logout'), 'engine/logout.php', {}, (e, d) {

          prefs.setBool('stayloggedin', false);
          prefs.setString('sessionkey', '');
          Navigator.pushAndRemoveUntil(prefs.context(), MaterialPageRoute(builder: (builder) =>  App()), (route) => false);

      }, AppStateFinished(data: null)));
    }, null));

  }

  void hideMenu() {
    BlocProvider.of<AppAnimateBloc>(prefs.context()).add(AppAnimateEvent());
  }

  Future<String?> readBarcode() async {
    return Navigator.push(prefs.context(), MaterialPageRoute(builder: (builder) => BarcodeScannerWithOverlay()));
  }



  Future<bool?> openRoom(dynamic r) async {
    return Navigator.push(prefs.context(), MaterialPageRoute(builder: (builder) => WMRoomReserve(model: model, room: r, folio: <String,dynamic>{},)));
  }

  Future<bool?> openVoucher(String id, dynamic reservation) {
    return Navigator.push(prefs.context(), MaterialPageRoute(builder: (builder) => WMVoucher(model: model, id: id,  reservation: reservation,)));
  }

  Future<bool?> openRoomChart() async {
    BlocProvider.of<AppAnimateBloc>(prefs.context()).add(AppAnimateEvent());
    return Navigator.push(prefs.context(), MaterialPageRoute(builder: (builder) => WMRoomChart(model: model)));
  }

  Future<bool?> openFolio(dynamic d) async {
    return Navigator.push(prefs.context(), MaterialPageRoute(builder: (builder) => WMRoomReserve(model: model,room: {}, folio: d)));
  }

  Future<bool?> openRoomInventory(dynamic d) {
    return Navigator.push(prefs.context(), MaterialPageRoute(builder: (builder) => WMHotelInventory(model: model,room: d)));
  }

}
