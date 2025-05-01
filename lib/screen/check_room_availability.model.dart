part of 'check_room_availability.dart';

class RoomAvailabilityModel {
  final entryDateTextController = TextEditingController();
  final departureDateTextController = TextEditingController();

  var entryDate = DateTime.now();
  var departureDate = DateTime.now();

  RoomAvailabilityModel() {
    entryDateTextController.text =
        DateFormat('dd/MM/yyyy').format(DateTime.now());
    departureDateTextController.text =
        DateFormat('dd/MM/yyyy').format(DateTime.now());
  }
}

class AppStateRoomAvailability extends AppStateFinished {
  AppStateRoomAvailability({required super.data});
}

extension RoomAvailability on WMCheckRoomAvaiability {
  void editEntryDate() {
    showDatePicker(
            context: prefs.context(),
            initialEntryMode: DatePickerEntryMode.calendarOnly,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)))
        .then((value) {
      if (value != null) {
        _model.entryDate = value;
        _model.entryDateTextController.text =
            DateFormat('dd/MM/yyyy').format(value);
      }
    });
  }

  void editDepartureDate() {
    showDatePicker(
            context: prefs.context(),
            initialEntryMode: DatePickerEntryMode.calendarOnly,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)))
        .then((value) {
      if (value != null) {
        _model.departureDate = value;
        _model.departureDateTextController.text =
            DateFormat('dd/MM/yyyy').format(value);
      }
    });
  }

  void search() {
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(
        model.tr('Querying'),
        '/engine/hotel/room-availability.php',
        {
          'entry': DateFormat('yyyy-MM-dd').format(_model.entryDate),
          'departure': DateFormat('yyyy-MM-dd').format(_model.departureDate)
        },
        (e, d) {},
        AppStateRoomAvailability(data:null)));
  }

  void showRoomOfCategory(String cat) {
    Navigator.push(
        prefs.context(),
        MaterialPageRoute(
            builder: (builder) => WMRoomsScreen(
                model: model,
                categoryFilter: cat,
                entry: _model.entryDate,
                departure: _model.departureDate)));
  }
}
