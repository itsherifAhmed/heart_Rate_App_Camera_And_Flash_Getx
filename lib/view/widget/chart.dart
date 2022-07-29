import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import '../../model/sensor.dart';

class Chart extends StatelessWidget {
  final List<SensorValue> _data;

  const Chart(this._data);

  @override
  Widget build(BuildContext context) {
    return  charts.TimeSeriesChart([
      charts.Series<SensorValue, DateTime>(
        id: 'Values',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (SensorValue values, _) => values.time,
        measureFn: (SensorValue values, _) => values.value,
        data: _data,
      )
    ],
        animate: false,
        primaryMeasureAxis: const charts.NumericAxisSpec(
          tickProviderSpec:
          charts.BasicNumericTickProviderSpec(zeroBound: false),
          renderSpec: charts.NoneRenderSpec(),
        ),
        domainAxis: const charts.DateTimeAxisSpec(
            renderSpec:  charts.NoneRenderSpec()));
  }
}