import 'package:flutter/material.dart';

class PlanningPage extends StatefulWidget {
  @override
  _PlanningPageState createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  final Map<String, bool> _dayEnabled = {
    'Lundi': true,
    'Mardi': false,
    'Mercredi': false,
    'Jeudi': false,
    'Vendredi': false,
    'Samedi': false,
    'Dimanche': false,
  };

  final Map<String, List<Map<String, TimeOfDay>>> _daySchedules = {
    'Lundi': [
      {
        'start': TimeOfDay(hour: 8, minute: 0),
        'end': TimeOfDay(hour: 12, minute: 0),
      },
      {
        'start': TimeOfDay(hour: 14, minute: 0),
        'end': TimeOfDay(hour: 20, minute: 0),
      },
    ],
    'Mardi': [],
    'Mercredi': [],
    'Jeudi': [],
    'Vendredi': [],
    'Samedi': [],
    'Dimanche': [],
  };

  int _reminderMinutes = 15;

  Future<void> _selectTime(
    BuildContext context,
    String day,
    int index,
    bool isStart,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _daySchedules[day]![index][isStart ? 'start' : 'end']!,
    );
    if (picked != null) {
      setState(() {
        _daySchedules[day]![index][isStart ? 'start' : 'end'] = picked;
      });
    }
  }

  void _addTimeSlot(String day) {
    setState(() {
      _daySchedules[day]!.add({
        'start': TimeOfDay(hour: 8, minute: 0),
        'end': TimeOfDay(hour: 12, minute: 0),
      });
    });
  }

  void _deleteTimeSlot(String day, int index) {
    setState(() {
      _daySchedules[day]!.removeAt(index);
    });
  }

  String _formatTime(TimeOfDay time) {
    return time.hour.toString().padLeft(2, '0') +
        ':' +
        time.minute.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final days = _dayEnabled.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('MON PLANNING'),
        backgroundColor: Color(0xFF1A2D4A),
        automaticallyImplyLeading: false, // Remove nav button
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            "Définissez vos jours et heures de travail pour recevoir des rappels.",
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 24),
          ...days.map((day) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch(
                      value: _dayEnabled[day]!,
                      onChanged: (value) {
                        setState(() => _dayEnabled[day] = value);
                      },
                    ),
                  ],
                ),
                if (_dayEnabled[day]!) ...[
                  ..._daySchedules[day]!.asMap().entries.map((entry) {
                    int index = entry.key;
                    var slot = entry.value;
                    return Row(
                      children: [
                        Icon(Icons.alarm, size: 18),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _selectTime(context, day, index, true),
                          child: Text(
                            _formatTime(slot['start']!),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(" - "),
                        GestureDetector(
                          onTap: () => _selectTime(context, day, index, false),
                          child: Text(
                            _formatTime(slot['end']!),
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTimeSlot(day, index),
                        ),
                      ],
                    );
                  }),
                  TextButton(
                    onPressed: () => _addTimeSlot(day),
                    child: Text('+ Ajouter un créneau'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                ],
                Divider(),
              ],
            );
          }),
          SizedBox(height: 8),
          Text("Recevoir un rappel avant chaque session :"),
          DropdownButton<int>(
            value: _reminderMinutes,
            onChanged: (value) {
              if (value != null) {
                setState(() => _reminderMinutes = value);
              }
            },
            items:
                [5, 10, 15, 30, 60]
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e, child: Text('$e minutes')),
                    )
                    .toList(),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text("Enregistrer la planification"),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Planning enregistré !")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF20C962),
                padding: EdgeInsets.symmetric(vertical: 14),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 24),
          Center(child: Text("© 2025 CovoitCalc. All rights reserved.")),
        ],
      ),
    );
  }
}
