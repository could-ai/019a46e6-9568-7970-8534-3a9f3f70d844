import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/resident.dart';
import '../providers/theme_provider.dart';
import 'view_records_screen.dart';
import 'statistics_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _calles = [
    'Libertador',
    'Atamaica',
    'Callejón Atamaica',
    'Principal',
    'Callejón Principal',
    'Don Julio',
    'Soublette',
    'José Antonio Páez',
  ];

  String? _selectedCalle;
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  DateTime? _fechaNacimiento;
  final TextEditingController _cedulaController = TextEditingController();
  Resident? _editingResident;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Resident?;
      if (args != null) {
        _loadResidentForEdit(args);
      }
    });
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _cedulaController.dispose();
    super.dispose();
  }

  void _capitalizeFirstLetter(TextEditingController controller) {
    String text = controller.text;
    if (text.isNotEmpty && text[0] != text[0].toUpperCase()) {
      controller.text = text[0].toUpperCase() + text.substring(1);
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  String? _validateCedula(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    RegExp regExp = RegExp(r'^[VE]-\d{8}$');
    if (!regExp.hasMatch(value)) return 'Formato: V-xxxxxxxx o E-xxxxxxxx';
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate() && _selectedCalle != null && _fechaNacimiento != null) {
      Resident resident = Resident(
        calle: _selectedCalle!,
        nombres: _nombresController.text,
        apellidos: _apellidosController.text,
        fechaNacimiento: _fechaNacimiento!,
        cedula: _cedulaController.text,
      );
      resident.edad = resident.calcularEdad();

      if (_editingResident != null) {
        resident.id = _editingResident!.id;
        await DatabaseHelper().updateResident(resident);
        _editingResident = null; // Reset after update
      } else {
        await DatabaseHelper().insertResident(resident);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro efectuado correctamente')),
      );
      _clearForm();
    }
  }

  void _clearForm() {
    _selectedCalle = null;
    _nombresController.clear();
    _apellidosController.clear();
    _fechaNacimiento = null;
    _cedulaController.clear();
    _editingResident = null;
    setState(() {});
  }

  void _loadResidentForEdit(Resident resident) {
    _editingResident = resident;
    _selectedCalle = resident.calle;
    _nombresController.text = resident.nombres;
    _apellidosController.text = resident.apellidos;
    _fechaNacimiento = resident.fechaNacimiento;
    _cedulaController.text = resident.cedula;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidad Santa Rosalía'),
        actions: [
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Estrellas de Venezuela
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(8, (index) => const Icon(Icons.star, color: Colors.yellow)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Comunidad Santa Rosalía',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Calle'),
                    value: _selectedCalle,
                    items: _calles.map((String calle) {
                      return DropdownMenuItem<String>(
                        value: calle,
                        child: Text(calle),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCalle = value),
                    validator: (value) => value == null ? 'Selecciona una calle' : null,
                  ),
                  TextFormField(
                    controller: _nombresController,
                    decoration: const InputDecoration(labelText: 'Nombres'),
                    onChanged: (_) => _capitalizeFirstLetter(_nombresController),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: _apellidosController,
                    decoration: const InputDecoration(labelText: 'Apellidos'),
                    onChanged: (_) => _capitalizeFirstLetter(_apellidosController),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Fecha de Nacimiento'),
                    controller: TextEditingController(
                      text: _fechaNacimiento != null ? DateFormat('dd/MM/yyyy').format(_fechaNacimiento!) : '',
                    ),
                    onTap: () => _selectDate(context),
                    validator: (value) => _fechaNacimiento == null ? 'Selecciona fecha' : null,
                  ),
                  TextFormField(
                    controller: _cedulaController,
                    decoration: const InputDecoration(labelText: 'Cédula de Identidad'),
                    validator: _validateCedula,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow, foregroundColor: Colors.white),
                  onPressed: _register,
                  child: const Text('Registrar'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  onPressed: () => Navigator.pushNamed(context, '/view'),
                  child: const Text('Ver Registro'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  onPressed: () => Navigator.pushNamed(context, '/stats'),
                  child: const Text('Estadísticas'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}