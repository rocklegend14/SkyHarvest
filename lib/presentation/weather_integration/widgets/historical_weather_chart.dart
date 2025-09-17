import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/weather_data.dart';
import 'package:intl/intl.dart';

class HistoricalWeatherChart extends StatefulWidget {
  final List<WeatherData> historicalData;

  const HistoricalWeatherChart({super.key, required this.historicalData});

  @override
  State<HistoricalWeatherChart> createState() => _HistoricalWeatherChartState();
}

class _HistoricalWeatherChartState extends State<HistoricalWeatherChart> {
  String _selectedMetric = 'temperature';

  final Map<String, String> _metrics = {
    'temperature': 'Temperature (°C)',
    'humidity': 'Humidity (%)',
    'rainfall': 'Rainfall (mm)',
    'wind_speed': 'Wind Speed (km/h)',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metric Selector
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Metric',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _metrics.entries.map((entry) {
                          final isSelected = _selectedMetric == entry.key;
                          return FilterChip(
                            selected: isSelected,
                            label: Text(entry.value),
                            onSelected: (selected) {
                              setState(() => _selectedMetric = entry.key);
                            },
                            selectedColor: Colors.blue[100],
                            checkmarkColor: Colors.blue[700],
                            labelStyle: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.blue[700]
                                      : Colors.grey[700],
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Chart Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last 7 Days - ${_metrics[_selectedMetric]}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(height: 250, child: LineChart(_buildLineChart())),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Statistics Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Average',
                          _getAverage(),
                          Icons.trending_flat,
                          Colors.blue[600]!,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Maximum',
                          _getMaximum(),
                          Icons.trending_up,
                          Colors.red[600]!,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Minimum',
                          _getMinimum(),
                          Icons.trending_down,
                          Colors.green[600]!,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Total Days',
                          widget.historicalData.length.toString(),
                          Icons.calendar_today,
                          Colors.purple[600]!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChart() {
    final spots = <FlSpot>[];

    for (int i = 0; i < widget.historicalData.length; i++) {
      final weather = widget.historicalData[i];
      double value = 0.0;

      switch (_selectedMetric) {
        case 'temperature':
          value = weather.temperature ?? 0.0;
          break;
        case 'humidity':
          value = weather.humidity ?? 0.0;
          break;
        case 'rainfall':
          value = weather.rainfall ?? 0.0;
          break;
        case 'wind_speed':
          value = weather.windSpeed ?? 0.0;
          break;
      }

      spots.add(FlSpot(i.toDouble(), value));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: _getHorizontalInterval(),
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
        },
        getDrawingVerticalLine: (value) {
          return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              final index = value.toInt();
              if (index >= 0 && index < widget.historicalData.length) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    DateFormat(
                      'MM/dd',
                    ).format(widget.historicalData[index].recordedAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
                  ),
                );
              }
              return Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _getHorizontalInterval(),
            reservedSize: 42,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text(
                value.toStringAsFixed(0),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
                textAlign: TextAlign.left,
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      minX: 0,
      maxX: (widget.historicalData.length - 1).toDouble(),
      minY: _getMinY(),
      maxY: _getMaxY(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.blue[600]!],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.blue[600]!,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue[400]!.withAlpha(77),
                Colors.blue[600]!.withAlpha(26),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  double _getHorizontalInterval() {
    final values = _getValues();
    if (values.isEmpty) return 1.0;
    final range =
        values.reduce((a, b) => a > b ? a : b) -
        values.reduce((a, b) => a < b ? a : b);
    return range / 5;
  }

  double _getMinY() {
    final values = _getValues();
    if (values.isEmpty) return 0.0;
    final min = values.reduce((a, b) => a < b ? a : b);
    return min * 0.9;
  }

  double _getMaxY() {
    final values = _getValues();
    if (values.isEmpty) return 1.0;
    final max = values.reduce((a, b) => a > b ? a : b);
    return max * 1.1;
  }

  List<double> _getValues() {
    return widget.historicalData.map((weather) {
      switch (_selectedMetric) {
        case 'temperature':
          return weather.temperature ?? 0.0;
        case 'humidity':
          return weather.humidity ?? 0.0;
        case 'rainfall':
          return weather.rainfall ?? 0.0;
        case 'wind_speed':
          return weather.windSpeed ?? 0.0;
        default:
          return 0.0;
      }
    }).toList();
  }

  String _getAverage() {
    final values = _getValues();
    if (values.isEmpty) return '0';
    final average = values.reduce((a, b) => a + b) / values.length;
    return average.toStringAsFixed(1);
  }

  String _getMaximum() {
    final values = _getValues();
    if (values.isEmpty) return '0';
    final max = values.reduce((a, b) => a > b ? a : b);
    return max.toStringAsFixed(1);
  }

  String _getMinimum() {
    final values = _getValues();
    if (values.isEmpty) return '0';
    final min = values.reduce((a, b) => a < b ? a : b);
    return min.toStringAsFixed(1);
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
