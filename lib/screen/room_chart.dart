import 'package:picassohotel/bloc/app_bloc.dart';
import 'package:picassohotel/bloc/question_bloc.dart';
import 'package:picassohotel/screen/app.dart';
import 'package:picassohotel/utils/calendar.dart';
import 'package:picassohotel/utils/prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

part 'room_chart.model.dart';

class WMRoomChart extends WMApp {
  final _model = RoomChartModel();

  WMRoomChart({super.key, required super.model}) {
    getChart();
  }

  @override
  List<Widget> actions() {
    return [
      IconButton(
          onPressed: setStartDate, icon: Icon(Icons.calendar_month_sharp)),
      IconButton(onPressed: getChart, icon: Icon(Icons.refresh_outlined)),
    ];
  }

  @override
  String titleText() {
    return '';
  }

  @override
  Widget body(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: BlocBuilder<AppBloc, AppState>(
                buildWhen: (p, c) => c is AppStateRoomChart,
                builder: (builder, state) {
                  return chart();
                })),
      ],
    );
  }

  Widget chart() {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 100,
                height: 50,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: Colors.black12,
                    border: Border.fromBorderSide(
                        BorderSide(color: Colors.black12))),
                child: Text(model.tr('Room')),
              ),
              Expanded(
                  child: SingleChildScrollView(
                      controller: _model.roomsVertScrollController,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            for (final r in _model.rooms) ...[
                              InkWell(
                                  onTap: () {
                                    changeRoomState(r);
                                  },
                                  child: Container(
                                      width: 100,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: colorOfRoomState(r['f_state']),
                                          border: Border.fromBorderSide(
                                              BorderSide(
                                                  color: Colors.black12))),
                                      child: Text(r['f_short'])))
                            ]
                          ])))
            ],
          ),
          Expanded(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          for (int i = 0; i < 40; i++) ...[headerDay(i)]
                        ],
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                              controller: _model.chartVertScrollController,
                              child: Stack(children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (int i = 0;
                                        i < _model.rooms.length;
                                        i++) ...[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          for (int j = 0; j < 40; j++)
                                            chartWhite(i, j)
                                        ],
                                      )
                                    ]
                                  ],
                                ),
                                for (final r in filterReservations())
                                  chartReserve(r)
                              ])))
                    ],
                  )))
        ]);
  }

  Widget headerDay(int i) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
          color: Colors.black12,
          border: Border.fromBorderSide(BorderSide(color: Colors.black12))),
      child: Text(
        '${_model.date.add(Duration(days: i)).day}\r\n${DateFormat("MMM").format(_model.date.add(Duration(days: i)))}',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget chartWhite(int i, int j) {
    return InkWell(
        onTap: () {},
        child: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border.fromBorderSide(BorderSide(color: Colors.black12))),
        ));
  }

  Widget chartReserve(dynamic d) {
    return Positioned(
        top: (_model.roomPos[d['f_room']] ?? 0) * RoomChartModel.squareside,
        left: leftOfReserve(d),
        child: InkWell(
          onTap: () {
            model.navigation.openFolio(d).then((value) {
              if (value ?? false) {
                getChart();
              }
            });
          },
          child: Container(
            alignment: Alignment.center,
            height: RoomChartModel.squareside - 4,
            width: lengthOfReserve(d) - 4,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: colorOfReserveState(d['f_state']),
                border:
                    Border.fromBorderSide(BorderSide(color: Colors.black12))),
            child: Text(
              d['f_guest_name'] ?? '',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ));
  }
}
