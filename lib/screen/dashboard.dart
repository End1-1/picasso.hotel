import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:picassohotel/bloc/app_bloc.dart';
import 'package:picassohotel/bloc/question_bloc.dart';
import 'package:picassohotel/utils/calendar.dart';
import 'package:picassohotel/utils/prefs.dart';
import 'package:picassohotel/utils/styles.dart';

import 'app.dart';

part 'dashboard.model.dart';
part 'dashboard.reports.dart';
part 'hotel/dashboard.hotel.dart';
part 'reports/elina/dashboard.elinarep.dart';

class WMDashboard extends WMApp {
  final _model = DashboardModel();

  WMDashboard({super.key, required super.model}) {
    getDashboard();
  }

  @override
  Widget? leadingButton(BuildContext context) {
    return null;
  }

  @override
  String titleText() {
    return Prefs.config['first_page_title'] ?? 'Picasso';
  }

  @override
  List<Widget> actions() {
    return [
      IconButton(onPressed: getDashboard, icon: const Icon(Icons.refresh)),
      IconButton(
          onPressed: model.navigation.openRoomChart,
          icon: const Icon(Icons.table_chart_outlined)),
      IconButton(onPressed: model.menuRaise, icon: const Icon(Icons.menu))
    ];
  }

  @override
  List<Widget> menuWidgets() {
   return [
      Styling.menuButton(
          model.navigation.settings, 'config', model.tr('Configuration')),
      Styling.menuButton(model.navigation.logout, 'logout', model.tr('Logout')),
    ];
  }

  @override
  Widget body(BuildContext context) {
    return bodyHotel();
  }
}
