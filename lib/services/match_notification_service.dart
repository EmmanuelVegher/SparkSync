import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/match_alert_popup.dart';

class MatchNotificationService {
  SupabaseClient? _client;
  RealtimeChannel? _globalMatchChannel;

  MatchNotificationService() {
    try {
      _client = Supabase.instance.client;
    } catch (_) {
      _client = null;
    }
  }

  /// Starts listening to the real-time WebSocket channel for mutual matches
  void initializeMatchListener(
    BuildContext context, {
    void Function(Map<String, dynamic> matchData)? onOpenDm,
  }) {
    if (_client == null) return;
    final currentUser = _client!.auth.currentUser;
    if (currentUser == null) return;

    try {
      // Listen directly to changes on the matches table structure natively handled by Supabase Realtime
      _globalMatchChannel = _client!
          .channel('public:matches_alerts')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'matches',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'interaction_status',
              value: 'matched',
            ),
            callback: (payload) {
              final record = payload.newRecord;
              final String? userOneId =
                  record['user_one_id']?.toString() ??
                  record['user_one']?.toString();
              final String? userTwoId =
                  record['user_two_id']?.toString() ??
                  record['user_two']?.toString();

              // Only trigger popup if the current authenticated client user is part of this specific match
              if (currentUser.id == userOneId || currentUser.id == userTwoId) {
                if (context.mounted) {
                  _triggerMatchPopupOverlay(context, record, onOpenDm);
                }
              }
            },
          );

      _globalMatchChannel!.subscribe();
    } catch (e) {
      debugPrint("Match notification subscription error: $e");
    }
  }

  void _triggerMatchPopupOverlay(
    BuildContext context,
    Map<String, dynamic> data,
    void Function(Map<String, dynamic> matchData)? onOpenDm,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return MatchAlertPopup(
          matchData: data,
          onOpenDm: onOpenDm != null ? () => onOpenDm(data) : null,
        );
      },
    );
  }

  void dispose() {
    if (_globalMatchChannel != null && _client != null) {
      _client!.removeChannel(_globalMatchChannel!);
      _globalMatchChannel = null;
    }
  }
}
