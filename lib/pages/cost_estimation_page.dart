import 'package:covoitcalc_app/pages/map_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FuelCostCalculatorPage extends StatefulWidget {
  @override
  _FuelCostCalculatorPageState createState() => _FuelCostCalculatorPageState();
}

class _FuelCostCalculatorPageState extends State<FuelCostCalculatorPage> {
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _consumptionController = TextEditingController();
  final TextEditingController _fuelPriceController = TextEditingController();
  final List<TextEditingController> _extraChargesControllers = [
    TextEditingController(),
  ];

  List<DocumentSnapshot> _vehicles = [];
  String? _selectedVehicleId;
  double? _selectedVehicleConsumption;
  double? _calculatedCost;

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  void fetchVehicles() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('vehicles').get();
    setState(() {
      _vehicles = snapshot.docs;
      if (_vehicles.isNotEmpty) {
        _selectedVehicleId = _vehicles.first.id;
        _selectedVehicleConsumption = _vehicles.first['consumption'];
        _consumptionController.text = _selectedVehicleConsumption.toString();
      }
    });
  }

  void _addExtraChargeField() {
    setState(() {
      _extraChargesControllers.add(TextEditingController());
    });
  }

  void _navigateToMap() async {
    final distanceInKm = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapPage()),
    );

    if (distanceInKm != null) {
      setState(() {
        _distanceController.text = distanceInKm.toStringAsFixed(2);
      });
    }
  }

  void _calculate() {
    final distance = double.tryParse(_distanceController.text);
    final consumption = double.tryParse(_consumptionController.text);
    final fuelPrice = double.tryParse(_fuelPriceController.text);

    if (distance == null || consumption == null || fuelPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs requis.')),
      );
      return;
    }

    double totalExtra = 0;
    for (var controller in _extraChargesControllers) {
      final extra = double.tryParse(controller.text);
      if (extra != null) totalExtra += extra;
    }

    final cost = ((distance / 100) * consumption * fuelPrice) + totalExtra;

    setState(() {
      _calculatedCost = cost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ESTIMER LE COÛT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Distance Input or Map
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _distanceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Distance (km)',
                      hintText: 'Entrez la distance du trajet',
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _navigateToMap,
                  icon: Icon(Icons.map),
                  label: Text('Maps'),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Vehicle Dropdown
            DropdownButtonFormField<String>(
              value: _selectedVehicleId,
              decoration: InputDecoration(labelText: 'Choisir un véhicule'),
              items:
                  _vehicles.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(
                        '${data['name']} (${data['consumption']} L/100km)',
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                final selected = _vehicles.firstWhere((v) => v.id == value);
                final consumption = selected['consumption'];
                setState(() {
                  _selectedVehicleId = value;
                  _consumptionController.text = consumption.toString();
                });
              },
            ),
            SizedBox(height: 16),

            // Consommation
            TextField(
              controller: _consumptionController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Consommation (L/100Km)',
                helperText: 'Modifiable si besoin',
              ),
            ),
            SizedBox(height: 16),

            // Fuel Price
            TextField(
              controller: _fuelPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Prix du carburant',
                hintText: 'Ex : 14.20 Dhs/litre (Gasoil, Essence...)',
              ),
            ),
            SizedBox(height: 16),

            // Extra Charges
            ..._extraChargesControllers.map((controller) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Charges supplémentaires',
                    hintText: 'Ex : entretien, vidange, péage, recharge...',
                    suffixIcon: Icon(Icons.info_outline, color: Colors.grey),
                  ),
                ),
              );
            }).toList(),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.add_circle, color: Colors.blue),
                onPressed: _addExtraChargeField,
              ),
            ),
            SizedBox(height: 24),

            // Calculate Button (Full width)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculate,
                icon: Icon(Icons.calculate),
                label: Text('Calculer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            // Display Result Below Button
            if (_calculatedCost != null) ...[
              SizedBox(height: 20),
              Text(
                '💰 Coût total estimé : ${_calculatedCost!.toStringAsFixed(2)} Dhs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],

            SizedBox(height: 32),
            Text('© 2025 CovoitCalc. All rights reserved.'),
          ],
        ),
      ),
    );
  }
}
