import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehiclesPage extends StatelessWidget {
  final CollectionReference vehiclesRef = FirebaseFirestore.instance.collection(
    'vehicles',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vehicles")),
      body: StreamBuilder<QuerySnapshot>(
        stream: vehiclesRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text('No vehicles found.'));
          }

          return ListView(
            children:
                docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name'] ?? 'Unknown';
                  final consumption = data['consumption'] ?? 'Unknown';

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(Icons.directions_car, color: Colors.blue),
                      title: Text(name),
                      subtitle: Text('Consumption: $consumption L/100km'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.green),
                            onPressed:
                                () => _showVehicleDialog(
                                  context,
                                  docId: doc.id,
                                  currentName: name,
                                  currentConsumption: consumption.toString(),
                                ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, doc.id),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVehicleDialog(context),
        child: Icon(Icons.add, color: Colors.white), // White "+" icon
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this vehicle?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                vehiclesRef.doc(docId).delete();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showVehicleDialog(
    BuildContext context, {
    String? docId,
    String? currentName,
    String? currentConsumption,
  }) {
    final nameController = TextEditingController(text: currentName);
    final consumptionController = TextEditingController(
      text: currentConsumption,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? 'Add Vehicle' : 'Edit Vehicle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Vehicle Name'),
              ),
              TextField(
                controller: consumptionController,
                decoration: InputDecoration(labelText: 'Consumption (L/100km)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final consumption = double.tryParse(
                  consumptionController.text.trim(),
                );

                if (name.isNotEmpty && consumption != null) {
                  if (docId == null) {
                    // Add new vehicle
                    vehiclesRef.add({'name': name, 'consumption': consumption});
                  } else {
                    // Update existing vehicle
                    vehiclesRef.doc(docId).update({
                      'name': name,
                      'consumption': consumption,
                    });
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
