import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/weather_data.dart';
import 'package:intl/intl.dart';

class WeatherForecastList extends StatelessWidget {
  final List<WeatherData> forecast;

  const WeatherForecastList({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    // Group forecast by day
    Map<String, List<WeatherData>> groupedForecast = {};

    for (var weather in forecast) {
      String dateKey = DateFormat('yyyy-MM-dd').format(weather.recordedAt);
      if (groupedForecast[dateKey] == null) {
        groupedForecast[dateKey] = [];
      }
      groupedForecast[dateKey]!.add(weather);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: groupedForecast.keys.length,
      itemBuilder: (context, index) {
        String dateKey = groupedForecast.keys.elementAt(index);
        List<WeatherData> dayForecast = groupedForecast[dateKey]!;
        DateTime date = DateTime.parse(dateKey);

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Date Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Text(
                  DateFormat('EEEE, MMM dd').format(date),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),

              // Hourly Forecast
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  itemCount: dayForecast.length,
                  itemBuilder: (context, hourIndex) {
                    final hourlyWeather = dayForecast[hourIndex];
                    return Container(
                      width: 80,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            DateFormat(
                              'HH:mm',
                            ).format(hourlyWeather.recordedAt),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            hourlyWeather.conditionIcon,
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            hourlyWeather.temperatureDisplay,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          if (hourlyWeather.rainfall != null &&
                              hourlyWeather.rainfall! > 0)
                            Text(
                              hourlyWeather.rainfallDisplay,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.blue[600],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Daily Summary
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'High',
                      _getMaxTemperature(dayForecast),
                      Icons.keyboard_arrow_up,
                      Colors.red[500]!,
                    ),
                    _buildSummaryItem(
                      'Low',
                      _getMinTemperature(dayForecast),
                      Icons.keyboard_arrow_down,
                      Colors.blue[500]!,
                    ),
                    _buildSummaryItem(
                      'Rain',
                      _getTotalRainfall(dayForecast),
                      Icons.umbrella,
                      Colors.blue[600]!,
                    ),
                    _buildSummaryItem(
                      'Wind',
                      _getAverageWindSpeed(dayForecast),
                      Icons.air,
                      Colors.grey[600]!,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
      ],
    );
  }

  String _getMaxTemperature(List<WeatherData> dayForecast) {
    double max = dayForecast
        .map((w) => w.temperature ?? 0.0)
        .reduce((a, b) => a > b ? a : b);
    return '${max.toStringAsFixed(1)}°C';
  }

  String _getMinTemperature(List<WeatherData> dayForecast) {
    double min = dayForecast
        .map((w) => w.temperature ?? 0.0)
        .reduce((a, b) => a < b ? a : b);
    return '${min.toStringAsFixed(1)}°C';
  }

  String _getTotalRainfall(List<WeatherData> dayForecast) {
    double total = dayForecast
        .map((w) => w.rainfall ?? 0.0)
        .reduce((a, b) => a + b);
    return '${total.toStringAsFixed(1)}mm';
  }

  String _getAverageWindSpeed(List<WeatherData> dayForecast) {
    double average =
        dayForecast.map((w) => w.windSpeed ?? 0.0).reduce((a, b) => a + b) /
        dayForecast.length;
    return '${average.toStringAsFixed(1)} km/h';
  }
}
