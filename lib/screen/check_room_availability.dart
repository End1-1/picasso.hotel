import 'package:cafe5_mworker/bloc/app_bloc.dart';
import 'package:cafe5_mworker/screen/app.dart';
import 'package:cafe5_mworker/screen/rooms.dart';
import 'package:cafe5_mworker/utils/prefs.dart';
import 'package:cafe5_mworker/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

part 'check_room_availability.model.dart';

class WMCheckRoomAvaiability extends WMApp {
  final _model = RoomAvailabilityModel();

  WMCheckRoomAvaiability({super.key, required super.model});

  @override
  Widget body() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Styling.columnSpacingWidget(),
          Row(
            children: [
              Expanded(
                  child: Styling.textFormField(
                      _model.entryDateTextController, model.tr('Entry'), readOnly: true)),
              IconButton(
                  onPressed: editEntryDate, icon: const Icon(Icons.edit)),
              Styling.rowSpacingWidget()
            ],
          ),
          Styling.columnSpacingWidget(),
          Row(
            children: [
              Expanded(
                  child: Styling.textFormField(
                      _model.departureDateTextController,
                      model.tr('Departure'), readOnly: true)),
              IconButton(
                  onPressed: editDepartureDate, icon: const Icon(Icons.edit)),
              Styling.rowSpacingWidget()
            ],
          ),
          Styling.columnSpacingWidget(),
          BlocBuilder<AppBloc, AppState>(builder: (builder, state) {
            if (state is AppStateRoomAvailability) {
              return SingleChildScrollView(scrollDirection: Axis.horizontal, child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(children: [Styling.textWithWidth(model.tr('Category'), 120, fontWeight: FontWeight.bold),
                      Styling.textWithWidth(model.tr('Total'), 100, fontWeight: FontWeight.bold),
                      Styling.textWithWidth(model.tr('Occupied'), 100, fontWeight: FontWeight.bold),
                      Styling.textWithWidth(model.tr('Free'), 100, fontWeight: FontWeight.bold),
                    ]),
                    Styling.columnSpacingWidget(),
                    for (final e in state.data) ...[
                      InkWell(onTap: () { showRoomOfCategory(e[0]);}, child: Row(children: [Styling.textWithWidth(e[0], 120),
                        Styling.textWithWidth(e[2], 100),
                        Styling.textWithWidth(e[4].toString(), 100),
                        Styling.textWithWidth('${(int.tryParse(e[2]) ?? 0) - e[4]}', 100),
                      ])),
                      Styling.columnSpacingWidget()
                    ]
                  ]));
            } else {
              return Container();
            }
          })
        ],
      ),
    );
  }

  @override
  List<Widget> actions() {
    return [
      IconButton(onPressed: search, icon: Icon(Icons.search_outlined)),
    ];
  }
}
