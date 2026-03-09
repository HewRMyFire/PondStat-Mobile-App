import 'package:flutter/material.dart';

class MonitoringParameters {
  static const List<Map<String, dynamic>> daily = [
    {'label': 'Water Temperature', 'icon': Icons.thermostat_outlined, 'unit': '°C', 'keyboardType': TextInputType.number},
    {'label': 'Air Temperature', 'icon': Icons.air_outlined, 'unit': '°C', 'keyboardType': TextInputType.number},
    {'label': 'pH Level', 'icon': Icons.science_outlined, 'unit': '', 'keyboardType': TextInputType.number},
    {'label': 'Salinity', 'icon': Icons.waves_outlined, 'unit': 'ppm', 'keyboardType': TextInputType.number},
    {'label': 'Feeding Time', 'icon': Icons.local_dining_outlined, 'unit': 'kg', 'keyboardType': TextInputType.number},
  ];

  static const List<Map<String, dynamic>> weekly = [
    {'label': 'Microbe Count', 'icon': Icons.mic_outlined, 'unit': 'cells/ml', 'keyboardType': TextInputType.number},
    {'label': 'Phytoplankton Count', 'icon': Icons.nature_outlined, 'unit': 'cells/ml', 'keyboardType': TextInputType.number},
    {'label': 'Zooplankton Count', 'icon': Icons.pets_outlined, 'unit': 'ind/L', 'keyboardType': TextInputType.number},
    {'label': 'Avg Body Weight', 'icon': Icons.fitness_center_outlined, 'unit': 'g', 'keyboardType': TextInputType.number},
  ];

  static const List<Map<String, dynamic>> biweekly = [
    {'label': 'Dissolved O2', 'icon': Icons.opacity_outlined, 'unit': 'mg/L', 'keyboardType': TextInputType.number},
    {'label': 'Ammonia', 'icon': Icons.warning_outlined, 'unit': 'ppm', 'keyboardType': TextInputType.number},
    {'label': 'Nitrate', 'icon': Icons.water_drop_outlined, 'unit': 'ppm', 'keyboardType': TextInputType.number},
    {'label': 'Nitrite', 'icon': Icons.water_drop_outlined, 'unit': 'ppm', 'keyboardType': TextInputType.number},
    {'label': 'Alkalinity', 'icon': Icons.balance_outlined, 'unit': 'ppm', 'keyboardType': TextInputType.number},
    {'label': 'Phosphate', 'icon': Icons.data_usage_outlined, 'unit': 'ppm', 'keyboardType': TextInputType.number},
    {'label': 'Ca-Mg Ratio', 'icon': Icons.ac_unit_outlined, 'unit': 'ratio', 'keyboardType': TextInputType.text},
  ];

  static List<Map<String, dynamic>> getParametersByIndex(int index) {
    switch (index) {
      case 0:
        return daily;
      case 1:
        return weekly;
      case 2:
        return biweekly;
      default:
        return [];
    }
  }

  static String getTabTitle(int index) {
    switch (index) {
      case 0:
        return "Daily Monitoring";
      case 1:
        return "Weekly Analysis";
      case 2:
        return "Biweekly Report";
      default:
        return "";
    }
  }
}