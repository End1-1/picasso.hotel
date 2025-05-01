import 'package:cafe5_mworker/bloc/app_bloc.dart';
import 'package:cafe5_mworker/bloc/question_bloc.dart';
import 'package:cafe5_mworker/screen/app.dart';
import 'package:cafe5_mworker/utils/prefs.dart';
import 'package:cafe5_mworker/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

part 'rooms.model.dart';

class WMRoomsScreen extends WMApp {
  final _model = RoomsModel();

  WMRoomsScreen(
      {required super.model,
      String categoryFilter = '',
      required DateTime entry,
      required DateTime departure}) {
    _model.entryDate = entry;
    _model.departureDate = departure;
    _model.categoryFilter = categoryFilter;
    getRooms();
  }

  @override
  String titleText() {
    return model.tr('Rooms list');
  }

  @override
  List<Widget> actions() {
    return [
      IconButton(onPressed: getRooms, icon: const Icon(Icons.refresh)),
      TextButton(
          onPressed: filterCategories,
          child: Text(
              _model.categoryFilter.isEmpty ? '[-]' : _model.categoryFilter)),
    ];
  }

  @override
  List<Widget> menuWidgets() {
    return _model.menuWidgets;
  }

  @override
  Widget body() {
    return Column(children: [
      BlocBuilder<AppBloc, AppState>(
        buildWhen: (previouse, current) => current is AppStateRoomsFilter,
          builder: (builder, state) {

          return Row(children: [
            Styling.rowSpacingWidget(),
            Styling.text(prefs.dateText(_model.entryDate)),
            IconButton(onPressed: editEntry, icon: const Icon(Icons.edit)),
            Styling.rowSpacingWidget(),
            Styling.text('-'),
            Styling.rowSpacingWidget(),
            Styling.text(prefs.dateText(_model.departureDate)),
            IconButton(onPressed: editDeparture, icon: const Icon(Icons.edit)),
            Styling.rowSpacingWidget(),
          ]);

      }),
      Expanded(child: BlocBuilder<AppBloc, AppState>(
        buildWhen: (previouse, current) => current is AppStateRooms,
          builder: (builder, state) {
        if (state is AppStateRooms) {
          return SingleChildScrollView(
              child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                for (final e in state.data['rooms']) ...[roomWidget(e)]
              ]));
        }
        return Container();
      }))
    ]);
  }

  Widget roomWidget(dynamic e) {
    final freeColor = const Color(0xffffffff);
    final occupiedColor = const Color(0xffaedcae);
    final dirtyColor = const Color(0xffffeca1);
    final invenColor = const Color(0xffbdbdbd);
    var bgColor = freeColor;
    switch (e['f_state']) {
      case "0":
        bgColor = freeColor;
        break;
      case "1":
        bgColor = occupiedColor;
        break;
      case "2":
        bgColor = dirtyColor;
        break;
      case "3":
        bgColor = invenColor;
        break;
      default:
        bgColor = Colors.indigo;
        break;
    }
    return InkWell(onTap:(){openRoom(e);}, child: Container(
        margin: const EdgeInsets.fromLTRB(3, 3, 3, 3),
        decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: Colors.black38),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        alignment: Alignment.center,
        width: MediaQuery.sizeOf(prefs.context()).width * .46,
        child: Text(e['f_short'])));
  }
}
