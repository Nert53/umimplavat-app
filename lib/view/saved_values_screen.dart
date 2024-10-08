import 'dart:async';

import 'package:code/data/database_service.dart';
import 'package:code/model/all_values.dart';
import 'package:flutter/material.dart';

class SavedValuesScreen extends StatefulWidget {
  const SavedValuesScreen({super.key});

  @override
  State<SavedValuesScreen> createState() => _SavedValuesScreenState();
}

class _SavedValuesScreenState extends State<SavedValuesScreen> {
  late List<AllValues> _records = [];
  bool isLoading = false;
  final noteTextController = TextEditingController();

  bool isUndoPressed = false;

  Future<void> _getAllRecords() async {
    setState(() {
      isLoading = true;
    });

    _records = await DatabaseService.instance.getValues();

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    _getAllRecords();
    super.initState();
  }

  void editNoteDialog(AllValues record) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit note for this record'),
              Text(
                'Record from: ${record.date}',
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(
                controller: noteTextController..text = record.noteText,
                maxLines: 3,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close_outlined),
                      color: Colors.red),
                  IconButton(
                    onPressed: () {
                      record.noteText = noteTextController.text;
                      DatabaseService.instance.updateValue(record);
                      Navigator.of(context).pop();
                      _getAllRecords();
                    },
                    icon: const Icon(Icons.save_outlined),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Values'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            color: Colors.black,
            tooltip: 'View help.',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Explenations'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Icon(Icons.timer_outlined),
                            SizedBox(width: 8),
                            Text('... measured time'),
                          ],
                        ),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Icon(Icons.trending_up_outlined),
                            SizedBox(width: 8),
                            Text('... measured SR'),
                          ],
                        ),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Icon(Icons.straighten_outlined),
                            SizedBox(width: 8),
                            Text('... measured section length'),
                          ],
                        ),
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Icon(Icons.notes_outlined),
                            SizedBox(width: 8),
                            Text('... editable note'),
                          ],
                        ),
                        const Divider(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Icon(Icons.timer,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            const Text('... new swim time'),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Icon(
                              Icons.trending_up,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text('... calculated SR'),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            ImageIcon(
                              const AssetImage('assets/icons/arrow_range.png'),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text('... calculated SL'),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : _records.isEmpty
                  ? const Text('No values saved yet.',
                      style: TextStyle(fontSize: 20))
                  : buildValueList()),
    );
  }

  Widget buildValueList() {
    return ListView.builder(
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0, 2),
                blurRadius: 2,
              ),
            ],
          ),
          child: ListTile(
            key: Key(record.id),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.timer_outlined),
                    const SizedBox(width: 8),
                    Text('${record.originalTime} s'),
                  ],
                ),
                Row(
                  children: <Widget>[
                    const Icon(Icons.trending_up_outlined),
                    const SizedBox(width: 8),
                    Text('${record.originalStrokeRate} cycles/min'),
                  ],
                ),
                Row(
                  children: <Widget>[
                    const Icon(Icons.straighten_outlined),
                    const SizedBox(width: 8),
                    Text('${record.sectionLength} m'),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.timer,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text('${record.newTime} s'),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.trending_up,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text('${record.newStrokeRate} cycles/min'),
                  ],
                ),
                Row(
                  children: <Widget>[
                    ImageIcon(
                      const AssetImage('assets/icons/arrow_range.png'),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text('${record.newStrokeLength} m'),
                  ],
                ),
                Row(
                  children: <Widget>[
                    const Icon(Icons.notes_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                          maxLines: 5,
                          overflow: TextOverflow.clip,
                          record.noteText),
                    ),
                  ],
                ),
              ],
            ),
            subtitle: Text('Saved on: ${record.date}',
                style: const TextStyle(color: Colors.blueGrey)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit_note_outlined,
                    size: 30,
                  ),
                  onPressed: () {
                    editNoteDialog(record);
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outlined,
                    color: Colors.red,
                    size: 30,
                  ),
                  tooltip: 'Delete this value.',
                  onPressed: () async {
                    _deleteValue(record, index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteValue(AllValues record, int recordIndex) {
    setState(() {
      _records.remove(record);
    });

    displayUndoSnackbar(context, record, recordIndex);
    Timer.periodic(const Duration(milliseconds: 3000), (timer) async {
      if (isUndoPressed) {
        timer.cancel();
        isUndoPressed = false;
        return;
      } else {
        DatabaseService.instance.deleteValue(record.id);
        isUndoPressed = false;
        setState(() {
          _getAllRecords();
        });
      }
    });
  }

  void displayUndoSnackbar(
      BuildContext context, AllValues record, int recordIndex) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Values of ${record.date} was deleted.'),
        duration: const Duration(milliseconds: 3000),
        behavior: SnackBarBehavior.floating,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          onPressed: () {
            isUndoPressed = true;
            setState(() {
              _records.insert(recordIndex, record);
            });
          },
        ),
      ),
    );
  }
}
