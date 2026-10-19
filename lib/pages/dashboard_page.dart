import 'package:covoitcalc_app/pages/vehicle_page.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final String userEmail;

  const DashboardPage({Key? key, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Se déconnecter'),
              onTap: () {
                // TODO: Add logout logic
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png', // Make sure logo.png exists
              height: 30,
            ),
            SizedBox(width: 8),
            /* RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 20),
                children: [
                  TextSpan(
                    text: 'COVOIT',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(text: 'CALC', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),*/
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Bienvenue, $userEmail 👋',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildNavButton(
                  context,
                  icon: Icons.calculate,
                  label: 'Estimer le Coût',
                  onTap: () {
                    // Navigate to cost estimation
                  },
                ),
                _buildNavButton(
                  context,
                  icon: Icons.attach_money,
                  label: 'Calculer le Bénéfice',
                  onTap: () {
                    // Navigate to benefit calculation
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildNavButton(
                        context,
                        icon: Icons.calendar_today,
                        label: 'Planification',
                        subtitle: 'Consulter et ajuster\nvotre planification',
                        onTap: () {},
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildNavButton(
                        context,
                        icon: Icons.map,
                        label: 'Traffic Live',
                        subtitle:
                            'Suivez l’état du trafic\net optimisez vos trajets',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                _buildNavButton(
                  context,
                  icon: Icons.directions_car,
                  label: 'Mes Véhicules',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VehiclesPage()),
                    );
                  },
                ),
                _buildNavButton(
                  context,
                  icon: Icons.settings,
                  label: 'Paramètres',
                  onTap: () {
                    // Navigate to settings
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              '© 2025 CovoitCalc. All rights reserved.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                color: Colors.grey.withOpacity(0.2),
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              SizedBox(width: 16),
              Expanded(
                child:
                    subtitle == null
                        ? Text(label, style: TextStyle(fontSize: 18))
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
