import 'package:cafe5_mworker/screen/app.dart';
import 'package:flutter/material.dart';


part 'hotel_inventory.part.dart';

class WMHotelInventory extends WMApp {
  final _model = HotelInventoryModel();
  WMHotelInventory({super.key, required super.model, required Map<String,dynamic> room}) {
    _model.room = room;
  }

  @override
  String titleText() {
    return _model.room.isEmpty ? '' :_model.room['f_short'];
  }

  @override
  Widget body() {
    return Container();
  }

}