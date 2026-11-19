import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/station_model.dart';
import '../models/program_model.dart';

class AppService {
  static const List<StationModel> stations = [
    StationModel(
      id: '1',
      name: 'Groove Salad',
      acronym: 'GSL',
      slogan: 'Un plato frío de beats ambientales',
      description: 'Un plato frío de beats ambientales',
      imageUrl: 'https://images.unsplash.com/photo-1516280440614-37939bbacd81',
      streamUrl: 'https://ice1.somafm.com/groovesalad-128-mp3',
      category: 'Ambient',
      frequency: 'GSL • ONLINE',
      websiteUrl: 'https://somafm.com/',
      xUrl: 'https://x.com/SomaFM',
      instagramUrl: 'https://www.instagram.com/somafm_official/',
    ),
    StationModel(
      id: '2',
      name: 'Secret Agent',
      acronym: 'SAG',
      slogan: 'La banda sonora para tu vida elegante',
      description: 'La banda sonora para tu vida elegante',
      imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f',
      streamUrl: 'https://ice1.somafm.com/secretagent-128-mp3',
      category: 'Lounge',
      frequency: 'SAG • ONLINE',
      websiteUrl: 'https://somafm.com/',
      xUrl: 'https://x.com/SomaFM',
      instagramUrl: 'https://www.instagram.com/somafm_official/',
    ),
    StationModel(
      id: '3',
      name: 'Indie Pop Rocks!',
      acronym: 'IPR',
      slogan: 'Canciones indie pop nuevas y clásicas',
      description: 'Canciones indie pop nuevas y clásicas',
      imageUrl: 'https://images.unsplash.com/photo-1511379938547-c1f69419868d',
      streamUrl: 'https://ice1.somafm.com/indiepop-128-mp3',
      category: 'Indie Pop',
      frequency: 'IPR • ONLINE',
      websiteUrl: 'https://somafm.com/',
      xUrl: 'https://x.com/SomaFM',
      instagramUrl: 'https://www.instagram.com/somafm_official/',
    ),
    StationModel(
      id: '4',
      name: 'Nightride FM',
      acronym: 'NRFM',
      slogan: 'Synthwave y Cyberpunk 24/7',
      description: 'Synthwave y Cyberpunk 24/7',
      imageUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
      streamUrl: 'https://stream.nightride.fm/nightride.mp3',
      category: 'Synthwave',
      frequency: 'NRFM • ONLINE',
      websiteUrl: 'https://nightride.fm/',
      xUrl: 'https://twitter.com/nightride__fm',
      instagramUrl: '',
    ),
  ];

  static List<StationModel> getStations() {
    return stations;
  }

  static Future<bool> launchExternalUrl(String? url) async {
    if (url == null || url.trim().isEmpty) {
      return false;
    }

    final cleanUrl = url.trim();
    final uri = Uri.tryParse(cleanUrl);

    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return false;
    }

    try {
      final canOpen = await canLaunchUrl(uri);

      if (!canOpen) {
        return false;
      }

      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error al abrir enlace externo: $e');
      return false;
    }
  }

  static List<ProgramModel> getPrograms() {
    return const [
      ProgramModel(
        id: '1',
        name: 'Ambient Chill',
        description:
            'Música ambiental sin interrupciones. Disfruta de '
            'sonidos relajantes, atmósferas envolventes y beats suaves.',
        imageUrl:
            'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
        stationId: '1',
        schedule: 'Todo el día',
        host: 'Groove Salad',
      ),
      ProgramModel(
        id: '2',
        name: 'Espionaje Sonoro',
        description:
            'Jazz instrumental, lounge retro y melodías '
            'misteriosas para acompañar tus momentos.',
        imageUrl:
            'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f',
        stationId: '2',
        schedule: 'Todo el día',
        host: 'Secret Agent',
      ),
      ProgramModel(
        id: '3',
        name: 'Indie Sessions',
        description:
            'Descubre novedades del rock alternativo, '
            'bandas independientes y sonidos diferentes.',
        imageUrl:
            'https://images.unsplash.com/photo-1511379938547-c1f69419868d',
        stationId: '3',
        schedule: 'Todo el día',
        host: 'Indie Pop Rocks!',
      ),
      ProgramModel(
        id: '4',
        name: 'Cyber Grid',
        description:
            'Lo-fi synthwave, ritmos electrónicos y sonidos '
            'cyberpunk para viajar a otra dimensión.',
        imageUrl:
            'https://images.unsplash.com/photo-1516280440614-37939bbacd81',
        stationId: '4',
        schedule: 'Todo el día',
        host: 'Nightride FM',
      ),
    ];
  }
}
