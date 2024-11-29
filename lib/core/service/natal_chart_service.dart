import 'package:sweph/sweph.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class NatalChartService {
  static bool _isInitialized = false;
  static Future<void> _initializeSweph() async {
    if (!_isInitialized) {
      try {
        final tempDir = await getTemporaryDirectory();
        final ephePath = '${tempDir.path}/ephe';

        if (!await Directory(ephePath).exists()) {
          await Directory(ephePath).create(recursive: true);
        }

        Sweph.swe_set_ephe_path(ephePath);
        _isInitialized = true;
      } catch (e) {
        print('Sweph initialization error: $e');
        _isInitialized = false;
        rethrow;
      }
    }
  }

  static Future<String> getEphePath() async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/ephe';
  }

  static Future<Map<String, dynamic>> calculateNatalChart(
      DateTime birthDate, String birthTime, String birthPlace) async {
    // Her hesaplama öncesi initialize kontrolü
    await _initializeSweph();

    if (!_isInitialized) {
      throw Exception('Sweph initialization failed');
    }

    try {
      final ephePath = await getEphePath();
      Sweph.swe_set_ephe_path(ephePath);

      // Koordinat bilgilerini alacak bir servis gerekli
      final coordinates = await _getCoordinates(birthPlace);

      final julianDay = Sweph.swe_julday(birthDate.year, birthDate.month,
          birthDate.day, _parseTime(birthTime), CalendarType.SE_GREG_CAL);

      // Gezegen konumlarını hesapla
      final planets = {
        'Sun': _calculatePlanetPosition(julianDay, HeavenlyBody.SE_SUN),
        'Moon': _calculatePlanetPosition(julianDay, HeavenlyBody.SE_MOON),
        'Mercury': _calculatePlanetPosition(julianDay, HeavenlyBody.SE_MERCURY),
        'Venus': _calculatePlanetPosition(julianDay, HeavenlyBody.SE_VENUS),
        'Mars': _calculatePlanetPosition(julianDay, HeavenlyBody.SE_MARS),
        'Jupiter': _calculatePlanetPosition(julianDay, HeavenlyBody.SE_JUPITER),
        'Saturn': _calculatePlanetPosition(julianDay, HeavenlyBody.SE_SATURN),
        'Uranus': _calculatePlanetPosition(julianDay, HeavenlyBody.SE_URANUS),
        'Neptune': _calculatePlanetPosition(julianDay, HeavenlyBody.SE_NEPTUNE),
        'Pluto': _calculatePlanetPosition(julianDay, HeavenlyBody.SE_PLUTO),
      };

      // Yükselen ve ev hesaplamaları
      final ascendant = _calculateAscendant(julianDay, coordinates);

      return {
        'planets': planets,
        'ascendant': ascendant,
        'birthDetails': {
          'date': birthDate,
          'time': birthTime,
          'place': birthPlace
        }
      };
    } catch (e) {
      print('Natal chart calculation error: $e');
      rethrow;
    }
  }

  static double _parseTime(String timeString) {
    final parts = timeString.split(':');
    return double.parse(parts[0]) + (double.parse(parts[1]) / 60);
  }

  static Map<String, dynamic> _calculatePlanetPosition(
      double julianDay, HeavenlyBody planet) {
    final result = Sweph.swe_calc_ut(julianDay, planet, SwephFlag.SEFLG_SWIEPH);

    return {
      'longitude': result.longitude,
      'latitude': result.latitude,
      'sign': _getZodiacSign(result.longitude),
      'house': _calculateHouse(result.longitude)
    };
  }

  static String _getZodiacSign(double longitude) {
    final signs = [
      'Aries',
      'Taurus',
      'Gemini',
      'Cancer',
      'Leo',
      'Virgo',
      'Libra',
      'Scorpio',
      'Sagittarius',
      'Capricorn',
      'Aquarius',
      'Pisces'
    ];
    return signs[(longitude / 30).floor()];
  }

  static int _calculateHouse(double longitude) {
    // Basit ev hesaplaması
    return (longitude / 30).floor() + 1;
  }

  static Future<Map<String, double>> _getCoordinates(String birthPlace) async {
    // Gerçek koordinat servisi gerekli
    // Örnek mock data
    return {'latitude': 41.0082, 'longitude': 28.9784};
  }

  static double _calculateAscendant(
      double julianDay, Map<String, double> coordinates) {
    final houses = Sweph.swe_houses(
        julianDay, coordinates['latitude']!, coordinates['longitude']!, Hsys.P);
    return houses.ascmc[0];
  }
}
