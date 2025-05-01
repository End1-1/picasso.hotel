part of 'dashboard.dart';

extension DashboardStore on WMDashboard {
  List<Widget> menuWidgetsStore() {
    return [
      Styling.menuButton(() {
        model.navigation.createDraftSale().then((value) {
          getDashboard();
        });
      }, 'draftsale', model.tr('Create draft sale')),
      Styling.menuButton(model.navigation.checkQuantity, 'available',
          model.tr('Check availability')),
      Styling.menuButton(model.navigation.checkStoreInput, 'checkstoreinput',
          model.tr('Check store input')),
    ];
  }

  Widget bodyStore() {
    return BlocBuilder<AppBloc, AppState>(
        buildWhen: (p, c) => c is AppStateDashboard,
        builder: (builder, state) {
          if (state is! AppStateDashboard) {
            return Container();
          }
          return _DraftsBoard(_model, model, openDraft, removeDraft);
        });
  }
}

class _DraftsBoard extends StatefulWidget {
  final WMModel _wmModel;
  final DashboardModel _model;
  final Function(String) onTap;
  final Function(String) onRemove;

  const _DraftsBoard(this._model, this._wmModel, this.onTap, this.onRemove);

  @override
  State<StatefulWidget> createState() => __DraftsBoard();
}

class __DraftsBoard extends State<_DraftsBoard>
    with SingleTickerProviderStateMixin {
  late final controller = SlidableController(this);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          for (final e in widget._model.drafts) ...[
            Container(
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black26))),
                height: 80,
                child: Slidable(
                    key: Key(e['f_id']),
                    endActionPane: ActionPane(
                      extentRatio: 0.25,
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          // An action can be bigger than the others.
                          flex: 1,
                          onPressed: (_) { widget.onRemove(e['f_id']);},
                          backgroundColor: const Color(0xFFFF6C6C),
                          foregroundColor: Colors.white,
                          icon: Icons.delete_outline,
                          label: widget._wmModel.tr('Remove'),
                        )
                      ],
                    ),
                    child: InkWell(
                        onTap: () {
                          widget.onTap(e['f_id']);
                        },
                        child: Row(children: [
                          SizedBox(
                              width: 100,
                              child: Styling.text('${e['f_date']}')),
                          SizedBox(
                              width: 150, child: Styling.text(e['f_staff'])),
                          Expanded(child: Container()),
                          Styling.text('${e['f_amount']}'),
                          Styling.rowSpacingWidget()
                        ])))),
          ]
        ]));
  }
}
