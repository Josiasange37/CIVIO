import 'dart:convert';
import 'package:flutter/services.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Procedure>> getProcedures() async {
    if (_cache.isNotEmpty) return _cache;
    
    try {
      final snapshot = await _firestore.collection('procedures').get(const GetOptions(source: Source.serverAndCache));
      
      if (snapshot.docs.isNotEmpty) {
        _cache = snapshot.docs.map((doc) => Procedure.fromJson(doc.data())).toList();
        return _cache;
      }
      
      // Seed Firestore if empty
      debugPrint('Firestore procedures empty. Seeding from local JSON...');
      final String response = await rootBundle.loadString('assets/json/procedures.json');
      final List<dynamic> data = json.decode(response);
      final procedures = data.map((json) => Procedure.fromJson(json)).toList();
      
      for (var procedure in procedures) {
        await _firestore.collection('procedures').doc(procedure.id).set(procedure.toJson());
      }
      
      _cache = procedures;
      return _cache;
    } catch (e) {
      debugPrint('Error loading procedures from Firestore: $e');
      // Fallback to local JSON entirely if Firestore fails
      try {
        final String response = await rootBundle.loadString('assets/json/procedures.json');
        final List<dynamic> data = json.decode(response);
        _cache = data.map((json) => Procedure.fromJson(json)).toList();
        return _cache;
      } catch (innerE) {
        debugPrint('Fallback local load failed: $innerE');
        return [];
      }
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
