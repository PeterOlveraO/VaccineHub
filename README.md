# VaccineHub

Sistema de administración de vacunas para pacientes.

## Estructura de Carpetas

```
lib/
├── main.dart
├── core/
│   └── database/
│       └── database_helper.dart    # Singleton DatabaseHelper con SQLite
├── models/
│   ├── patient.dart                 # Modelo Patient
│   ├── vaccine.dart                 # Modelo Vaccine
│   ├── vaccine_schedule.dart        # Modelo VaccineSchedule
│   └── appointment.dart             # Modelo Appointment
└── repositories/
    ├── patient_repository.dart             # CRUD pacientes
    ├── vaccine_repository.dart              # CRUD vacunas
    ├── vaccine_schedule_repository.dart      # CRUD esquemas de dosis
    └── appointment_repository.dart           # CRUD citas + lógica de negocio
```

## Tecnologías y Dependencias

- **Framework:** Flutter
- **Base de Datos:** SQLite
- **Paquetes:**
  - `sqflite: ^2.3.0`
  - `path: ^1.8.3`

## Instalación y Ejecución

### Requisitos Previos

- Flutter SDK instalado
- Un emulador de Android/iOS configurado o un dispositivo físico conectado

### Comandos

```bash
# Instalar dependencias
flutter pub get

# Ejecutar el proyecto
flutter run
```

## Arquitectura del Proyecto

### Base de Datos (SQLite)

| Tabla | Columnas |
|-------|----------|
| `patients` | id, full_name, phone, registration_date |
| `vaccines` | id, name, total_doses |
| `vaccine_schedules` | id, vaccine_id, dose_number, days_to_next_dose |
| `appointments` | id, patient_id, vaccine_id, dose_number, batch_group, status, is_paid, application_date, next_dose_date, created_at |

**Características:**
- Foreign Keys activadas con `PRAGMA foreign_keys = ON`
- Eliminación en cascada configurada

### Modelos (lib/models/)

| Modelo | Propiedades |
|--------|-------------|
| `Patient` | id, fullName, phone, registrationDate |
| `Vaccine` | id, name, totalDoses |
| `VaccineSchedule` | id, vaccineId, doseNumber, daysToNextDose |
| `Appointment` | id, patientId, vaccineId, doseNumber, batchGroup, status, isPaid, applicationDate, nextDoseDate, createdAt |

Cada modelo incluye:
- Constructor principal
- `toMap()` - Convierte a Map para SQLite
- `fromMap()` - Factory constructor desde Map
- Conversión automática bool ↔ int para `isPaid`

### Repositorios (lib/repositories/)

| Repositorio | Métodos |
|-------------|---------|
| `PatientRepository` | insertPatient, getAllPatients, searchPatients, deletePatient |
| `VaccineRepository` | getAllVaccines, insertVaccine |
| `VaccineScheduleRepository` | getSchedulesForVaccine, insertSchedule |
| `AppointmentRepository` | insertAppointment, getPendingAppointmentsByMonth, completeAppointment |

**Reglas de negocio implementadas:**
- Límite de 10 citas por batch_group
- Generación automática de siguiente cita al completar una dosis
- Cálculo dinámico de próxima fecha según days_to_next_dose

## Script de Prueba (lib/main.dart)

Contiene una prueba de integración que:
1. Inserta vacuna VPH (3 dosis)
2. Inserta esquemas de dosis (30 y 60 días)
3. Inserta paciente María López
4. Crea cita con batch_group
5. Completa la cita
6. Genera automáticamente la siguiente cita programada
7. Busca citas pendientes por mes

---
##  Guía de Ejecución y Pruebas (Entorno Local)

1. Iniciar el Emulador
Abre tu terminal  y ejecuta:

emulator -avd Emulador_Vacunas

Espera a que el sistema operativo Android cargue por completo en la ventana del emulador.

2. Ejecutar la Aplicación
Abre una nueva pestaña en tu terminal dentro de la raíz del proyecto y ejecuta:

flutter run

Si la terminal te lo solicita, ingresa el número correspondiente al emulador en la lista de dispositivos conectados.

3. Verificación del Backend (Prueba de Integración)
Para confirmar que la base de datos SQLite y el motor de cálculo de fechas funcionan correctamente:

Al abrir la app, presiona el botón "Ejecutar Prueba de BD".

Revisa la consola de depuración (Debug Console) o tu terminal.

Resultados Esperados (Logs de Éxito):
La consola debe imprimir la siguiente secuencia, validando que la Dosis 2 se agendó automáticamente calculando los días correctos:

Plaintext
I/flutter ( 8406): --- INICIANDO PRUEBA DE BD ---
I/flutter ( 8406): Vacuna insertada con ID: 2
I/flutter ( 8406): Paciente insertado con ID: 2
I/flutter ( 8406): Cita inicial creada con ID: 2
I/flutter ( 8406): --- NUEVA CITA GENERADA ---
I/flutter ( 8406): Patient ID: 2
I/flutter ( 8406): Vaccine ID: 2
I/flutter ( 8406): Dosis: 2
I/flutter ( 8406): Status: scheduled
I/flutter ( 8406): Next Dose Date: 2026-04-12
I/flutter ( 8406): --- PRUEBA FINALIZADA ---

## Roadmap

- [x] Capa de datos (Database, Modelos, Repositorios)
- [x] Patrón Repository
- [ ] UI - Dashboard
- [ ] UI - Formularios (Pacientes, Citas, Vacunas)
- [ ] Seguridad - Exportar archivo .db

---

## Historial de Prompts

1. **Crear database_helper.dart** - Implementar patrón Singleton con SQLite, activar Foreign Keys, crear 4 tablas con esquema específico.

2. **Crear modelos de datos** - Generar 4 archivos: patient.dart, vaccine.dart, vaccine_schedule.dart, appointment.dart con toMap/fromMap.

3. **Crear patient_repository.dart** - CRUD para pacientes con búsqueda por nombre.

4. **Crear appointment_repository.dart** - Lógica de citas con verificación de batch (10 máx) y método completeAppointment que genera siguiente dosis automáticamente.

5. **Crear repositories restantes** - vaccine_repository.dart y vaccine_schedule_repository.dart.

6. **Crear main.dart de prueba** - Script de integración que prueba todo el flujo de citas y vacunas.

7. **Actualizar README.md** - Documentación de estructura y resumen del proyecto.
