import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/procedure.dart';

abstract class IProcedureRepository {
  Future<List<Procedure>> getProcedures();
  Future<Procedure?> getProcedureById(String id);
  Future<List<Procedure>> searchProcedures(String query);
}

class ProcedureRepository implements IProcedureRepository {
  List<Procedure> _cache = [];
  final FirebaseFirestore _firestore;

  ProcedureRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Procedure>> getProcedures() async {
    if (_cache.isNotEmpty) return _cache;

    try {
      final snapshot = await _firestore
          .collection('procedures')
          .get(const GetOptions(source: Source.serverAndCache));

      _cache = snapshot.docs
          .map((doc) => Procedure.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      return _cache;
    } catch (e) {
      debugPrint('Error loading procedures from Firestore: $e');
      return [];
    }
  }

  @override
  Future<Procedure?> getProcedureById(String id) async {
    final procedures = await getProcedures();
    try {
      return procedures.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Procedure>> searchProcedures(String query) async {
    final procedures = await getProcedures();
    if (query.isEmpty) return procedures;

    final searchLower = query.toLowerCase();
    return procedures.where((p) {
      return p.title.toLowerCase().contains(searchLower) ||
             p.category.toLowerCase().contains(searchLower) ||
             p.description.toLowerCase().contains(searchLower);
    }).toList();
  }
}
