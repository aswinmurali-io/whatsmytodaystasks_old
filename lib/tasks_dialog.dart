import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';

import 'custom_dialog.dart';
import 'database.dart';
import 'globals.dart';

/*
  Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    pageBuilder: (BuildContext context, _, __) =>
        TaskDialog()));
 */

class TaskDialog extends StatefulWidget {
  final setState2;

  final bool modifyWhat, done;
  final int importance;
  final String title, description, week2, oldTitle;
  final dynamic endtime, selectedTime;

  TaskDialog(this.setState2, this.modifyWhat, this.done, this.importance, this.title, this.description, this.week2,
      this.oldTitle, this.endtime, this.selectedTime);

  @override
  createState() => _TaskDialogState(
      setState2, modifyWhat, done, importance, title, description, week2, oldTitle, endtime, selectedTime);
}

class _TaskDialogState extends State<TaskDialog> {
  int _importance;
  TextEditingController _textFieldTaskController;
  TextEditingController _textFieldDescriptionController;

  final setState2;

  final bool modifyWhat, done;
  int importance;
  String title, description, week2, oldTitle;
  dynamic endtime, selectedTime;

  _TaskDialogState(this.setState2, this.modifyWhat, this.done, this.importance, this.title, this.description,
      this.week2, this.oldTitle, this.endtime, this.selectedTime);

  @override
  void initState() {
    super.initState();
    _textFieldTaskController = TextEditingController(text: title);
    _textFieldDescriptionController = TextEditingController(text: description);
    _importance = importance ?? 0;
  }

  @override
  void dispose() {
    _textFieldTaskController.dispose();
    _textFieldDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String _currentWeek, dropdown, week;
    _currentWeek = dropdown = week = Jiffy(DateTime.now()).EEEE;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black54.withOpacity(0.55),
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light),
      child: CustomGradientDialogForm(
        title: Text((modifyWhat) ? "Edit Task" : "New Task", style: TextStyle(color: Colors.white, fontSize: 25)),
        content: Column(
          children: [
            const Text("What's the task ?"),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
              child: TextField(
                  controller: _textFieldTaskController,
                  autocorrect: true,
                  cursorColor: Colors.red,
                  maxLines: 1,
                  enableSuggestions: true,
                  maxLength: 40,
                  onChanged: (value) => title = value),
            ),
            const Text("Something else to remember with it?"),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
              child: TextField(
                  controller: _textFieldDescriptionController,
                  autocorrect: true,
                  cursorColor: Colors.red,
                  maxLines: 1,
                  autofocus: true,
                  enableSuggestions: true,
                  maxLength: 30,
                  onChanged: (value) => description = value),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Pick a day"),
                DropdownButton(
                    value: dropdown,
                    items: (weeks + ["Tomorrow"])
                            .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                            .toList() +
                        [],
                    onChanged: (value) {
                      week = value;
                      setState(() => dropdown = value);
                    }),
              ],
            ),
            Row(
              children: [
                const Text("Is this task very important ? "),
                Checkbox(
                    value: (_importance == 0) ? false : true,
                    onChanged: (bool value) => setState(() => _importance = (value) ? 1 : 0))
              ],
            ),
            ExpansionTile(
              title: Text("Time"),
              children: [
                SingleChildScrollView(
                  child: Wrap(children: [
                    const Text(
                        "if you already set the time and want to remove it. Open the time selector and just press cancel"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Set the start time"),
                        GradientButton(
                            shadowColor: Colors.black26,
                            elevation: (kIsWeb) ? 0.0 : 6.0,
                            shapeRadius: BorderRadius.circular(10),
                            gradient: Gradients.blush,
                            increaseWidthBy: 40,
                            child: Text("Choose Start Time"),
                            callback: () =>
                                selectedTime = showTimePicker(context: context, initialTime: TimeOfDay.now())),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Set the end time"),
                        GradientButton(
                            shadowColor: Colors.black26,
                            elevation: (kIsWeb) ? 0.0 : 6.0,
                            shapeRadius: BorderRadius.circular(10),
                            gradient: Gradients.blush,
                            increaseWidthBy: 40,
                            child: Text("Choose End Time"),
                            callback: () => endtime = showTimePicker(context: context, initialTime: TimeOfDay.now())),
                      ],
                    ),
                  ]),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GradientButton(
                      shadowColor: Colors.black26,
                      elevation: (kIsWeb) ? 0.0 : 6.0,
                      shapeRadius: BorderRadius.circular(10),
                      gradient: Gradients.coldLinear,
                      increaseWidthBy: 20,
                      child: const Text("Save", style: TextStyle(color: Colors.white)),
                      callback: () async {
                        if (week != null && _textFieldTaskController.text.replaceAll(RegExp(r'\s'), '').length != 0) {
                          TimeOfDay _awaitedTime, _awaitedTime2;
                          if (selectedTime is String && selectedTime != "Any Time") {
                            DateTime dateTimeFromString = DateFormat.jm().parse(selectedTime);
                            selectedTime = TimeOfDay(hour: dateTimeFromString.hour, minute: dateTimeFromString.minute);
                            _awaitedTime = selectedTime;
                          } else if (selectedTime is Future<TimeOfDay>) {
                            _awaitedTime = (await selectedTime);
                          }

                          if (endtime is String && endtime != "Any Time") {
                            DateTime dateTimeFromString = DateFormat.jm().parse(endtime);
                            endtime = TimeOfDay(hour: dateTimeFromString.hour, minute: dateTimeFromString.minute);
                            _awaitedTime2 = endtime;
                          } else if (endtime is Future<TimeOfDay>) {
                            _awaitedTime2 = (await endtime);
                          }
                          // if modifiying then first check if key present else make one
                          setState(() {
                            if (modifyWhat && userTasks.containsKey(oldTitle)) userTasks.remove(oldTitle);
                            userTasks.addAll({
                              title: {
                                "time": (_awaitedTime != null)
                                    ? "${(_awaitedTime.hour > 12) ? _awaitedTime.hour - 12 : _awaitedTime.hour}:${(_awaitedTime.minute < 10) ? '0${_awaitedTime.minute}' : _awaitedTime.minute} ${(_awaitedTime.period.index == 1) ? 'PM' : 'AM'}"
                                    : "Any Time",
                                "endtime": (_awaitedTime2 != null)
                                    ? "${(_awaitedTime2.hour > 12) ? _awaitedTime2.hour - 12 : _awaitedTime2.hour}:${(_awaitedTime2.minute < 10) ? '0${_awaitedTime2.minute}' : _awaitedTime2.minute} ${(_awaitedTime2.period.index == 1) ? 'PM' : 'AM'}"
                                    : "Any Time",
                                "notify": true,
                                "description": description ?? '',
                                "image": null,
                                "importance": _importance,
                                "repeat": false,
                                "done": (!modifyWhat) ? false : done,
                                "week": (dropdown == "Tomorrow")
                                    ? ((_currentWeek == "Sunday") ? 0 : weeks.indexOf(_currentWeek) + 1)
                                    : weeks.indexOf(week)
                              },
                            });
                          });
                          Database.upload(userTasks);
                          Navigator.of(context).pop();
                          setState2(() => userTasks = userTasks);
                        }
                      }),
                  if (modifyWhat)
                    GradientButton(
                      shadowColor: Colors.black26,
                      elevation: (kIsWeb) ? 0.0 : 6.0,
                      shapeRadius: BorderRadius.circular(10),
                      gradient: Gradients.aliHussien,
                      increaseWidthBy: 20,
                      child: const Text("Delete", style: TextStyle(color: Colors.white)),
                      callback: () {
                        Database.upload(userTasks);
                        Navigator.of(context).pop();
                        setState2(() => userTasks.remove(title));
                      },
                    )
                ],
              ),
            )
          ],
        ),
        titleBackground: Colors.red,
        contentBackground: Colors.white,
        icon: const Icon(Icons.edit, color: Colors.white, size: 25),
      ),
    );
  }
}
