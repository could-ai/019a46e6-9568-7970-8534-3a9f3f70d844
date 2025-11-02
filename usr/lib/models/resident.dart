class Resident {
  int? id;
  String calle;
  String nombres;
  String apellidos;
  DateTime fechaNacimiento;
  String cedula;
  int? edad;
  String? telefono;
  String? direccion;
  bool? vota;
  String? centroVotacion;
  bool? alimentacion;
  bool? pension;
  bool? maternidad;
  bool? escolaridad;
  bool? bnt;
  bool? hogaresPatria;

  Resident({
    this.id,
    required this.calle,
    required this.nombres,
    required this.apellidos,
    required this.fechaNacimiento,
    required this.cedula,
    this.edad,
    this.telefono,
    this.direccion,
    this.vota,
    this.centroVotacion,
    this.alimentacion,
    this.pension,
    this.maternidad,
    this.escolaridad,
    this.bnt,
    this.hogaresPatria,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'calle': calle,
      'nombres': nombres,
      'apellidos': apellidos,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
      'cedula': cedula,
      'edad': edad,
      'telefono': telefono,
      'direccion': direccion,
      'vota': vota == true ? 1 : 0,
      'centroVotacion': centroVotacion,
      'alimentacion': alimentacion == true ? 1 : 0,
      'pension': pension == true ? 1 : 0,
      'maternidad': maternidad == true ? 1 : 0,
      'escolaridad': escolaridad == true ? 1 : 0,
      'bnt': bnt == true ? 1 : 0,
      'hogaresPatria': hogaresPatria == true ? 1 : 0,
    };
  }

  static Resident fromMap(Map<String, dynamic> map) {
    return Resident(
      id: map['id'],
      calle: map['calle'],
      nombres: map['nombres'],
      apellidos: map['apellidos'],
      fechaNacimiento: DateTime.parse(map['fechaNacimiento']),
      cedula: map['cedula'],
      edad: map['edad'],
      telefono: map['telefono'],
      direccion: map['direccion'],
      vota: map['vota'] == 1,
      centroVotacion: map['centroVotacion'],
      alimentacion: map['alimentacion'] == 1,
      pension: map['pension'] == 1,
      maternidad: map['maternidad'] == 1,
      escolaridad: map['escolaridad'] == 1,
      bnt: map['bnt'] == 1,
      hogaresPatria: map['hogaresPatria'] == 1,
    );
  }

  int calcularEdad() {
    DateTime hoy = DateTime.now();
    int edad = hoy.year - fechaNacimiento.year;
    if (hoy.month < fechaNacimiento.month ||
        (hoy.month == fechaNacimiento.month && hoy.day < fechaNacimiento.day)) {
      edad--;
    }
    return edad;
  }
}