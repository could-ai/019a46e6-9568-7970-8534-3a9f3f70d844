import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/resident.dart';
import 'detail_screen.dart';

class ViewRecordsScreen extends StatefulWidget {
  const ViewRecordsScreen({super.key});

  @override
  State<ViewRecordsScreen> createState() => _ViewRecordsScreenState();
}

class _ViewRecordsScreenState extends State<ViewRecordsScreen> {
  List<Resident> _residents = [];
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _loadResidents();
  }

  void _loadResidents() async {
    _residents = await DatabaseHelper().getResidents();
    setState(() {});
  }

  void _deleteResident(int id) async {
    await DatabaseHelper().deleteResident(id);
    _loadResidents();
    setState(() => _selectedIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ver Registros')),
      body: _residents.isEmpty
          ? const Center(child: Text('No hay registros'))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Calle')),
                        DataColumn(label: Text('Nombres')),
                        DataColumn(label: Text('Apellidos')),
                        DataColumn(label: Text('Fecha Nac.')),
                        DataColumn(label: Text('Cédula')),
                        DataColumn(label: Text('Edad')),
                      ],
                      rows: _residents.map((resident) {
                        int index = _residents.indexOf(resident);
                        return DataRow(
                          selected: _selectedIndex == index,
                          onSelectChanged: (selected) {
                            setState(() => _selectedIndex = selected! ? index : null);
                          },
                          color: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.grey.shade300;
                              }
                              return null;
                            },
                          ),
                          cells: [
                            DataCell(Text(resident.calle)),
                            DataCell(
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailScreen(resident: resident),
                                  ),
                                ),
                                child: Text(resident.nombres, style: const TextStyle(color: Colors.blue)),
                              ),
                            ),
                            DataCell(Text(resident.apellidos)),
                            DataCell(Text('${resident.fechaNacimiento.day}/${resident.fechaNacimiento.month}/${resident.fechaNacimiento.year}')),
                            DataCell(Text(resident.cedula)),
                            DataCell(Text('${resident.edad}')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                if (_selectedIndex != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/',
                            arguments: _residents[_selectedIndex!],
                          ).then((_) => _loadResidents());
                        },
                        child: const Text('Editar'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _deleteResident(_residents[_selectedIndex!].id!),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}