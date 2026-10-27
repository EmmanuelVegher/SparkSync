import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Supported Football Leagues
class FootballLeague {
  final String id;
  final String name;
  final String shortName;
  final String flag;

  const FootballLeague({
    required this.id,
    required this.name,
    required this.shortName,
    required this.flag,
  });
}

/// Live Football Fixtures Service
/// Pulls real-time matches from TheSportsDB free endpoint across major leagues
class FootballService {
  static final FootballService _instance = FootballService._internal();
  factory FootballService() => _instance;
  FootballService._internal();

  /// Top 6 World Leagues followed in Nigeria & globally
  static const List<FootballLeague> supportedLeagues = [
    FootballLeague(
      id: '4328',
      name: 'English Premier League',
      shortName: 'Premier League',
      flag: '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
    ),
    FootballLeague(
      id: '4480',
      name: 'UEFA Champions League',
      shortName: 'Champions League',
      flag: '🇪🇺',
    ),
    FootballLeague(
      id: '4335',
      name: 'Spanish La Liga',
      shortName: 'La Liga',
      flag: '🇪🇸',
    ),
    FootballLeague(
      id: '4332',
      name: 'Italian Serie A',
      shortName: 'Serie A',
      flag: '🇮🇹',
    ),
    FootballLeague(
      id: '4331',
      name: 'German Bundesliga',
      shortName: 'Bundesliga',
      flag: '🇩🇪',
    ),
    FootballLeague(
      id: '4334',
      name: 'French Ligue 1',
      shortName: 'Ligue 1',
      flag: '🇫🇷',
    ),
  ];

  final Map<String, MatchPredictionPool> _cachedPools = {};
  final Map<String, DateTime> _lastFetchTimes = {};

  /// Shorten club name for compact buttons on mobile
  static String getShortTeamName(String fullName) {
    final lower = fullName.toLowerCase();
    if (lower.contains('manchester united') || lower.contains('man utd')) return 'Man Utd';
    if (lower.contains('manchester city') || lower.contains('man city')) return 'Man City';
    if (lower.contains('paris saint-germain') || lower.contains('paris sg') || lower == 'psg') return 'PSG';
    if (lower.contains('wolverhampton') || lower.contains('wolves')) return 'Wolves';
    if (lower.contains('tottenham') || lower.contains('spurs')) return 'Spurs';
    if (lower.contains('borussia dortmund') || lower.contains('bvb')) return 'Dortmund';
    if (lower.contains('bayern')) return 'Bayern';
    if (lower.contains('leverkusen')) return 'Leverkusen';
    if (lower.contains('atletico madrid') || lower.contains('atlético')) return 'Atlético';
    if (lower.contains('athletic club') || lower.contains('athletic bilbao')) return 'Athletic';
    if (lower.contains('shakhtar')) return 'Shakhtar';
    if (lower.contains('sporting')) return 'Sporting';
    if (lower.contains('nottingham forest') || lower.contains('forest')) return 'Forest';
    if (lower.contains('crystal palace') || lower.contains('palace')) return 'Palace';
    if (lower.contains('brighton')) return 'Brighton';
    if (lower.contains('newcastle')) return 'Newcastle';
    if (lower.contains('aston villa')) return 'Villa';
    if (lower.contains('west ham')) return 'West Ham';
    if (lower.contains('bournemouth')) return 'Bournemouth';
    if (lower.contains('southampton')) return 'Southampton';
    if (lower.contains('leicester')) return 'Leicester';
    if (lower.contains('real madrid')) return 'Real Madrid';
    if (lower.contains('barcelona')) return 'Barcelona';
    if (lower.contains('juventus')) return 'Juventus';
    if (lower.contains('inter')) return 'Inter';
    if (lower.contains('milan')) return 'AC Milan';
    if (lower.contains('napoli')) return 'Napoli';
    if (lower.contains('marseille')) return 'Marseille';
    if (lower.contains('monaco')) return 'Monaco';
    if (lower.contains('sevilla')) return 'Sevilla';

    // If still long, shorten to first 10 chars
    if (fullName.length > 11) {
      return '${fullName.substring(0, 10)}.';
    }
    return fullName;
  }

  /// Map clubs across all major leagues to their visual badge emojis/colors
  String getClubEmoji(String teamName) {
    final lower = teamName.toLowerCase();
    // English Premier League
    if (lower.contains('arsenal')) return '🔴';
    if (lower.contains('chelsea')) return '🔵';
    if (lower.contains('manchester united') || lower.contains('man utd')) return '👹';
    if (lower.contains('manchester city') || lower.contains('man city')) return '🩵';
    if (lower.contains('liverpool')) return '🔴';
    if (lower.contains('tottenham') || lower.contains('spurs')) return '⚪';
    if (lower.contains('newcastle')) return '🏁';
    if (lower.contains('aston villa')) return '🦁';
    if (lower.contains('west ham')) return '⚒️';
    if (lower.contains('everton')) return '🔵';
    if (lower.contains('brighton')) return '🌊';
    if (lower.contains('wolves') || lower.contains('wolverhampton')) return '🐺';
    if (lower.contains('crystal palace')) return '🦅';
    if (lower.contains('fulham')) return '⚪';
    if (lower.contains('nottingham') || lower.contains('forest')) return '🌳';
    if (lower.contains('brentford')) return '🐝';
    if (lower.contains('bournemouth')) return '🍒';
    if (lower.contains('leicester')) return '🦊';
    if (lower.contains('southampton')) return '🔴';
    if (lower.contains('ipswich')) return '🚜';

    // Spanish La Liga
    if (lower.contains('real madrid')) return '⚪';
    if (lower.contains('barcelona')) return '🔵🔴';
    if (lower.contains('atletico') || lower.contains('atlético')) return '🔴⚪';
    if (lower.contains('sevilla')) return '⚪🔴';
    if (lower.contains('real betis') || lower.contains('betis')) return '🟢⚪';
    if (lower.contains('real sociedad')) return '🔵⚪';
    if (lower.contains('athletic')) return '🔴⚪';
    if (lower.contains('villarreal')) return '🟡';
    if (lower.contains('valencia')) return '🦇';
    if (lower.contains('girona')) return '🔴⚪';
    if (lower.contains('osasuna')) return '🔴';

    // Italian Serie A
    if (lower.contains('juventus')) return '⚪⚫';
    if (lower.contains('inter')) return '🔵⚫';
    if (lower.contains('milan')) return '🔴⚫';
    if (lower.contains('napoli')) return '🩵';
    if (lower.contains('roma')) return '🐺';
    if (lower.contains('lazio')) return '🦅';
    if (lower.contains('atalanta')) return '🔵⚫';
    if (lower.contains('fiorentina')) return '🟣';
    if (lower.contains('sassuolo')) return '🟢⚫';

    // German Bundesliga
    if (lower.contains('bayern')) return '🔴';
    if (lower.contains('dortmund') || lower.contains('bvb')) return '🟡⚫';
    if (lower.contains('leverkusen')) return '🔴⚫';
    if (lower.contains('leipzig')) return '⚪🔴';
    if (lower.contains('stuttgart')) return '⚪🔴';
    if (lower.contains('frankfurt')) return '🦅';
    if (lower.contains('wolfsburg')) return '🐺';
    if (lower.contains('mainz')) return '🔴⚪';

    // French Ligue 1
    if (lower.contains('paris') || lower.contains('psg')) return '🔵🔴';
    if (lower.contains('marseille')) return '⚪🩵';
    if (lower.contains('monaco')) return '🔴⚪';
    if (lower.contains('lyon')) return '🦁';
    if (lower.contains('lille')) return '🔴';
    if (lower.contains('rennes')) return '🔴⚫';

    // European Champions League
    if (lower.contains('sporting')) return '🟢⚪';
    if (lower.contains('benfica')) return '🔴🦅';
    if (lower.contains('porto')) return '🐉';
    if (lower.contains('shakhtar')) return '⚒️';
    if (lower.contains('ajax')) return '⚪🔴';
    if (lower.contains('celtic')) return '🟢⚪';
    if (lower.contains('rangers')) return '🔵';

    return '⚽';
  }

  /// Format UTC ISO string (e.g. 2026-10-31T12:30:00) into West Africa Time (WAT)
  String formatMatchTimeToWAT(String? isoDate, String? dateEvent, String? timeEvent) {
    try {
      DateTime? dt;
      if (isoDate != null && isoDate.isNotEmpty) {
        dt = DateTime.tryParse(isoDate);
      }
      if (dt == null && dateEvent != null) {
        final combined = timeEvent != null ? '$dateEvent $timeEvent' : dateEvent;
        dt = DateTime.tryParse(combined);
      }

      if (dt != null) {
        // West Africa Time (WAT) is UTC+1
        final wat = dt.toUtc().add(const Duration(hours: 1));
        final weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final dayName = weekdayNames[wat.weekday - 1];
        final hour = wat.hour.toString().padLeft(2, '0');
        final min = wat.minute.toString().padLeft(2, '0');
        return '$dayName • $hour:$min WAT';
      }
    } catch (_) {}
    return 'Super Matchday • 17:30 WAT';
  }

  /// Fetch the next live match for a given league (default Premier League: 4328)
  Future<MatchPredictionPool?> fetchNextLiveMatch({String leagueId = '4328'}) async {
    // Return memory cached pool if fetched within the last 15 minutes
    final cached = _cachedPools[leagueId];
    final lastFetch = _lastFetchTimes[leagueId];
    if (cached != null &&
        lastFetch != null &&
        DateTime.now().difference(lastFetch).inMinutes < 15) {
      return cached;
    }

    try {
      final endpoint = 'https://www.thesportsdb.com/api/v1/json/123/eventsnextleague.php?id=$leagueId';
      final response = await http
          .get(Uri.parse(endpoint))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final events = data['events'] as List<dynamic>?;

        if (events != null && events.isNotEmpty) {
          // Find marquee headliner match if available
          dynamic selectedMatch = events.first;

          for (final ev in events) {
            final name = (ev['strEvent'] ?? '').toString().toLowerCase();
            if ((name.contains('arsenal') && name.contains('chelsea')) ||
                (name.contains('chelsea') && name.contains('manchester')) ||
                (name.contains('liverpool') && name.contains('arsenal')) ||
                (name.contains('manchester') && name.contains('liverpool')) ||
                (name.contains('tottenham') && name.contains('arsenal')) ||
                (name.contains('madrid') && name.contains('barcelona')) ||
                (name.contains('bayern') && name.contains('dortmund')) ||
                (name.contains('inter') && name.contains('milan')) ||
                (name.contains('paris') && name.contains('lyon')) ||
                (name.contains('paris') && name.contains('marseille'))) {
              selectedMatch = ev;
              break;
            }
          }

          final homeTeam = (selectedMatch['strHomeTeam'] ?? 'Home Team').toString();
          final awayTeam = (selectedMatch['strAwayTeam'] ?? 'Away Team').toString();
          final idEvent = (selectedMatch['idEvent'] ?? 'match_$leagueId').toString();
          final leagueName = (selectedMatch['strLeague'] ?? _getLeagueNameById(leagueId)).toString();

          final timeWat = formatMatchTimeToWAT(
            selectedMatch['strTimestamp']?.toString(),
            selectedMatch['dateEvent']?.toString(),
            selectedMatch['strTime']?.toString(),
          );

          final pool = MatchPredictionPool(
            id: 'pool_$idEvent',
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            homeBadge: getClubEmoji(homeTeam),
            awayBadge: getClubEmoji(awayTeam),
            league: '$leagueName Matchday',
            matchTime: timeWat,
            totalPoolCredits: 520,
            entryCostCredits: 10,
            predictionsCount: {
              '1': 32, // Home
              'X': 9,  // Draw
              '2': 21, // Away
            },
            userPrediction: null,
          );

          _cachedPools[leagueId] = pool;
          _lastFetchTimes[leagueId] = DateTime.now();
          return pool;
        }
      }
    } catch (e) {
      debugPrint('[FootballService] Error pulling live matches for league $leagueId: $e');
    }
    return null;
  }

  /// Backwards compatible helper for Premier League
  Future<MatchPredictionPool?> fetchNextLivePremierLeagueMatch() {
    return fetchNextLiveMatch(leagueId: '4328');
  }

  String _getLeagueNameById(String id) {
    final league = supportedLeagues.firstWhere(
      (l) => l.id == id,
      orElse: () => supportedLeagues.first,
    );
    return league.name;
  }
}
