import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import/legacy_column.dart';
import 'package:blood_pressure_app/model/export_import/record_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('ScriptedFormatter', () {
    test('should not throw errors', () async {
      final f = ScriptedFormatter(r'$SYS');
      
      expect(f.formatPattern, r'$SYS');
      f.encode(BloodPressureRecord(DateTime.now(), 123, 456, 789, 'test text'));
      f.encode(BloodPressureRecord(DateTime.now(), null, null, null, ''));
      f.decode('123');
    });
    test('should create correct strings', () {
      final testRecord = BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(31415926), 123, 45, 67, 'Test',
          needlePin: const MeasurementNeedlePin(Colors.red));

      expect(ScriptedFormatter(r'constant text',).encode(testRecord), 'constant text');
      expect(ScriptedFormatter(r'$SYS',).encode(testRecord), testRecord.systolic.toString());
      expect(ScriptedFormatter(r'$DIA',).encode(testRecord), testRecord.diastolic.toString());
      expect(ScriptedFormatter(r'$PUL',).encode(testRecord), testRecord.pulse.toString());
      expect(ScriptedFormatter(r'$COLOR',).encode(testRecord), testRecord.needlePin!.color.value.toString());
      expect(ScriptedFormatter(r'$NOTE',).encode(testRecord), testRecord.notes);
      expect(ScriptedFormatter(r'$TIMESTAMP',).encode(testRecord), testRecord.creationTime.millisecondsSinceEpoch.toString());
      expect(ScriptedFormatter(r'{{$SYS-$DIA}}',).encode(testRecord),
          (testRecord.systolic! - testRecord.diastolic!).toDouble().toString());
      expect(ScriptedFormatter(r'{{$SYS*$DIA-$PUL}}',).encode(testRecord),
          (testRecord.systolic! * testRecord.diastolic! - testRecord.pulse!).toDouble().toString());
      expect(ScriptedFormatter(r'$SYS-$DIA',).encode(testRecord), ('${testRecord.systolic}-${testRecord.diastolic}'));

      final formatter = DateFormat.yMMMMEEEEd();
      expect(ScriptedFormatter('\$FORMAT{\$TIMESTAMP,${formatter.pattern}}',).encode(testRecord),
          formatter.format(testRecord.creationTime));
    });
    test('should report correct reversibility', () {
      expect(ScriptedFormatter(r'$SYS',).restoreAbleType, RowDataFieldType.sys);
      expect(ScriptedFormatter(r'$DIA',).restoreAbleType, RowDataFieldType.dia);
      expect(ScriptedFormatter(r'$PUL',).restoreAbleType, RowDataFieldType.pul);
      expect(ScriptedFormatter(r'$TIMESTAMP',).restoreAbleType, RowDataFieldType.timestamp);
      expect(ScriptedFormatter(r'$NOTE',).restoreAbleType, RowDataFieldType.notes);
      expect(ScriptedFormatter(r'$COLOR',).restoreAbleType, RowDataFieldType.color);
      expect(ScriptedFormatter(r'test$SYS123',).restoreAbleType, RowDataFieldType.sys);
      expect(ScriptedFormatter(r'test$DIA123',).restoreAbleType, RowDataFieldType.dia);
      expect(ScriptedFormatter(r'test$PUL123',).restoreAbleType, RowDataFieldType.pul);

      //expect(ScriptedFormatter(r'$PUL$SYS',).isReversible, false);
      expect(ScriptedFormatter(r'test$NOTE',).restoreAbleType, null);
      expect(ScriptedFormatter(r'test$NOTE123',).restoreAbleType, null);
      expect(ScriptedFormatter(r'{{$PUL-$SYS}}',).restoreAbleType, null);
    });
    test('should correctly decode reversible patterns', () {
      expect(ScriptedFormatter(r'$SYS',).decode('123'), (RowDataFieldType.sys, 123));
      expect(ScriptedFormatter(r'$DIA',).decode('456'), (RowDataFieldType.dia, 456));
      expect(ScriptedFormatter(r'$PUL',).decode('789'), (RowDataFieldType.pul, 789));
      expect(ScriptedFormatter(r'$TIMESTAMP',).decode('12345678'), (RowDataFieldType.timestamp, DateTime.fromMillisecondsSinceEpoch(12345678)));
      expect(ScriptedFormatter(r'$NOTE',).decode('test note'), (RowDataFieldType.notes, 'test note'));
      final encodedPurple = ScriptedFormatter(r'$COLOR',)
          .encode(BloodPressureRecord(DateTime.now(), null, null, null, '',
          needlePin: const MeasurementNeedlePin(Colors.purple)));
      expect(ScriptedFormatter(r'$COLOR',).decode(encodedPurple)?.$1, RowDataFieldType.color);
      expect(ScriptedFormatter(r'$COLOR',).decode(encodedPurple)?.$2, isA<Color>()
          .having((p0) => p0.value, 'color', Colors.purple.value));
      expect(ScriptedFormatter(r'test$SYS',).decode('test567'), (RowDataFieldType.sys, 567));
      expect(ScriptedFormatter(r'test$SYS123',).decode('test567123'), (RowDataFieldType.sys, 567));
      expect(ScriptedFormatter(r'test$DIA123',).decode('test567123'), (RowDataFieldType.dia, 567));
      expect(ScriptedFormatter(r'test$PUL123',).decode('test567123'), (RowDataFieldType.pul, 567));
    });
  });
}