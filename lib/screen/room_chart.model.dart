part of 'room_chart.dart';

class RoomChartModel {
  final chartVertScrollController = ScrollController();
  final roomsVertScrollController = ScrollController();
  static const double squareside = 50;

  var date = prefs.strDate(prefs.string('workingday'));
  final rooms = [];
  final roomPos = <String, double>{};
  final reservations = [];

  RoomChartModel() {
    chartVertScrollController.addListener(() {
      roomsVertScrollController.animateTo(
          chartVertScrollController.position.pixels,
          duration: Duration(milliseconds: 1),
          curve: Curves.linear);
    });
    roomsVertScrollController.addListener(() {
      chartVertScrollController.animateTo(
          roomsVertScrollController.position.pixels,
          duration: Duration(milliseconds: 1),
          curve: Curves.linear);
    });
  }
}

class AppStateRoomChart extends AppStateFinished {
  AppStateRoomChart({required super.data});
}

class AppEventRoomChart extends AppEventLoading {
  AppEventRoomChart(
      super.text, super.route, super.data, super.callback, super.state);
}

extension WMERoomChart on WMRoomChart {
  void backWeek() {
    _model.date = _model.date.add(Duration(days: -7));
    if (_model.date.isBefore(prefs.workingDay())) {
      _model.date = prefs.workingDay();
    }
    getChart();
  }

  void backMonth() {
    _model.date = _model.date.add(Duration(days: -30));
    if (_model.date.isBefore(prefs.workingDay())) {
      _model.date = prefs.workingDay();
    }
    getChart();
  }

  void forwardWeek() {
    _model.date = _model.date.add(Duration(days: 7));
    getChart();
  }

  void forwardMonth() {
    _model.date = _model.date.add(Duration(days: 30));
    getChart();
  }

  void setStartDate() {
    Calendar.show(currentDate: _model.date).then((value) {
      if (value != null) {
        _model.date = value;
        getChart();
      }
    });
  }

  void getChart() {
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventRoomChart(
        model.tr('Loading chart'),
        '/engine/hotel/room-chart.php',
        {'date': prefs.dateMySqlText(_model.date)}, (e, d) {
      _model.rooms.clear();
      _model.rooms.addAll(d['rooms'] ?? []);
      _model.reservations.clear();
      _model.reservations.addAll(d['reservations'] ?? []);
      _model.roomPos.clear();
      for (int i = 0; i < _model.rooms.length; i++) {
        _model.roomPos[_model.rooms[i]['f_id']] = i * 1.0;
      }
    }, AppStateRoomChart(data:null)));
  }

  Color colorOfReserveState(String state) {
    switch (state) {
      case "1":
        return Color(0xff9cf0ff);
      case "2":
        return Color(0xffff9b9b);
      case "3":
        return Colors.black12;
      default:
        return Colors.indigoAccent;
    }
  }

  Color colorOfRoomState(String state) {
    switch (state) {
      case "1":
        return Color(0xff9cf0ff);
      case "2":
        return Color(0xfffff6ac);
      case "3":
        return Colors.black12;
      default:
        return Colors.white;
    }
  }

  double lengthOfReserve(dynamic d) {
    final l = _model.reservations.firstWhere((element) => element['f_endDate'] == d['f_startDate'] && element['f_room'] == d['f_room'], orElse: ()=>null);
    var loffset = l == null ? RoomChartModel.squareside / 2 : 0;
    DateTime d1 = prefs.strDate(d['f_startDate']);
    DateTime d2 = prefs.strDate(d['f_endDate']);
    var r = d2.difference(d1).inDays * 1.0;
    r = r > 0 ? r : 1;
    r *= RoomChartModel.squareside;
    r += loffset.toInt();
    //print("lenof of ${d['f_id']} ${d['f_startDate']}-${d['f_endDate']} $r");
    return r;
  }

  double leftOfReserve(dynamic d) {
    final l = _model.reservations.firstWhere((element) => element['f_endDate'] == d['f_startDate'] && element['f_room'] == d['f_room'], orElse: ()=>null);
    var loffset = l == null ? RoomChartModel.squareside / -2 : 0;
    DateTime dt = prefs.strDate(d['f_startDate']);
    int diffdays = dt.difference(_model.date).inDays;
    double length = diffdays * RoomChartModel.squareside;
    var left = length + (RoomChartModel.squareside / 2) + loffset;
    //print("Left ${d['f_id']} $left  diffdays $diffdays workingday ${prefs.dateMySqlText(_model.date)}");
    return left;
  }

  List<dynamic> filterReservations() {
    final r = [];
    for (final m in _model.reservations) {
      if (m['f_state'] == "1") {
        r.add(m);
        continue;
      }
      if (prefs.strDate(m['f_startDate']).isAfter(_model.date.add(Duration(days: 41)))) {
        continue;
      }
      r.add(m);
    }
    print("FILTERED ${_model.reservations.length} of ${r.length}");
    return r;
  }

  void changeRoomState(dynamic r) {
    if (r['f_state'] == "2") {
      BlocProvider.of<QuestionBloc>(prefs.context()).add(QuestionEventRaise(model.tr('Change the current state to vacant ready?'), () {
        BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(model.tr('Please, wait...'), '/engine/hotel/change-room-state.php',
            {'newState': 0, 'room': r['f_id']}, (p0, p1) => getChart(), null));
      }, () { }));
    }
  }
}
