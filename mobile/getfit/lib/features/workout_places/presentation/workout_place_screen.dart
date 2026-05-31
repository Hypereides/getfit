import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/workout_place_service.dart';
import '../domain/workout_place.dart';

enum _LoadState {
  initial,
  loading,
  locationServiceDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  loaded,
  error,
}

class WorkoutPlaceScreen extends StatefulWidget {
  const WorkoutPlaceScreen({super.key});

  @override
  State<WorkoutPlaceScreen> createState() => _WorkoutPlaceScreenState();
}

class _WorkoutPlaceScreenState extends State<WorkoutPlaceScreen> {
  final WorkoutPlaceService _service = WorkoutPlaceService();

  _LoadState _state = _LoadState.initial;
  WorkoutPlaceResult? _result;
  String? _errorMessage;
  bool _closedExpanded = false;
  bool _unknownExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPlaces());
  }

  Future<void> _loadPlaces() async {
    setState(() {
      _state = _LoadState.loading;
      _result = null;
      _errorMessage = null;
    });

    try {
      final result =
          await _service.getWorkoutPlacesWithinDistanceFromLocation();
      if (!mounted) return;

      setState(() {
        _result = result;
        _state = _LoadState.loaded;
      });

      if (result.open.isEmpty && result.unknownHours.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          _showNoPlacesDialog();
        }
      }
    } on LocationPermissionDeniedException catch (e) {
      if (mounted) {
        setState(() => _state = e.isPermanent
            ? _LoadState.permissionPermanentlyDenied
            : _LoadState.permissionDenied);
      }
    } on LocationServiceDisabledException {
      if (mounted) {
        setState(() => _state = _LoadState.locationServiceDisabled);
      }
    } on PlacesApiException catch (e) {
      if (mounted) {
        setState(() {
          _state = _LoadState.error;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _LoadState.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _showNoPlacesDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('No Places Open Now'),
        content: const Text(
          'There are no nearby workout places confirmed open right now.\n\n'
          'Try again later or browse the closed list below.',
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showWorkoutPlaceInfo(WorkoutPlace place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WorkoutPlaceInfoSheet(
        place: place,
        onDirections: () {
          Navigator.pop(context);
          openDirections(place);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> openDirections(WorkoutPlace place) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${place.latitude},${place.longitude}'
      '&travelmode=walking',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12))
          ],
        ),
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.place_outlined,
                    color: Color(0xFF2E7D32), size: 32),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Find a Workout Place',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5)),
                    Text('Powered by OpenStreetMap · no account needed',
                        style:
                            TextStyle(fontSize: 13, color: Colors.black45)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 32),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _LoadState.initial:
      case _LoadState.loading:
        return _loadingCard();

      case _LoadState.locationServiceDisabled:
        return _statusCard(
          icon: Icons.location_off_rounded,
          color: Colors.orange,
          title: 'Location Services Disabled',
          subtitle: 'Please enable Location Services in your device settings.',
          actionLabel: 'Open Settings',
          actionIcon: Icons.settings_rounded,
          onAction: () async {
            await Geolocator.openLocationSettings();
            _loadPlaces();
          },
        );

      case _LoadState.permissionDenied:
        return _statusCard(
          icon: Icons.location_disabled_rounded,
          color: Colors.orange,
          title: 'Location Permission Required',
          subtitle:
              'GetFit needs your location to find nearby workout places.',
          actionLabel: 'Retry',
          actionIcon: Icons.refresh_rounded,
          onAction: _loadPlaces,
        );

      case _LoadState.permissionPermanentlyDenied:
        return _statusCard(
          icon: Icons.lock_outline_rounded,
          color: Colors.red,
          title: 'Permission Permanently Denied',
          subtitle:
              'Open App Settings and grant location permission, then come back.',
          actionLabel: 'App Settings',
          actionIcon: Icons.settings_rounded,
          onAction: () async {
            await Geolocator.openAppSettings();
            _loadPlaces();
          },
        );

      case _LoadState.error:
        return _statusCard(
          icon: Icons.error_outline_rounded,
          color: Colors.red,
          title: 'Something Went Wrong',
          subtitle: _errorMessage ?? 'An unknown error occurred.',
          actionLabel: 'Retry',
          actionIcon: Icons.refresh_rounded,
          onAction: _loadPlaces,
        );

      case _LoadState.loaded:
        return _buildPlaceList();
    }
  }

  Widget _buildPlaceList() {
    final r = _result!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA5D6A7)),
        ),
        child: Row(children: [
          const Icon(Icons.my_location_rounded,
              color: Color(0xFF2E7D32), size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Using your current GPS location',
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: _loadPlaces,
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero, minimumSize: Size.zero),
            child: const Text('Refresh',
                style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
        ]),
      ),
      const SizedBox(height: 32),

      _sectionHeader('Open Now', r.open.length, const Color(0xFF2E7D32)),
      const SizedBox(height: 16),
      if (r.open.isEmpty)
        _emptyCard(Icons.access_time_rounded,
            'No places confirmed open right now.', Colors.orange)
      else
        ...r.open.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PlaceCard(
                  place: p,
                  isOpen: true,
                  onTap: () => _showWorkoutPlaceInfo(p)),
            )),

      if (r.unknownHours.isNotEmpty) ...[
        const SizedBox(height: 24),
        _expandable(
          label: '${r.unknownHours.length} '
              'place${r.unknownHours.length == 1 ? '' : 's'} '
              '— hours not listed',
          icon: Icons.help_outline_rounded,
          color: Colors.grey,
          expanded: _unknownExpanded,
          onTap: () => setState(() => _unknownExpanded = !_unknownExpanded),
        ),
        if (_unknownExpanded) ...[
          const SizedBox(height: 12),
          ...r.unknownHours.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PlaceCard(
                    place: p,
                    isOpen: null,
                    onTap: () => _showWorkoutPlaceInfo(p)),
              )),
        ],
      ],

      if (r.closed.isNotEmpty) ...[
        const SizedBox(height: 24),
        _expandable(
          label: 'Closed Now (${r.closed.length})',
          icon: Icons.lock_clock_outlined,
          color: Colors.grey,
          expanded: _closedExpanded,
          onTap: () => setState(() => _closedExpanded = !_closedExpanded),
        ),
        if (_closedExpanded) ...[
          const SizedBox(height: 12),
          ...r.closed.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PlaceCard(
                    place: p,
                    isOpen: false,
                    onTap: () => _showWorkoutPlaceInfo(p)),
              )),
        ],
      ],
    ]);
  }


  Widget _loadingCard() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: Column(children: [
            CircularProgressIndicator(color: Color(0xFF2E7D32)),
            SizedBox(height: 16),
            Text('Getting your location and searching nearby…',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54)),
          ]),
        ),
      );

  Widget _statusCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String actionLabel,
    required IconData actionIcon,
    required VoidCallback onAction,
  }) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          Icon(icon, size: 48, color: color),
          const SizedBox(height: 14),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.5)),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onAction,
            icon: Icon(actionIcon, size: 18),
            label: Text(actionLabel,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ]),
      );

  Widget _sectionHeader(String label, int count, Color color) =>
      Row(children: [
        Flexible(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 10),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(20)),
          child: Text('$count',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ),
      ]);

  Widget _expandable({
    required String label,
    required IconData icon,
    required Color color,
    required bool expanded,
    required VoidCallback onTap,
  }) =>
      InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis),
            ),
            Icon(
                expanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: Colors.grey[500]),
          ]),
        ),
      );

  Widget _emptyCard(IconData icon, String text, Color color) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
              child: Text(text,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14))),
        ]),
      );
}
class _PlaceCard extends StatelessWidget {
  const _PlaceCard(
      {required this.place, required this.isOpen, required this.onTap});

  final WorkoutPlace place;
  final bool? isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isOpen == true
        ? const Color(0xFFA5D6A7)
        : isOpen == false
            ? Colors.grey[300]!
            : Colors.blue.withValues(alpha: 0.3);
    final bgColor = isOpen == true ? Colors.white : Colors.grey[50]!;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: borderColor, width: isOpen == true ? 1.5 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isOpen == false
                              ? Colors.grey[600]
                              : Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (place.address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.location_on_outlined,
                            size: 13, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.address,
                            style:
                                TextStyle(fontSize: 13, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ],
                    const SizedBox(height: 8),
                    _typeBadge(),
                    const SizedBox(height: 6),
                    Text('Tap for details →',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _openBadge(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _openBadge() {
    final (label, bg, fg) = switch (isOpen) {
      true  => ('● Open',    const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      false => ('○ Closed',  Colors.grey.shade200,    Colors.grey.shade600),
      _     => ('? Unknown', Colors.blue.shade50,     Colors.blue.shade400),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _typeBadge() {
    const color = Color(0xFF2E7D32);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.category_outlined, size: 13, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(place.type,
              style: const TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 12),
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}

class _WorkoutPlaceInfoSheet extends StatelessWidget {
  const _WorkoutPlaceInfoSheet({
    required this.place,
    required this.onDirections,
    required this.onCancel,
  });

  final WorkoutPlace place;
  final VoidCallback onDirections;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(place.name,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(place.type,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _chip(),
                  ],
                ),
                const SizedBox(height: 20),

                if (place.address.isNotEmpty)
                  _row(Icons.location_on_outlined, 'Address', place.address),
                _row(Icons.schedule_outlined, 'Hours', place.availableHours),
                if (place.phoneNumber != null)
                  _row(Icons.phone_outlined, 'Phone', place.phoneNumber!),
                if (place.website != null)
                  _row(Icons.language_rounded, 'Website', place.website!),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(children: [
                    Icon(Icons.info_outline,
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Data © OpenStreetMap contributors (ODbL)',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[500]),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 28),

                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onCancel,
                      child: Text('Cancel',
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: onDirections,
                      icon: const Icon(Icons.directions_rounded),
                      label: const Text('Get Directions',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _chip() {
    final (label, bg, fg) = switch (place.isOpenNow) {
      true  => ('● Open Now', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      false => ('○ Closed',   Colors.grey.shade200,    Colors.grey.shade600),
      _     => ('? Unknown',  Colors.blue.shade50,     Colors.blue.shade400),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 13, color: fg)),
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ]),
      );
}