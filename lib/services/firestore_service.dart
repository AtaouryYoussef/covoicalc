import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _collection = 'vehicles';

  Stream<List<Vehicle>> getVehicles() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Vehicle(
          id: doc.id,
          name: doc['name'],
          consumption: doc['consumption'],
        );
      }).toList();
    });
  }

  Future<void> addVehicle(Vehicle vehicle) {
    return _db.collection(_collection).add({
      'name': vehicle.name,
      'consumption': vehicle.consumption,
    });
  }

  Future<void> updateVehicle(Vehicle vehicle) {
    return _db.collection(_collection).doc(vehicle.id).update({
      'name': vehicle.name,
      'consumption': vehicle.consumption,
    });
  }

  Future<void> deleteVehicle(String id) {
    return _db.collection(_collection).doc(id).delete();
  }
}
