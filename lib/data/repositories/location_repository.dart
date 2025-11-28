  // ----------------------------------------------
  // lib/data/repositories/location_repository.dart
  // ----------------------------------------------

  import 'package:geolocator/geolocator.dart';

  class LocationRepository {
    Future<Position> getCurrentPosition() async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Layanan lokasi dimatikan.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Izin lokasi ditolak.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Izin lokasi ditolak permanen, silakan aktifkan di pengaturan HP.');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    }
  }