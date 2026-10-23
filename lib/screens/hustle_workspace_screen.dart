import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/fluid_neon_capsule_bar.dart';

class HustleWorkspaceScreen extends StatefulWidget {
  const HustleWorkspaceScreen({super.key});

  @override
  State<HustleWorkspaceScreen> createState() => _HustleWorkspaceScreenState();
}

class _HustleWorkspaceScreenState extends State<HustleWorkspaceScreen> {
  int userWallet = 850;
  int userEnergy = 75;

  // Active Job State Management Fields
  String? _activeJobId;
  int _secondsRemaining = 0;
  Timer? _jobTimer;
  double _progressFraction = 0.0;

  // Static Jobs Dictionary List Blueprint
  final List<Map<String, dynamic>> _availableJobs = [
    {
      "id": "dj",
      "title": "🎛️ Club DJ Shift",
      "energy": 20,
      "reward": 60,
      "duration": 15,
    },
    {
      "id": "tech",
      "title": "🏢 Remote Tech Contract",
      "energy": 40,
      "reward": 180,
      "duration": 45,
    },
    {
      "id": "taxi",
      "title": "🚖 Ride-Hailing Hustle",
      "energy": 15,
      "reward": 45,
      "duration": 10,
    },
  ];

  void _startHustle(Map<String, dynamic> job) {
    if (_activeJobId != null) return; // Prevent concurrent multiple job handling
    if (userEnergy < (job['energy'] as int)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Not enough energy! Eat food or rest to recharge.",
          ),
        ),
      );
      return;
    }

    setState(() {
      _activeJobId = job['id'];
      userEnergy -= job['energy'] as int;
      _secondsRemaining = job['duration'] as int;
      _progressFraction = 1.0;
    });

    final totalDuration = job['duration'] as int;

    _jobTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsRemaining--;
        _progressFraction = _secondsRemaining / totalDuration;

        if (_secondsRemaining <= 0) {
          _jobTimer?.cancel();
          userWallet += job['reward'] as int;
          _activeJobId = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.greenAccent,
              content: Text(
                "Job Complete! Earned +${job['reward']} Coins 🪙",
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _jobTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16162A),
        elevation: 0,
        title: const Text(
          "City Jobs & Work",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          _buildTopResourceChip("🪙 $userWallet Coins", Colors.cyanAccent),
          _buildTopResourceChip("⚡ $userEnergy Energy", Colors.orangeAccent),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "AVAILABLE JOBS",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),

            // Loop iterating over the jobs ledger dictionary map cards
            Expanded(
              child: ListView.builder(
                itemCount: _availableJobs.length,
                itemBuilder: (context, index) {
                  final job = _availableJobs[index];
                  final bool isCurrentJob = _activeJobId == job['id'];
                  final bool processingAnyJob = _activeJobId != null;

                  return Card(
                    color: const Color(0xFF16162A),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Uses: ${job['energy']} Energy ⚡  |  Earns: +${job['reward']} Coins 🪙",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isCurrentJob
                                      ? Colors.orange
                                      : (processingAnyJob
                                          ? Colors.grey
                                          : const Color(0xFF6C63FF)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: processingAnyJob
                                    ? null
                                    : () => _startHustle(job),
                                child: Text(
                                  isCurrentJob ? "${_secondsRemaining}s" : "START",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (isCurrentJob) ...[
                            const SizedBox(height: 12),
                            FluidNeonCapsuleBar(
                              progress: 1.0 - _progressFraction,
                              height: 24,
                              label: "⚡ Siphon in Progress • ${_secondsRemaining}s remaining",
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopResourceChip(String label, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF252545),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
