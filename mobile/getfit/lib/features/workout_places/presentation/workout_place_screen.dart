import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/state/session_controller.dart';
import '../data/workout_place_service.dart';
import '../domain/workout_place.dart';

class WorkoutPlaceScreen extends StatefulWidget {
  const WorkoutPlaceScreen({super.key});

  @override
  State<WorkoutPlaceScreen> createState() => _WorkoutPlaceScreenState();
}

class _WorkoutPlaceScreenState extends State<WorkoutPlaceScreen> {
  final WorkoutPlaceService _service = WorkoutPlaceService();

  bool _isLoading = true;
  WorkoutPlaceResult? _result;
  String? _mockCity;
  bool _closedExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPlaces());
  }

  Future<void> _loadPlaces() async {
    setState(() { _isLoading = true; _result = null; });

    final city = context.read<SessionController>().currentUser?.profile.city ?? 'Athens';
    _mockCity = city;

    final result = await _service.searchPlaces(city: city);
    if (!mounted) return;

    setState(() {
      _result = result;
      _isLoading = false;
    });

    if (result.open.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      _showNoPlacesDialog();
    }
  }

  void _showNoPlacesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.access_time_rounded, color: Colors.orange),
          SizedBox(width: 10),
          Text('All gyms are closed'),
        ]),
        content: Text(
          'There are no workout places open right now near ${_mockCity ?? 'your location'}.\n\nCheck back later or browse closed places below.',
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPlaceDetail(WorkoutPlace place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlaceDetailSheet(
        place: place,
        onDirections: () {
          Navigator.pop(context);
          _openDirections(place);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _openDirections(WorkoutPlace place) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}&travelmode=walking',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open directions.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        padding: const EdgeInsets.all(40),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.place_outlined, color: Color(0xFF2E7D32), size: 32),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Find a Workout Place', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5, height: 1.2)),
                Text('Nearby gyms and fitness centres open right now', style: TextStyle(fontSize: 14, color: Colors.black54)),
              ]),
            ),
          ]),
          const SizedBox(height: 20),

          if (_mockCity != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(children: [
                const Icon(Icons.location_on_rounded, color: Color(0xFF2E7D32), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'GPS mocked to $_mockCity based on your profile location · $timeStr',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32), fontWeight: FontWeight.w500),
                  ),
                ),
                TextButton(
                  onPressed: _loadPlaces,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                  child: const Text('Refresh', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ]),
            ),
          const SizedBox(height: 32),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Center(child: Column(children: [
                const CircularProgressIndicator(color: Color(0xFF2E7D32)),
                const SizedBox(height: 16),
                Text('Locating nearby workout places…', style: TextStyle(color: Colors.grey[600])),
              ])),
            )
          else if (_result != null) ...[
            Row(children: [
              const Text('Open Now', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(20)),
                child: Text('${_result!.open.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ]),
            const SizedBox(height: 16),

            if (_result!.open.isEmpty)
              _emptyCard(
                icon: Icons.access_time_rounded,
                title: 'No places open right now',
                subtitle: 'All nearby gyms are closed at this time. Check the list below for hours.',
                color: Colors.orange,
              )
            else
              ...(_result!.open.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _PlaceCard(place: p, isOpen: true, onTap: () => _showPlaceDetail(p)),
              ))),

            if (_result!.closed.isNotEmpty) ...[
              const SizedBox(height: 24),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _closedExpanded = !_closedExpanded),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(children: [
                    Icon(Icons.lock_clock_outlined, color: Colors.grey[500], size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Closed Now (${_result!.closed.length})',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                    ),
                    const Spacer(),
                    Icon(
                      _closedExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: Colors.grey[500],
                    ),
                  ]),
                ),
              ),
              if (_closedExpanded) ...[
                const SizedBox(height: 12),
                ...(_result!.closed.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PlaceCard(place: p, isOpen: false, onTap: () => _showPlaceDetail(p)),
                ))),
              ],
            ],
          ],
        ]),
      ),
    );
  }

  Widget _emptyCard({required IconData icon, required String title, required String subtitle, required Color color}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13), textAlign: TextAlign.center),
        ]),
      );
}


class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place, required this.isOpen, required this.onTap});
  final WorkoutPlace place;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isOpen ? const Color(0xFFA5D6A7) : Colors.grey[300]!;
    final bgColor = isOpen ? Colors.white : Colors.grey[50]!;

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
            border: Border.all(color: borderColor, width: isOpen ? 1.5 : 1),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(place.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isOpen ? Colors.black87 : Colors.grey[600])),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(child: Text(place.address, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
                ]),
              ])),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isOpen ? const Color(0xFFE8F5E9) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOpen ? '● Open' : '○ Closed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isOpen ? const Color(0xFF2E7D32) : Colors.grey[500],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(place.hoursLabel, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ]),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _badge(place.type, Icons.category_outlined, const Color(0xFF2E7D32)),
              _badge('★ ${place.rating}', Icons.star_rounded, Colors.orange),
              if (place.amenities.isNotEmpty)
                _badge(place.amenities.first, Icons.check_circle_outline, Colors.blue),
            ]),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Tap for details →', style: TextStyle(fontSize: 12, color: Colors.grey[400], fontStyle: FontStyle.italic)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _badge(String label, IconData icon, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    ]),
  );
}


class _PlaceDetailSheet extends StatelessWidget {
  const _PlaceDetailSheet({required this.place, required this.onDirections, required this.onCancel});
  final WorkoutPlace place;
  final VoidCallback onDirections;
  final VoidCallback onCancel; //flow 2 alter*

  @override
  Widget build(BuildContext context) {
    final isOpen = place.isOpenAt(DateTime.now().hour);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(margin: const EdgeInsets.only(top: 12, bottom: 8), width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
          Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.all(24), children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(place.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(place.type, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOpen ? const Color(0xFFE8F5E9) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOpen ? '● Open Now' : '○ Closed',
                  style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13,
                    color: isOpen ? const Color(0xFF2E7D32) : Colors.grey[600],
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            _infoTile(Icons.location_on_outlined, 'Address', place.address),
            _infoTile(Icons.access_time_rounded, 'Hours', place.hoursLabel),
            _infoTile(Icons.star_rounded, 'Rating', '${place.rating} / 5.0'),
            if (place.phone.isNotEmpty)
              _infoTile(Icons.phone_outlined, 'Phone', place.phone),

            if (place.description.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(place.description, style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14)),
            ],

            if (place.amenities.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Amenities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: place.amenities.map((a) =>
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_rounded, size: 14, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 6),
                    Text(a, style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600, fontSize: 13)),
                  ]),
                )
              ).toList()),
            ],

            const SizedBox(height: 32),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[400]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onCancel,
                  child: Text('Cancel', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onDirections,
                  icon: const Icon(Icons.directions_rounded),
                  label: const Text('Get Directions', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ])),
        ]),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ]),
    ]),
  );
}