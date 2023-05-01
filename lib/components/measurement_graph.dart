import 'dart:collection';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class _LineChart extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _LineChartState();
  }

}

class _LineChartState extends State<_LineChart> {
  static const _recordsCount = 50;
  var _displayMode = DisplayModes.day;

  @override
  Widget build(BuildContext context) {
    const _pulseColor = Colors.red;
    const _diaColor = Colors.green;
    const _sysColor = Colors.teal;


    return Consumer<BloodPressureModel>(
      builder: (context, model, child) {
        late final _dataFuture;
        DateTime now = DateTime.now();
        switch (_displayMode) {
          case DisplayModes.day:
            _dataFuture = model.getInTimeRange(DateTime(now.year, now.month, now.day), now);
            break;
          case DisplayModes.month:
            _dataFuture = model.getInTimeRange(DateTime(now.year, now.month), now);
            break;
          case DisplayModes.year:
            _dataFuture = model.getInTimeRange(DateTime(now.year), now);
            break;
          case DisplayModes.lifetime:
            _dataFuture = model.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(0), now);
            break;
        }


        return FutureBuilder<UnmodifiableListView<BloodPressureRecord>>(
          future: _dataFuture,
          builder: (BuildContext context, AsyncSnapshot<UnmodifiableListView<BloodPressureRecord>> snapshot) {
            Widget res;
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                res = const Text('not started');
                break;
              case ConnectionState.waiting:
                res = const Text('loading...');
                break;
              default:
                if (snapshot.hasError) {
                  res = Text('ERROR: ${snapshot.error}');
                } else {
                  assert(snapshot.hasData);
                  final data = snapshot.data ?? [];

                  List<FlSpot> pulseSpots = [];
                  List<FlSpot> diastolicSpots = [];
                  List<FlSpot> systolicSpots = [];
                  int pulMax = 0;
                  int diaMax = 0;
                  int sysMax = 0;
                  for (var element in data) {
                    final x = element.creationTime.millisecondsSinceEpoch.toDouble();
                    diastolicSpots.add(FlSpot(x, element.diastolic.toDouble()));
                    systolicSpots.add(FlSpot(x, element.systolic.toDouble()));
                    pulseSpots.add(FlSpot(x, element.pulse.toDouble()));
                    pulMax = max(pulMax, element.pulse);
                    diaMax = max(diaMax, element.diastolic);
                    sysMax = max(sysMax, element.systolic);
                  }


                  final noTitels = AxisTitles(sideTitles: SideTitles(reservedSize: 40, showTitles: false));
                  res = LineChart(
                      swapAnimationDuration: const Duration(milliseconds: 250),
                      LineChartData(
                          minY: 30,
                          maxY: max(pulMax.toDouble(), max(diaMax.toDouble(), sysMax.toDouble())) + 5,
                          titlesData: FlTitlesData(topTitles: noTitels, rightTitles:  noTitels,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double pos, TitleMeta meta) {
                                      late final DateFormat formater;
                                      switch (_displayMode) {
                                        case DisplayModes.day:
                                          formater = DateFormat('H:mm');
                                          break;
                                        case DisplayModes.month:
                                          formater = DateFormat('d');
                                          break;
                                        case DisplayModes.year:
                                          formater = DateFormat('MMM');
                                          break;
                                        case DisplayModes.lifetime:
                                          formater = DateFormat('yyyy');
                                      }
                                      return Text(
                                          formater.format(DateTime.fromMillisecondsSinceEpoch(pos.toInt()))
                                      );
                                    }
                                ),
                              )
                          ),
                          lineBarsData: [
                            // high blood pressure marking acordning to https://www.texasheart.org/heart-health/heart-information-center/topics/high-blood-pressure-hypertension/
                            LineChartBarData(
                                spots: pulseSpots,
                                color: _pulseColor,
                                barWidth: 4,
                                isCurved: true,
                                preventCurveOverShooting: true
                            ),
                            LineChartBarData(
                                spots: diastolicSpots,
                                color: _diaColor,
                                barWidth: 4,
                                isCurved: true,
                                preventCurveOverShooting: true,
                                belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.red.shade400.withAlpha(100),
                                    cutOffY: 80,
                                    applyCutOffY: true
                                )
                            ),
                            LineChartBarData(
                                spots: systolicSpots,
                                color: _sysColor,
                                barWidth: 4,
                                isCurved: true,
                                preventCurveOverShooting: true,
                                belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.red.shade400.withAlpha(100),
                                    cutOffY: 130,
                                    applyCutOffY: true
                                )
                            )
                          ]
                      )
                  );
                }
            }
            return res;
          }
      );
      },
    );
  }

}

class DisplayModes {
  static const day = 0;
  static const month = 1;
  static const year = 2;
  static const lifetime = 3;
}

class MeasurementGraph extends StatelessWidget {
  const MeasurementGraph({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, left: 6),
        child: _LineChart(),
      ),
    );
  }
}