
import 'dart:convert';
import 'dart:typed_data';

import 'package:blood_pressure_app/model/pdf_creator.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:csv/csv.dart';

import 'blood_pressure.dart';

class DataExporter {
  Settings settings;

  DataExporter(this.settings);

  Future<Uint8List> createFile(List<BloodPressureRecord> records) async {
    if (settings.exportFormat == ExportFormat.csv) {
      List<String> exportItems;
      if (settings.exportCustomEntries) {
        exportItems = settings.exportItems;
      } else {
        exportItems = ['timestampUnixMs', 'systolic', 'diastolic', 'pulse', 'notes'];
      }

      var csvHead = '';
      if (settings.exportCsvHeadline) {
        for (var i = 0; i<exportItems.length; i++) {
          csvHead += exportItems[i];
          if (i<(exportItems.length - 1)) {
            csvHead += settings.csvFieldDelimiter;
          }
        }
        csvHead += '\r\n';
      }

      List<List<dynamic>> items = [];
      for (var record in records) {
        List<dynamic> row = [];
        for (var attribute in exportItems) {
          switch (attribute) {
            case 'timestampUnixMs':
              row.add(record.creationTime.millisecondsSinceEpoch);
              break;
            case 'isoUTCTime':
              row.add(record.creationTime.toIso8601String());
              break;
            case 'systolic':
              row.add(record.systolic);
              break;
            case 'diastolic':
              row.add(record.diastolic);
              break;
            case 'pulse':
              row.add(record.pulse);
              break;
            case 'notes':
              row.add(record.notes);
              break;
          }
        }
        items.add(row);
      }
      var converter = ListToCsvConverter(fieldDelimiter: settings.csvFieldDelimiter, textDelimiter: settings.csvTextDelimiter);
      var csvData = converter.convert(items);
      return Uint8List.fromList(utf8.encode(csvHead + csvData));
    } else if (settings.exportFormat == ExportFormat.pdf) {
      return await PdfCreator().createPdf(records);
    }
    return Uint8List(0);
  }

  List<BloodPressureRecord> parseCSVFile(Uint8List data) {
    assert(settings.exportFormat == ExportFormat.csv);
    assert(settings.exportCsvHeadline);

    List<BloodPressureRecord> records = [];

    String fileContents = utf8.decode(data.toList());
    final converter = CsvToListConverter(fieldDelimiter: settings.csvFieldDelimiter, textDelimiter: settings.csvTextDelimiter);
    final csvLines = converter.convert(fileContents);
    final attributes = csvLines.removeAt(0);
    var creationTimePos = -1;
    var isoTimePos = -1;
    var sysPos = -1;
    var diaPos = -1;
    var pulPos = -1;
    var notePos = -1;
    for (var i = 0; i<attributes.length; i++) {
      switch (attributes[i]) {
        case 'timestampUnixMs':
          creationTimePos = i;
          break;
        case 'isoUTCTime':
          isoTimePos = i;
          break;
        case 'systolic':
          sysPos = i;
          break;
        case 'diastolic':
          diaPos = i;
          break;
        case 'pulse':
          pulPos = i;
          break;
        case 'notes':
          notePos = i;
          break;
      }
    }
    assert(creationTimePos >= 0 || isoTimePos >= 0);
    assert(sysPos >= 0);
    assert(diaPos >= 0);
    assert(pulPos >= 0);
    assert(notePos >= 0);

    for (final line in csvLines) {
      records.add(
          BloodPressureRecord(
              (creationTimePos >= 0 ) ? DateTime.fromMillisecondsSinceEpoch(line[creationTimePos]) : DateTime.parse(line[isoTimePos]),
              line[sysPos],
              line[diaPos],
              line[pulPos],
              line[notePos]
          )
      );
    }
    return records;
  }
}

enum ExportFormat {
  csv,
  pdf
}