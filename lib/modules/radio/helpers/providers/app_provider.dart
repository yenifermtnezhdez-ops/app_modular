
import 'package:flutter/foundation.dart';
import '../../models/station_model.dart';
import '../../models/program_model.dart';
import '../../services/app_service.dart';

class AppProvider extends ChangeNotifier {
  List<StationModel> _stations = [];
  List<ProgramModel> _programs = [];

  bool _isLoading = false;

  List<StationModel> get stations => _stations;
  List<ProgramModel> get programs => _programs;
  bool get isLoading => _isLoading;

  void loadData() {
    _isLoading = true;
    notifyListeners();

    _stations = AppService.getStations();
    _programs = AppService.getPrograms();

    _isLoading = false;
    notifyListeners();
  }

  StationModel? getStationById(String id) {
    try {
      return _stations.firstWhere((station) => station.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ProgramModel> getProgramsByStation(String stationId) {
    return _programs
        .where((program) => program.stationId == stationId)
        .toList();
  }
}
