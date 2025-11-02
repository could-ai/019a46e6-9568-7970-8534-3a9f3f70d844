import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/resident.dart';

class DetailScreen extends StatefulWidget {
  final Resident resident;

  const DetailScreen({super.key, required this.resident});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _centroVotacionController;
  bool _vota = false;
  bool _alimentacion = false;
  bool _pension = false;
  bool _maternidad = false;
  bool _escolaridad = false;
  bool _bnt = false;
  bool _hogaresPatria = false;

  @override
  void initState() {
    super.initState();
    _telefonoController = TextEditingController(text: widget.resident.telefono);
    _direccionController = TextEditingController(text: widget.resident.direccion);
    _centroVotacionController = TextEditingController(text: widget.resident.centroVotacion);
    _vota = widget.resident.vota ?? false;
    _alimentacion = widget.resident.alimentacion ?? false;
    _pension = widget.resident.pension ?? false;
    _maternidad = widget.resident.maternidad ?? false;
    _escolaridad = widget.resident.escolaridad ?? false;
    _bnt = widget.resident.bnt ?? false;
    _hogaresPatria = widget.resident.hogaresPatria ?? false;
  }

  @override
  void dispose() {
    _telefonoController.dispose();
    _direccionController.dispose();
    _centroVotacionController.dispose();
    super.dispose();
  }

  void _saveDetails() async {
    Resident updatedResident = Resident(
      id: widget.resident.id,
      calle: widget.resident.calle,
      nombres: widget.resident.nombres,
      apellidos: widget.resident.apellidos,
      fechaNacimiento: widget.resident.fechaNacimiento,
      cedula: widget.resident.cedula,
      edad: widget.resident.edad,
      telefono: _telefonoController.text,
      direccion: _direccionController.text,
      vota: _vota,
      centroVotacion: _centroVotacionController.text,
      alimentacion: _alimentacion,
      pension: _pension,
      maternidad: _maternidad,
      escolaridad: _escolaridad,
      bnt: _bnt,
      hogaresPatria: _hogaresPatria,
    );
    await DatabaseHelper().updateResident(updatedResident);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ficha Técnica')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Nombres: ${widget.resident.nombres}'),
            Text('Apellidos: ${widget.resident.apellidos}'),
            Text('Cédula: ${widget.resident.cedula}'),
            Text('Fecha de Nacimiento: ${widget.resident.fechaNacimiento.day}/${widget.resident.fechaNacimiento.month}/${widget.resident.fechaNacimiento.year}'),
            Text('Edad: ${widget.resident.edad}'),
            TextField(controller: _telefonoController, decoration: const InputDecoration(labelText: 'Teléfono')),
            TextField(controller: _direccionController, decoration: const InputDecoration(labelText: 'Dirección')),
            Row(children: [
              const Text('Vota: '),
              Checkbox(value: _vota, onChanged: (value) => setState(() => _vota = value!)),
            ]),
            TextField(controller: _centroVotacionController, decoration: const InputDecoration(labelText: 'Centro de Votación')),
            const Text('Beneficiario de misiones sociales:'),
            CheckboxListTile(title: const Text('Alimentación'), value: _alimentacion, onChanged: (value) => setState(() => _alimentacion = value!)),
            CheckboxListTile(title: const Text('Pensión'), value: _pension, onChanged: (value) => setState(() => _pension = value!)),
            CheckboxListTile(title: const Text('Maternidad'), value: _maternidad, onChanged: (value) => setState(() => _maternidad = value!)),
            CheckboxListTile(title: const Text('Escolaridad'), value: _escolaridad, onChanged: (value) => setState(() => _escolaridad = value!)),
            CheckboxListTile(title: const Text('B.N.T'), value: _bnt, onChanged: (value) => setState(() => _bnt = value!)),
            CheckboxListTile(title: const Text('Hogares de la Patria'), value: _hogaresPatria, onChanged: (value) => setState(() => _hogaresPatria = value!)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveDetails, child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
