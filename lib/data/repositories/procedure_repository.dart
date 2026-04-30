import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/procedure.dart';

abstract class IProcedureRepository {
  Future<List<Procedure>> getProcedures();
  Future<Procedure?> getProcedureById(String id);
  Future<List<Procedure>> searchProcedures(String query);
}

class ProcedureRepository implements IProcedureRepository {
  List<Procedure> _cache = [];

  @override
  Future<List<Procedure>> getProcedures() async {
    if (_cache.isNotEmpty) return _cache;
    
    try {
      final String response = await rootBundle.loadString('assets/json/procedures.json');
      final List<dynamic> data = json.decode(response);
      _cache = data.map((json) => Procedure.fromJson(json)).toList();
      return _cache;
    } catch (e) {
      debugPrint('Error loading procedures: $e');
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
