part of 'room_reserve.dart';

class RoomReserveModel {
  final priceTextController = TextEditingController();
  final totalTextController = TextEditingController();
  final remarksTextController = TextEditingController();
  final guestFirstNameTextController = TextEditingController();
  final guestLastNameTextController = TextEditingController();
  final guestPhoneTextController = TextEditingController();
  final guests = <dynamic>[];
  var reservation = <String, dynamic>{};
  final folio = <dynamic>[];
  var room = {};
  var createdDate = DateUtils.dateOnly(DateTime.now());
  var entryDate = DateUtils.dateOnly(DateTime.now());
  var departureDate = DateUtils.dateOnly(DateTime.now());
}

class AppStateRoomReserve extends AppStateFinished {
  AppStateRoomReserve({required super.data});
}

class AppStateRoomReserveGuest extends AppStateFinished {
  AppStateRoomReserveGuest({required super.data});
}

extension WMERoomReserve on WMRoomReserve {
  void openRoom() {
    if (_model.reservation.isNotEmpty) {
      openFolio();
      return;
    }
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(
        model.tr('Open room'),
        '/engine/hotel/open-room.php',
        {'room': _model.room['f_id'], 'state': _model.room['f_state']}, (e, d) {
      if (e) {
        return;
      }
      if (d['reservation'].isNotEmpty) {
        final r = d['reservation'];
        _model.reservation.clear();
        _model.reservation.addAll(r);
        _model.createdDate = prefs.strDate(r['f_created']);
        _model.entryDate = prefs.strDate(r['f_startDate']);
        _model.departureDate = prefs.strDate(r['f_endDate']);
        _model.priceTextController.text = r['f_roomFee'];
        _model.totalTextController.text = r['f_grandTotal'];
        _model.guests.clear();
        for (final e in d['guests']) {
          _model.guests.add(e);
        }
        _model.folio.clear();
        _model.folio.addAll(d['folio']);
        _model.room.clear();
        _model.room.addAll(d['room']);
      }
    }, AppStateRoomReserve(data: null)));
  }

  void openFolio() {
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(
        model.tr('Open folio'),
        '/engine/hotel/open-folio.php',
        {'f_id': _model.reservation['f_id']}, (e, d) {
      if (e) {
        return;
      }
      if (d['reservation'].isNotEmpty) {
        final r = d['reservation'];
        _model.reservation.clear();
        _model.reservation = r;
        _model.createdDate = prefs.strDate(r['f_created']);
        _model.entryDate = prefs.strDate(r['f_startDate']);
        _model.departureDate = prefs.strDate(r['f_endDate']);
        _model.priceTextController.text = r['f_roomFee'];
        _model.totalTextController.text = r['f_grandTotal'];
        _model.remarksTextController.text = r['f_remarks'];
        _model.guests.clear();
        for (final e in d['guests']) {
          _model.guests.add(e);
        }
        _model.folio.clear();
        _model.folio.addAll(d['folio']);
        _model.room = d['room'];
      }
    }, AppStateRoomReserve(data: null)));
  }

  void editEntry() {
    showDatePicker(
            context: prefs.context(),
            initialEntryMode: DatePickerEntryMode.calendarOnly,
            currentDate: _model.entryDate,
            firstDate: prefs.workingDay(),
            lastDate: DateTime.now().add(const Duration(days: 30 * 120)))
        .then((value) {
      if (value != null) {
        _model.entryDate = value;
        priceChanged('');
        BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(
            '', '', {}, (p0, p1) => null, AppStateRoomReserve(data: null)));
      }
    });
  }

  void editDeparture() {
    showDatePicker(
            context: prefs.context(),
            initialEntryMode: DatePickerEntryMode.calendarOnly,
            currentDate: _model.departureDate,
            firstDate: prefs.workingDay(),
            lastDate: DateTime.now().add(const Duration(days: 30 * 120)))
        .then((value) {
      if (value != null) {
        _model.departureDate = value;
        priceChanged('');
        BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(
            '', '', {}, (p0, p1) => null, AppStateRoomReserve(data: null)));
      }
    });
  }

  void addGuest() {
    _model.guestLastNameTextController.clear();
    _model.guestFirstNameTextController.clear();
    _model.guestPhoneTextController.clear();
    showDialog(
        context: prefs.context(),
        builder: (builder) {
          return SimpleDialog(
              shape: Border.all(color: Colors.transparent),
              contentPadding: const EdgeInsets.all(10),
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Styling.textFormField(
                                _model.guestLastNameTextController,
                                model.tr('First name')))
                      ],
                    ),
                    Styling.columnSpacingWidget(),
                    Row(
                      children: [
                        Expanded(
                            child: Styling.textFormField(
                                _model.guestFirstNameTextController,
                                model.tr('Last name')))
                      ],
                    ),
                    Styling.columnSpacingWidget(),
                    Row(
                      children: [
                        Expanded(
                            child: Styling.textFormField(
                                _model.guestPhoneTextController,
                                model.tr('Phone number')))
                      ],
                    ),
                    Row(
                      children: [
                        Styling.textButton(() {
                          Navigator.pop(prefs.context(), true);
                        }, model.tr('Ok'))
                      ],
                    )
                  ],
                )
              ]);
        }).then((value) {
      if (value ?? false) {
        _model.guests.add({
          'f_id': 0,
          'f_firstname': _model.guestFirstNameTextController.text,
          'f_lastname': _model.guestLastNameTextController.text,
          'f_tel1': _model.guestPhoneTextController.text
        });
        BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading('', '',
            {}, (p0, p1) => null, AppStateRoomReserveGuest(data: null)));
      }
    });
  }

  void priceChanged(String s) {
    int d = _model.departureDate.difference(_model.entryDate).inDays;
    _model.totalTextController.text =
        '${d * (double.tryParse(_model.priceTextController.text) ?? 0)}';
  }

  void checkin() {
    BlocProvider.of<QuestionBloc>(prefs.context())
        .add(QuestionEventRaise(model.tr('Confirm to checkin'), () {
      BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(
          model.tr('Checkout'),
          '/engine/hotel/checkin.php',
          {'reservation': _model.reservation}, (e, d) {
        if (e) {
          return;
        }
        Navigator.pop(prefs.context(), true);
      }, AppStateFinished(data: null)));
    }, null));
  }

  void checkOut() {
    if (folioBalance() != 0) {
      BlocProvider.of<QuestionBloc>(prefs.context())
          .add(QuestionEventRaise(model.tr('Balance not zero'), () {}, null));
      return;
    }
    BlocProvider.of<QuestionBloc>(prefs.context())
        .add(QuestionEventRaise(model.tr('Confirm to checkout'), () {
      BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(
          model.tr('Checkout'),
          '/engine/hotel/checkout.php',
          {'reservation': _model.reservation}, (e, d) {
        if (e) {
          return;
        }
        Navigator.pop(prefs.context(), true);
      }, AppStateFinished(data: null)));
    }, null));
  }

  void cancel() {
    BlocProvider.of<QuestionBloc>(prefs.context())
        .add(QuestionEventRaise(model.tr('Confirm to cancel reservation'), () {
      BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(
          model.tr('Checkout'),
          '/engine/hotel/cancel-reservation.php',
          {'reservation': _model.reservation}, (e, d) {
        if (e) {
          return;
        }
        Navigator.pop(prefs.context(), true);
      }, AppStateFinished(data: null)));
    }, null));
  }

  void save() {
    BlocProvider.of<AppBloc>(prefs.context()).add(AppEventLoading(
        model.tr('Saving'), '/engine/hotel/save-reservation.php', {
      'reservation': _model.reservation,
      'room': _model.room['f_id'],
      'guests': _model.guests,
      'guestid': _model.guests.isEmpty ? 0 : _model.guests[0]['f_id'],
      'entry': prefs.dateMySqlText(_model.entryDate),
      'departure': prefs.dateMySqlText(_model.departureDate),
      'price': double.tryParse(_model.priceTextController.text) ?? 0,
      'total': double.tryParse(_model.totalTextController.text) ?? 0,
      'remarks': _model.remarksTextController.text
    }, (e, d) {
      if (e) {
        return;
      }
      print(d);
      _model.reservation = d["reservation"];
      openFolio();
    }, AppStateFinished(data: null)));
  }

  double folioBalance() {
    double b = 0;
    for (final e in _model.folio) {
      b += (double.tryParse(e['f_amountamd']) ?? 0) * e['f_sign'];
    }
    return b;
  }

  void addVoucher() {
    if (_model.reservation.isEmpty) {
      BlocProvider.of<AppBloc>(prefs.context())
          .add(AppEventError(model.tr('Save first')));
      return;
    }
    model.navigation.openVoucher('', _model.reservation).then((value) {
      if (value ?? false) {
        openRoom();
      }
    });
  }

  bool canCheckin() {
    if (_model.reservation == null) {
      return false;
    }
    if (_model.reservation.isEmpty) {
      return false;
    }
    if (_model.reservation['f_state'] == 2 &&
        _model.entryDate == prefs.strDate(prefs.string('workingday'))) {
      return true;
    }
    return false;
  }

  int state() {
    if (_model.reservation == null) {
      return 0;
    }
    if (_model.reservation.isEmpty) {
      return 0;
    }
    if (_model.reservation['f_state'] is String) {
      return int.tryParse(_model.reservation['f_state']) ?? 0;
    }
    return _model.reservation['f_state'];
  }

  bool canCancel() {
    if (_model.reservation == null) {
      return false;
    }
    if (_model.reservation.isEmpty) {
      return false;
    }
    if (_model.reservation['f_state'] == 2) {
      return true;
    }
    return false;
  }
}
