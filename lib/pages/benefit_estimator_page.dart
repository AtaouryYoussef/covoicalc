import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BenefitEstimatorPage extends StatefulWidget {
  @override
  _BenefitEstimatorPageState createState() => _BenefitEstimatorPageState();
}

class _BenefitEstimatorPageState extends State<BenefitEstimatorPage> {
  final TextEditingController _revenueController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _consumptionController = TextEditingController();
  final TextEditingController _fuelPriceController = TextEditingController();
  final List<TextEditingController> _extraChargesControllers = [
    TextEditingController(),
  ];

  List<DocumentSnapshot> _vehicles = [];
  String? _selectedVehicleId;
  double? _benefit;

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
        final consumption = _vehicles.first['consumption'];
        _consumptionController.text = consumption.toString();
      }
    });
  }

  void _addExtraChargeField() {
    setState(() {
      _extraChargesControllers.add(TextEditingController());
    });
  }

  void _calculateBenefit() {
    final revenue = double.tryParse(_revenueController.text);
    final distance = double.tryParse(_distanceController.text);
    final consumption = double.tryParse(_consumptionController.text);
    final fuelPrice = double.tryParse(_fuelPriceController.text);

    if (revenue == null ||
        distance == null ||
        consumption == null ||
        fuelPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs requis.')),
      );
      return;
    }

    double totalExtras = 0;
    for (var controller in _extraChargesControllers) {
      final extra = double.tryParse(controller.text);
      if (extra != null) totalExtras += extra;
    }

    final fuelCost = (distance / 100) * consumption * fuelPrice;
    final netBenefit = revenue - fuelCost - totalExtras;

    setState(() {
      _benefit = netBenefit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Estimation du Bénéfice')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Revenue
            TextField(
              controller: _revenueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Revenu affiché (Dhs)',
                hintText: 'Ex : 150 Dhs',
              ),
            ),
            SizedBox(height: 16),

            // Distance
            TextField(
              controller: _distanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Kilométrage circulé (km)',
                hintText: 'Ex : 50 km',
              ),
            ),
            SizedBox(height: 16),

            // Vehicle Dropdown
            DropdownButtonFormField<String>(
              value: _selectedVehicleId,
              decoration: InputDecoration(
                labelText: 'Sélectionnez un véhicule',
              ),
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

            // Consommation (Editable)
            TextField(
              controller: _consumptionController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Consommation (L/100km)',
                helperText: 'Modifiable si besoin',
              ),
            ),
            SizedBox(height: 16),

            // Prix carburant
            TextField(
              controller: _fuelPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Prix du carburant (Dhs/L)',
              ),
            ),
            SizedBox(height: 16),

            // Extra charges
            ..._extraChargesControllers.map((controller) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Charges supplémentaires',
                    hintText: 'Ex : péage, vidange...',
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

            // Calculate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _calculateBenefit,
                icon: Icon(Icons.calculate),
                label: Text('Calculer le bénéfice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            // Result
            if (_benefit != null) ...[
              SizedBox(height: 24),
              Text(
                '🧾 Bénéfice estimé : ${_benefit!.toStringAsFixed(2)} Dhs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
            SizedBox(height: 32),
            Text('© 2025 CovoitCalc. Tous droits réservés.'),
          ],
        ),
      ),
    );
  }
}
