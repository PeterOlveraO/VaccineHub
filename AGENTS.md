# AGENTS.md - Guía de Desarrollo VaccineHub

## Descripción del Proyecto

VaccineHub es una aplicación Flutter para la administración de vacunas y gestión de pacientes. Utiliza SQLite para persistencia local de datos con arquitectura de patrón Repository.

## Comandos de Build y Desarrollo

### Instalar Dependencias
```bash
flutter pub get
```

### Ejecutar la Aplicación
```bash
flutter run
```

### Ejecutar en un Dispositivo Específico
```bash
flutter run -d <device_id>
flutter run -d emulator-5554  # Emulador Android
```

### Ejecutar Pruebas
```bash
flutter test                    # Ejecutar todas las pruebas
flutter test test/file.dart     # Ejecutar un archivo de prueba específico
flutter test --plain-name "test name"  # Ejecutar prueba por nombre
```

### Análisis Estático
```bash
flutter analyze                 # Ejecutar análisis estático
flutter analyze lib/            # Analizar directorio específico
flutter analyze --no-fatal-infos  # Ejecutar sin fallar en infos
```

### Comandos de Build
```bash
flutter build apk               # Build APK Android (debug)
flutter build apk --release     # Build APK Android (release)
flutter build ios               # Build iOS (solo macOS)
flutter build web               # Build para web
```

---

## Guías de Estilo de Código

### Organización de Archivos

```
lib/
├── main.dart
├── core/
│   └── database/
│       └── database_helper.dart
├── models/
│   ├── patient.dart
│   ├── vaccine.dart
│   ├── vaccine_schedule.dart
│   └── appointment.dart
└── repositories/
    ├── patient_repository.dart
    ├── vaccine_repository.dart
    ├── vaccine_schedule_repository.dart
    └── appointment_repository.dart
```

### Convenciones de Nombres

| Elemento | Convención | Ejemplo |
|---------|-------------|---------|
| Clases | PascalCase | `Patient`, `DatabaseHelper` |
| Métodos | camelCase | `insertPatient()`, `getAllPatients()` |
| Variables | camelCase | `fullName`, `databaseHelper` |
| Columnas BD | snake_case | `full_name`, `registration_date` |
| Constantes | camelCase | `maxBatchSize` |
| Archivos | snake_case | `patient_repository.dart` |

### Patrón de Modelos

Todos los modelos deben seguir esta estructura:

```dart
class ModelName {
  final int? id;
  final String requiredField;
  final String? optionalField;

  ModelName({
    this.id,
    required this.requiredField,
    this.optionalField,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'column_name': requiredField,
    };
  }

  factory ModelName.fromMap(Map<String, dynamic> map) {
    return ModelName(
      id: map['id'] as int?,
      requiredField: map['column_name'] as String,
    );
  }
}
```

### Patrón Repository

- Usar singleton `DatabaseHelper` para acceso a la base de datos
- Las clases Repository gestionan operaciones CRUD
- Usar `Future<ReturnType>` para métodos asíncronos
- Siempre usar `await` al llamar métodos asíncronos

```dart
class PatientRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertPatient(Patient patient) async {
    final db = await _databaseHelper.database;
    return await db.insert(
      'patients',
      patient.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
```

### Convenciones de Base de Datos

- Usar snake_case para nombres de tablas y columnas
- Siempre usar consultas parametrizadas con `whereArgs`
- Habilitar foreign keys: `PRAGMA foreign_keys = ON`
- Usar cascade delete para registros relacionados
- Usar INTEGER NOT NULL DEFAULT 0 para booleanos (convertir bool↔int en modelos)

### Organización de Imports

```dart
// Imports de paquetes primero
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Imports relativos
import '../core/database/database_helper.dart';
import '../models/patient.dart';
```

### Manejo de Errores

- Usar try-catch para operaciones de base de datos
- Permitir que las excepciones se propaguen con contexto significativo
- Evitar bloques catch vacíos

### Reglas de Lint (desde analysis_options.yaml)

El proyecto usa el paquete `flutter_lints`. Reglas principales:
- No usar print en producción (usar logging)
- Preferir comillas simples para strings
- Siempre especificar tipos de retorno para métodos públicos
- Usar constructores `const` donde sea posible

---

## Arquitectura

### Esquema de Base de Datos

| Tabla | Columnas Principales |
|-------|---------------------|
| patients | id, full_name, phone, registration_date |
| vaccines | id, name, total_doses |
| vaccine_schedules | id, vaccine_id, dose_number, days_to_next_dose |
| appointments | id, patient_id, vaccine_id, dose_number, batch_group, status, is_paid, application_date, next_dose_date, created_at |

### Reglas de Negocio

- Máximo 10 citas por batch_group
- Completar una cita genera automáticamente la siguiente dosis programada
- Foreign keys con cascade delete habilitado

---

## Pruebas

Las pruebas van en el directorio `test/`. Estructurar pruebas así:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:vaccinehub/models/patient.dart';

void main() {
  group('Patient Model', () {
    test('toMap convierte al formato correcto', () {
      final patient = Patient(
        id: 1,
        fullName: 'John Doe',
        registrationDate: '2024-01-01',
      );
      final map = patient.toMap();
      expect(map['full_name'], 'John Doe');
    });
  });
}
```

---

## Problemas Comunes

- **SQLite no funciona**: Asegurarse de que el emulador/dispositivo esté ejecutándose
- **Errores de foreign key**: Verificar `PRAGMA foreign_keys = ON` en la inicialización de la base de datos
- **Fallos de build**: Ejecutar `flutter clean` luego `flutter pub get`
