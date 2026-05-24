import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../core/data/seed_data.dart';
import '../../models/app_models.dart';
import '../../widgets/scene_link_widgets.dart';
import '../projects/project_detail_screen.dart';

/// Birmingham city centre (default map centre)
const _defaultCenter = LatLng(52.4862, -1.8904);
const _defaultZoom = 13.0;

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  bool _loadingLocation = false;
  MapLocation? _selectedLocation;
  String _activeFilter = 'all'; // all | studio | park | venue | hub | project
  double _currentZoom = _defaultZoom;

  final List<MapLocation> _locations = SeedData.mapLocations();

  List<MapLocation> get _filtered =>
      _activeFilter == 'all' ? _locations : _locations.where((l) => l.type == _activeFilter).toList();

  List<_MapCluster> get _clusters => _buildClusters(_filtered, _currentZoom);

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _goToMyLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied. Enable it in Settings.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() => _userLocation = latLng);
      _mapController.move(latLng, 14);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get your location.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Color _markerColor(String type) {
    return switch (type) {
      'studio' => const Color(0xFF6D3FDA),
      'park' => Colors.green,
      'venue' => Colors.orange,
      'hub' => const Color(0xFF35B0AB),
      'project' => Colors.red,
      _ => Colors.grey,
    };
  }

  IconData _markerIcon(String type) {
    return switch (type) {
      'studio' => Icons.videocam_rounded,
      'park' => Icons.park_rounded,
      'venue' => Icons.theater_comedy_rounded,
      'hub' => Icons.hub_rounded,
      'project' => Icons.folder_copy_rounded,
      _ => Icons.location_on_rounded,
    };
  }

  List<_MapCluster> _buildClusters(List<MapLocation> locations, double zoom) {
    final gridSize = zoom < 11
        ? 0.06
        : zoom < 12.5
            ? 0.03
            : 0.015;

    final buckets = <String, List<MapLocation>>{};
    for (final location in locations) {
      final latBucket = (location.latitude / gridSize).floor();
      final lngBucket = (location.longitude / gridSize).floor();
      final key = '$latBucket:$lngBucket';
      buckets.putIfAbsent(key, () => []).add(location);
    }

    return buckets.values.map((group) => _MapCluster(group)).toList();
  }

  CreativeProject? _linkedProject(MapLocation location) {
    final locationName = location.name.toLowerCase();
    for (final project in SeedData.projects()) {
      final projectName = project.title.toLowerCase();
      if (locationName.contains(projectName) || projectName.contains(locationName)) {
        return project;
      }
    }
    return null;
  }

  double _distanceKm(MapLocation location) {
    final origin = _userLocation ?? _defaultCenter;
    return Geolocator.distanceBetween(
          origin.latitude,
          origin.longitude,
          location.latitude,
          location.longitude,
        ) /
        1000;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Creative Map',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (_loadingLocation)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            IconButton(
              tooltip: 'My location',
              icon: const Icon(Icons.my_location_rounded),
              onPressed: _goToMyLocation,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: SceneCard(
              color: scheme.primaryContainer.withValues(alpha: 0.35),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.explore_rounded, color: scheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Discover creative hubs', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('Studios, collaborators and active briefs near Birmingham.', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
                      ],
                    ),
                  ),
                  SceneTag(label: '${_filtered.length} spots', filled: true),
                ],
              ),
            ),
          ),

          // ── Filter chips ─────────────────────────────────────────────
          Container(
            color: scheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final filter in ['all', 'studio', 'park', 'venue', 'hub', 'project'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter == 'all' ? '🗺️ All' : _filterLabel(filter)),
                        selected: _activeFilter == filter,
                        onSelected: (_) => setState(() {
                          _activeFilter = filter;
                          _selectedLocation = null;
                        }),
                        selectedColor: scheme.primaryContainer,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: _activeFilter == filter
                              ? scheme.onPrimaryContainer
                              : scheme.onSurfaceVariant,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        side: BorderSide(color: scheme.outlineVariant),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Map ──────────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _defaultCenter,
                    initialZoom: _defaultZoom,
                    minZoom: 8,
                    maxZoom: 18,
                    onPositionChanged: (camera, hasGesture) {
                      final zoom = camera.zoom;
                      if (zoom != _currentZoom && mounted) {
                        setState(() => _currentZoom = zoom);
                      }
                    },
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    // Tile layer (OpenStreetMap — free, no API key)
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.screenlink.app',
                    ),

                    // Creative location markers
                    MarkerLayer(
                      markers: [
                        // User location
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            width: 36,
                            height: 36,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 8)
                                ],
                              ),
                            ),
                          ),

                        // Creative location clusters and markers
                        ..._clusters.map((cluster) {
                          final location = cluster.items.first;
                          if (cluster.items.length == 1) {
                            return Marker(
                              point: LatLng(location.latitude, location.longitude),
                              width: 44,
                              height: 44,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedLocation = location),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: _markerColor(location.type),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _selectedLocation?.id == location.id
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _markerColor(location.type).withValues(alpha: 0.28),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _markerIcon(location.type),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            );
                          }

                          return Marker(
                            point: cluster.center,
                            width: 52,
                            height: 52,
                            child: GestureDetector(
                              onTap: () {
                                _mapController.move(cluster.center, (_currentZoom + 1.5).clamp(8, 18));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: scheme.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: scheme.primary, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: scheme.primary.withValues(alpha: 0.18),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${cluster.items.length}',
                                  style: TextStyle(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),

                // ── Info panel for selected location ─────────────────
                if (_selectedLocation != null)
                  Positioned(
                    bottom: 24,
                    left: 16,
                    right: 16,
                    child: _LocationInfoCard(
                      location: _selectedLocation!,
                      distanceKm: _distanceKm(_selectedLocation!),
                      markerColor: _markerColor(_selectedLocation!.type),
                      markerIcon: _markerIcon(_selectedLocation!.type),
                      linkedProject: _linkedProject(_selectedLocation!),
                      onCenterMap: () => _mapController.move(
                        LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude),
                        (_currentZoom + 0.5).clamp(8, 18),
                      ),
                      onClose: () => setState(() => _selectedLocation = null),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(String type) {
    return switch (type) {
      'studio' => '🎬 Studios',
      'park' => '🌳 Parks',
      'venue' => '🎭 Venues',
      'hub' => '🏢 Hubs',
      'project' => '📁 Projects',
      _ => type,
    };
  }
}

// ── Location info card ────────────────────────────────────────────────────────

class _LocationInfoCard extends StatelessWidget {
  const _LocationInfoCard({
    required this.location,
    required this.distanceKm,
    required this.markerColor,
    required this.markerIcon,
    required this.linkedProject,
    required this.onCenterMap,
    required this.onClose,
  });

  final MapLocation location;
  final double distanceKm;
  final Color markerColor;
  final IconData markerIcon;
  final CreativeProject? linkedProject;
  final VoidCallback onCenterMap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(24),
      shadowColor: Colors.black.withValues(alpha: 0.16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: markerColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(markerIcon, color: markerColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${distanceKm.toStringAsFixed(1)} km away',
                        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClose,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              location.description,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant, height: 1.35),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ScenePillButton(
                    label: 'Center map',
                    icon: Icons.my_location_rounded,
                    filled: false,
                    onPressed: onCenterMap,
                  ),
                ),
                if (linkedProject != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ScenePillButton(
                      label: 'Open brief',
                      icon: Icons.open_in_new_rounded,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: linkedProject!)),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCluster {
  _MapCluster(this.items)
      : center = LatLng(
          items.map((item) => item.latitude).reduce((a, b) => a + b) / items.length,
          items.map((item) => item.longitude).reduce((a, b) => a + b) / items.length,
        );

  final List<MapLocation> items;
  final LatLng center;
}
