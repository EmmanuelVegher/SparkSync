class NigeriaLga {
  final String name;
  final List<String> areas;

  const NigeriaLga({
    required this.name,
    required this.areas,
  });
}

class NigeriaState {
  final String name;
  final String capitalCity;
  final List<NigeriaLga> lgas;

  const NigeriaState({
    required this.name,
    required this.capitalCity,
    required this.lgas,
  });
}

class OfflineLocationResult {
  final String state;
  final String lga;
  final String area;
  final String city;
  final String country;

  const OfflineLocationResult({
    required this.state,
    required this.lga,
    required this.area,
    required this.city,
    this.country = 'Nigeria',
  });
}

/// Comprehensive offline database of Nigerian States, LGAs, and Wards/Areas.
/// Designed for offline-first resilience: works without any cellular or internet connection.
final List<NigeriaState> nigeriaStates = [
  const NigeriaState(
    name: 'Niger State',
    capitalCity: 'Minna',
    lgas: [
      NigeriaLga(
        name: 'Chanchaga LGA',
        areas: [
          'Minna Central',
          'Minna GRA',
          'Tunga',
          'Sabon Gari',
          'Kpakungu',
          'Sauka Kahuta',
          'Chanchaga Bay',
          'Mobil Roundabout',
        ],
      ),
      NigeriaLga(
        name: 'Bosso LGA',
        areas: [
          'Bosso Estate',
          'Maikunkele',
          'FUT Minna (Gidan Kwano)',
          'FUT Minna (Bosso Campus)',
          'Western Bypass',
          'Garatu',
          'Shango',
        ],
      ),
      NigeriaLga(
        name: 'Suleja LGA',
        areas: [
          'Suleja Town',
          'Madalla',
          'Gauraka',
          'Zuma Rock Foothills',
          'Kwamba',
          'Maje',
          'Chaza',
        ],
      ),
      NigeriaLga(
        name: 'Bida LGA',
        areas: [
          'Bida Central',
          'Federal Poly Area',
          'Dokodza',
          'Wadata',
          'Kpege',
          'Etsu Palace Area',
        ],
      ),
      NigeriaLga(
        name: 'Shiroro LGA',
        areas: [
          'Kuta',
          'Shiroro Dam Corridor',
          'Zumba',
          'Gwada',
        ],
      ),
      NigeriaLga(
        name: 'Kontagora LGA',
        areas: [
          'Kontagora Town',
          'GRA',
          'Tudun Wada',
          'Federal College Area',
        ],
      ),
      NigeriaLga(
        name: 'Mokwa LGA',
        areas: ['Mokwa Town', 'Jebba North', 'Kudu'],
      ),
      NigeriaLga(
        name: 'Lapai LGA',
        areas: ['Lapai Town', 'IBBU Campus Area', 'Badeggi'],
      ),
      NigeriaLga(
        name: 'Borgu LGA',
        areas: ['New Bussa', 'Kainji Dam Lake', 'Wawa'],
      ),
    ],
  ),

  const NigeriaState(
    name: 'Federal Capital Territory (FCT)',
    capitalCity: 'Abuja',
    lgas: [
      NigeriaLga(
        name: 'Abuja Municipal (AMAC)',
        areas: [
          'Central Business District (CBD)',
          'Maitama',
          'Wuse II',
          'Wuse Zone 1-7',
          'Garki',
          'Asokoro',
          'Jabi Lake',
          'Utako',
          'Gwarinpa Estate',
          'Mabushi',
          'Guzape',
          'Apo District',
          'Lugbe',
          'Lokogoma',
        ],
      ),
      NigeriaLga(
        name: 'Bwari Area Council',
        areas: [
          'Bwari Town',
          'Kubwa',
          'Dutse',
          'Usuma Dam',
          'Mpape',
          'Dawaki',
        ],
      ),
      NigeriaLga(
        name: 'Gwagwalada Area Council',
        areas: [
          'Gwagwalada Town',
          'University of Abuja',
          'Dobi',
          'Zuba',
        ],
      ),
      NigeriaLga(
        name: 'Kuje Area Council',
        areas: [
          'Kuje Town',
          'Pegi',
          'Chibiri',
        ],
      ),
      NigeriaLga(
        name: 'Abaji Area Council',
        areas: ['Abaji Town', 'Yaba FCT'],
      ),
      NigeriaLga(
        name: 'Kwali Area Council',
        areas: ['Kwali Town', 'Sheda Science Village'],
      ),
    ],
  ),

  const NigeriaState(
    name: 'Benue State',
    capitalCity: 'Makurdi',
    lgas: [
      NigeriaLga(
        name: 'Makurdi LGA',
        areas: [
          'High Level',
          'Wurukum',
          'North Bank',
          'Judges Quarters',
          'Modern Market',
          'Ankpa Quarters',
          'Benue Links Area',
          'BSU Campus',
        ],
      ),
      NigeriaLga(
        name: 'Gboko LGA',
        areas: [
          'Gboko Central',
          'GRA',
          'Mkar',
          'Yandev',
        ],
      ),
      NigeriaLga(
        name: 'Otukpo LGA',
        areas: [
          'Otukpo Town',
          'Upu Road',
          'Sabon Gari',
        ],
      ),
      NigeriaLga(
        name: 'Katsina-Ala LGA',
        areas: ['Katsina-Ala Town', 'College of Education Area'],
      ),
    ],
  ),

  const NigeriaState(
    name: 'Lagos State',
    capitalCity: 'Ikeja',
    lgas: [
      NigeriaLga(
        name: 'Eti-Osa LGA',
        areas: [
          'Lekki Phase 1',
          'Victoria Island (VI)',
          'Ikoyi',
          'Ajah',
          'Chevron Drive',
          'Jakande',
          'Sangotedo',
        ],
      ),
      NigeriaLga(
        name: 'Ikeja LGA',
        areas: [
          'Ikeja GRA',
          'Alausa Secretariat',
          'Allen Avenue',
          'Opebi',
          'Computer Village',
          'Maryland',
        ],
      ),
      NigeriaLga(
        name: 'Lagos Mainland LGA',
        areas: [
          'Yaba Tech / Silicon Lagoon',
          'Akoka (Unilag)',
          'Ebute Metta',
        ],
      ),
      NigeriaLga(
        name: 'Surulere LGA',
        areas: [
          'Bode Thomas',
          'National Stadium',
          'Aguda',
          'Ojuelegba',
        ],
      ),
      NigeriaLga(
        name: 'Lagos Island LGA',
        areas: [
          'Marina',
          'Broad Street',
          'CMS',
          'Balogun Market',
        ],
      ),
    ],
  ),

  const NigeriaState(
    name: 'Kaduna State',
    capitalCity: 'Kaduna',
    lgas: [
      NigeriaLga(
        name: 'Kaduna North LGA',
        areas: ['GRA', 'Kawo', 'Ungwan Rimi', 'Malali'],
      ),
      NigeriaLga(
        name: 'Kaduna South LGA',
        areas: ['Barnawa', 'Kakuri', 'Television'],
      ),
      NigeriaLga(
        name: 'Zaria LGA',
        areas: ['Samaru (ABU)', 'Kongo', 'Sabon Gari'],
      ),
    ],
  ),

  const NigeriaState(
    name: 'Plateau State',
    capitalCity: 'Jos',
    lgas: [
      NigeriaLga(
        name: 'Jos North LGA',
        areas: ['Jos Terminus', 'Rantya', 'Rayfield'],
      ),
      NigeriaLga(
        name: 'Jos South LGA',
        areas: ['Bukuru', 'Zawan'],
      ),
    ],
  ),

  const NigeriaState(
    name: 'Rivers State',
    capitalCity: 'Port Harcourt',
    lgas: [
      NigeriaLga(
        name: 'Port Harcourt LGA',
        areas: ['Old GRA', 'New GRA', 'D-Line', 'Town'],
      ),
      NigeriaLga(
        name: 'Obio-Akpor LGA',
        areas: ['Rumuokoro', 'Choba (UniPort)', 'Rumuola'],
      ),
    ],
  ),

  const NigeriaState(
    name: 'Kano State',
    capitalCity: 'Kano',
    lgas: [
      NigeriaLga(
        name: 'Nassarawa LGA',
        areas: ['Nassarawa GRA', 'Bompai'],
      ),
      NigeriaLga(
        name: 'Fagge LGA',
        areas: ['Fagge Central', 'Sabon Gari Kano'],
      ),
    ],
  ),
];

/// Offline Geofence Table: maps GPS coordinates to exact State, LGA, Area without network.
OfflineLocationResult? resolveOfflineCoordinates(double lat, double lon) {
  // 1. Detailed FCT Abuja Geofencing
  if (lat >= 8.40 && lat <= 9.35 && lon >= 6.85 && lon <= 7.75) {
    // Maitama
    if (lat >= 9.075 && lat <= 9.120 && lon >= 7.480 && lon <= 7.525) {
      return const OfflineLocationResult(
        state: 'Federal Capital Territory (FCT)',
        lga: 'Abuja Municipal (AMAC)',
        area: 'Maitama',
        city: 'Abuja',
      );
    }
    // Wuse II
    if (lat >= 9.060 && lat <= 9.095 && lon >= 7.455 && lon <= 7.490) {
      return const OfflineLocationResult(
        state: 'Federal Capital Territory (FCT)',
        lga: 'Abuja Municipal (AMAC)',
        area: 'Wuse II',
        city: 'Abuja',
      );
    }
    // Central Business District (CBD)
    if (lat >= 9.035 && lat <= 9.075 && lon >= 7.485 && lon <= 7.535) {
      return const OfflineLocationResult(
        state: 'Federal Capital Territory (FCT)',
        lga: 'Abuja Municipal (AMAC)',
        area: 'Central Business District (CBD)',
        city: 'Abuja',
      );
    }
    // Asokoro / Guzape
    if (lat >= 9.015 && lat <= 9.065 && lon >= 7.515 && lon <= 7.565) {
      return const OfflineLocationResult(
        state: 'Federal Capital Territory (FCT)',
        lga: 'Abuja Municipal (AMAC)',
        area: 'Asokoro',
        city: 'Abuja',
      );
    }
    // Garki / Apo
    if (lat >= 8.980 && lat <= 9.045 && lon >= 7.465 && lon <= 7.520) {
      return const OfflineLocationResult(
        state: 'Federal Capital Territory (FCT)',
        lga: 'Abuja Municipal (AMAC)',
        area: 'Garki',
        city: 'Abuja',
      );
    }
    // Jabi Lake / Utako
    if (lat >= 9.055 && lat <= 9.090 && lon >= 7.405 && lon <= 7.455) {
      return const OfflineLocationResult(
        state: 'Federal Capital Territory (FCT)',
        lga: 'Abuja Municipal (AMAC)',
        area: 'Jabi Lake',
        city: 'Abuja',
      );
    }
    // Gwarinpa Estate / Life Camp
    if (lat >= 9.080 && lat <= 9.145 && lon >= 7.370 && lon <= 7.445) {
      return const OfflineLocationResult(
        state: 'Federal Capital Territory (FCT)',
        lga: 'Abuja Municipal (AMAC)',
        area: 'Gwarinpa Estate',
        city: 'Abuja',
      );
    }
    // Lugbe / Airport Road
    if (lat >= 8.930 && lat <= 9.030 && lon >= 7.330 && lon <= 7.430) {
      return const OfflineLocationResult(
        state: 'Federal Capital Territory (FCT)',
        lga: 'Abuja Municipal (AMAC)',
        area: 'Lugbe / Airport Rd',
        city: 'Abuja',
      );
    }
    // Kubwa / Bwari
    if (lat >= 9.125 && lat <= 9.200 && lon >= 7.300 && lon <= 7.375) {
      return const OfflineLocationResult(
        state: 'Federal Capital Territory (FCT)',
        lga: 'Bwari Area Council',
        area: 'Kubwa',
        city: 'Abuja',
      );
    }
    // Dutse / Dawaki
    if (lat >= 9.125 && lat <= 9.180 && lon >= 7.375 && lon <= 7.415) {
      return const OfflineLocationResult(
        state: 'Federal Capital Territory (FCT)',
        lga: 'Bwari Area Council',
        area: 'Dutse Alhaji',
        city: 'Abuja',
      );
    }
    // Mpape
    if (lat >= 9.105 && lat <= 9.165 && lon >= 7.470 && lon <= 7.525) {
      return const OfflineLocationResult(
        state: 'Federal Capital Territory (FCT)',
        lga: 'Bwari Area Council',
        area: 'Mpape',
        city: 'Abuja',
      );
    }
    // Gwagwalada
    if (lat >= 8.880 && lat <= 9.020 && lon >= 7.000 && lon <= 7.150) {
      return const OfflineLocationResult(
        state: 'Federal Capital Territory (FCT)',
        lga: 'Gwagwalada Area Council',
        area: 'Gwagwalada Town',
        city: 'Abuja',
      );
    }

    // Default for broader FCT
    return const OfflineLocationResult(
      state: 'Federal Capital Territory (FCT)',
      lga: 'Abuja Municipal (AMAC)',
      area: 'Abuja Metro',
      city: 'Abuja',
    );
  }

  // 2. Niger State (Minna / Bosso / Chanchaga)
  if (lat >= 9.45 && lat <= 9.75 && lon >= 6.35 && lon <= 6.75) {
    if (lat >= 9.61) {
      return const OfflineLocationResult(
        state: 'Niger State',
        lga: 'Bosso LGA',
        area: 'Bosso / FUT Minna',
        city: 'Minna',
      );
    } else {
      return const OfflineLocationResult(
        state: 'Niger State',
        lga: 'Chanchaga LGA',
        area: 'Minna Central / Tunga',
        city: 'Minna',
      );
    }
  }

  // 3. Niger State (Suleja / Madalla / Zuma Rock)
  if (lat >= 9.12 && lat <= 9.32 && lon >= 7.10 && lon <= 7.28) {
    return const OfflineLocationResult(
      state: 'Niger State',
      lga: 'Suleja LGA',
      area: 'Suleja / Madalla',
      city: 'Minna',
    );
  }

  // 4. Niger State (Bida)
  if (lat >= 9.00 && lat <= 9.15 && lon >= 5.92 && lon <= 6.10) {
    return const OfflineLocationResult(
      state: 'Niger State',
      lga: 'Bida LGA',
      area: 'Bida Town',
      city: 'Minna',
    );
  }

  // 5. Lagos State - Eti-Osa (Lekki / VI)
  if (lat >= 6.40 && lat <= 6.52 && lon >= 3.42 && lon <= 3.70) {
    return const OfflineLocationResult(
      state: 'Lagos State',
      lga: 'Eti-Osa LGA',
      area: 'Lekki Phase 1',
      city: 'Lagos',
    );
  }

  // 6. Lagos State - Ikeja / Mainland
  if (lat >= 6.53 && lat <= 6.68 && lon >= 3.30 && lon <= 3.42) {
    return const OfflineLocationResult(
      state: 'Lagos State',
      lga: 'Ikeja LGA',
      area: 'Ikeja GRA',
      city: 'Lagos',
    );
  }

  // 7. Benue State - Makurdi
  if (lat >= 7.65 && lat <= 7.82 && lon >= 8.45 && lon <= 8.65) {
    return const OfflineLocationResult(
      state: 'Benue State',
      lga: 'Makurdi LGA',
      area: 'High Level, Makurdi',
      city: 'Makurdi',
    );
  }

  // 8. International Hubs
  // London, UK
  if (lat >= 51.25 && lat <= 51.70 && lon >= -0.55 && lon <= 0.35) {
    return const OfflineLocationResult(
      state: 'Greater London',
      lga: 'Westminster',
      area: 'Central London',
      city: 'London',
      country: 'United Kingdom',
    );
  }
  // New York, USA
  if (lat >= 40.50 && lat <= 40.95 && lon >= -74.30 && lon <= -73.65) {
    return const OfflineLocationResult(
      state: 'New York',
      lga: 'Manhattan',
      area: 'Midtown',
      city: 'New York',
      country: 'United States',
    );
  }
  // Toronto, Canada
  if (lat >= 43.55 && lat <= 43.90 && lon >= -79.70 && lon <= -79.10) {
    return const OfflineLocationResult(
      state: 'Ontario',
      lga: 'Toronto',
      area: 'Downtown',
      city: 'Toronto',
      country: 'Canada',
    );
  }
  // Accra, Ghana
  if (lat >= 5.45 && lat <= 5.80 && lon >= -0.35 && lon <= 0.10) {
    return const OfflineLocationResult(
      state: 'Greater Accra',
      lga: 'Accra Metropolitan',
      area: 'Osu / Airport City',
      city: 'Accra',
      country: 'Ghana',
    );
  }
  // Nairobi, Kenya
  if (lat >= -1.45 && lat <= -1.15 && lon >= 36.65 && lon <= 37.10) {
    return const OfflineLocationResult(
      state: 'Nairobi County',
      lga: 'Westlands',
      area: 'Westlands',
      city: 'Nairobi',
      country: 'Kenya',
    );
  }

  return null;
}
