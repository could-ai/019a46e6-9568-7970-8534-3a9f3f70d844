import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Map<String, dynamic>> _stats = [];
  final List<String> _calles = [
    'José Antonio Páez',
    'Soublette',
    'Don Julio',
    'Principal',
    'Callejón Principal',
    'Atamaica',
    'Callejón Atamaica',
    'Libertador',
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    _stats = await DatabaseHelper().getStatistics();
    setState(() {});
  }

  Map<String, int> _getAgeCounts(int age) {
    Map<String, int> counts = {};
    for (String calle in _calles) {
      counts[calle] = 0;
    }
    for (var stat in _stats) {
      if (stat['edad'] == age) {
        counts[stat['calle']] = stat['count'];
      }
    }
    return counts;
  }

  Map<String, int> _getStreetTotals() {
    Map<String, int> totals = {};
    for (String calle in _calles) {
      totals[calle] = 0;
    }
    for (var stat in _stats) {
      totals[stat['calle']] = (totals[stat['calle']] ?? 0) + (stat['count'] as int);
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> streetTotals = _getStreetTotals();
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            const DataColumn(label: Text('Edad')),
            ..._calles.map((calle) => DataColumn(label: Text(calle))),
            const DataColumn(label: Text('Total Edades')),
          ],
          rows: [
            ...List.generate(86, (age) {
              Map<String, int> counts = _getAgeCounts(age);
              int totalEdades = counts.values.reduce((a, b) => a + b);
              return DataRow(cells: [
                DataCell(Text('$age')),
                ..._calles.map((calle) => DataCell(Text('${counts[calle]}'))),
                DataCell(Text('$totalEdades')),
              ]);
            }),
            // Total row for streets
            DataRow(
              cells: [
                const DataCell(Text('Total Habitantes')),
                ..._calles.map((calle) => DataCell(Text('${streetTotals[calle]}'))),
                DataCell(Text('${streetTotals.values.reduce((a, b) => a + b)}')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
