import 'package:cafe5_mworker/bloc/app_bloc.dart';
import 'package:cafe5_mworker/screen/app.dart';
import 'package:cafe5_mworker/utils/calendar.dart';
import 'package:cafe5_mworker/utils/prefs.dart';
import 'package:cafe5_mworker/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WMDayEnd extends WMApp {
  final _dateController = TextEditingController();
  var _date = DateTime.now();

  WMDayEnd({super.key, required super.model}) {
    _dateController.text = prefs.dateMySqlText(_date);
    _refresh();
  }

  @override
  Widget body() {
    return Column(children: [
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(locale().dayEnd)]),
      Styling.rowSpacingWidget(),
      Row(children: [
        Expanded(
            child: Styling.textFormField(_dateController, locale().date,
                readOnly: true, onTap: _changeDate)),
      ]),
      Expanded(child: SingleChildScrollView(
          child: BlocBuilder<AppBloc, AppState>(builder: (builder, state) {
        if (state is AppStateDayEnd) {
          return Column(children: [
            for (final e in state.data['report'] ?? []) ...[
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(e['f_name'], style: const TextStyle(fontSize: 30))
              ])
            ]
          ]);
        }
        return Container();
      })))
    ]);
  }

  @override
  List<Widget> actions() {
    return [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))];
  }

  void _changeDate() {
    Calendar.show(
            firstDate: _date.add(const Duration(days: -365)),
            currentDate: _date)
        .then((value) {
      if (value != null) {
        _date = value;
        _dateController.text = prefs.dateMySqlText(_date);
        _refresh();
      }
    });
  }

  void _refresh() {
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading2(
        '/engine/shop/reports/day-end.php',
        {'date': prefs.dateMySqlText(_date), 'action': 'get'},
        AppStateDayEnd(data: null)));
  }
}
