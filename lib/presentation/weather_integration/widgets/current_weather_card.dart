import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../models/weather_data.dart';
import 'package:intl/intl.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherData weatherData;

  const CurrentWeatherCard({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(),
          ),
        ),
        child: Column(
          children: [
            // Main Weather Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weatherData.temperatureDisplay,
                      style: TextStyle(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    Text(
                      weatherData.conditionDisplay,
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.white.withAlpha(230),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    weatherData.conditionIcon,
                    style: TextStyle(fontSize: 48),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Weather Details
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Humidity',
                          weatherData.humidityDisplay,
                          Icons.water_drop,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'Wind Speed',
                          weatherData.windSpeedDisplay,
                          Icons.air,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Rainfall',
                          weatherData.rainfallDisplay,
                          Icons.umbrella,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'Location',
                          weatherData.location,
                          Icons.location_on,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Last Updated
            Text(
              'Updated: ${DateFormat('MMM dd, HH:mm').format(weatherData.recordedAt)}',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withAlpha(204),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.white.withAlpha(204)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Color> _getGradientColors() {
    switch (weatherData.condition) {
      case 'sunny':
        return [Colors.orange[400]!, Colors.yellow[600]!];
      case 'cloudy':
        return [Colors.grey[400]!, Colors.grey[600]!];
      case 'rainy':
        return [Colors.blue[400]!, Colors.blue[700]!];
      case 'stormy':
        return [Colors.purple[400]!, Colors.indigo[700]!];
      case 'foggy':
        return [Colors.blueGrey[300]!, Colors.blueGrey[600]!];
      default:
        return [Colors.blue[400]!, Colors.blue[700]!];
    }
  }
}
