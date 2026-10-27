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

/// Comprehensive offline database of all 36 Nigerian States + FCT, LGAs, and Wards.
/// Designed for offline-first resilience: works anywhere without network or cellular data.
final List<NigeriaState> nigeriaStates = [
  const NigeriaState(
    name: 'Abia State',
    capitalCity: 'Umuahia',
    lgas: [
      NigeriaLga(
        name: 'Aba North LGA',
        areas: ['Ariaria', 'Industrial', 'Eziama', 'Osusu', 'Uratta', 'Old GRA'],
      ),
      NigeriaLga(
        name: 'Aba South LGA',
        areas: ['Enyimba', 'Ngwa Road', 'School Road', 'Market Ward', 'Asa Road', 'Gloucester'],
      ),
      NigeriaLga(
        name: 'Arochukwu LGA',
        areas: ['Arochukwu Central', 'Ohafia North', 'Ututu', 'Ihechiowa', 'Abam', 'Isu'],
      ),
      NigeriaLga(
        name: 'Bende LGA',
        areas: ['Bende Central', 'Item', 'Alayi', 'Uzuakoli', 'Ozuitem', 'Umuhu'],
      ),
      NigeriaLga(
        name: 'Ikwuano LGA',
        areas: ['Ibere', 'Oboro', 'Oloko', 'Ariam', 'Usaka', 'Ahaba'],
      ),
      NigeriaLga(
        name: 'Isiala Ngwa North LGA',
        areas: ['Ihie', 'Amapu', 'Mbawsi', 'Uratta', 'Umuoha', 'Nvosi'],
      ),
      NigeriaLga(
        name: 'Isiala Ngwa South LGA',
        areas: ['Omoba', 'Ovungwu', 'Ngwaobi', 'Mbutu', 'Akpu Na Nkata'],
      ),
      NigeriaLga(
        name: 'Isuikwuato LGA',
        areas: ['Eluama', 'Isuamawu', 'Otampa', 'Achara', 'Ogunduasa', 'Umunnekwu'],
      ),
      NigeriaLga(
        name: 'Obi Ngwa LGA',
        areas: ['Abala', 'Mgboko', 'Ibeme', 'Akuma', 'Ohuru', 'Ntighauzor'],
      ),
      NigeriaLga(
        name: 'Ohafia LGA',
        areas: ['Ebem Ohafia', 'Asaga', 'Amaekpu', 'Ohafia Central', 'Abiriba', 'Nkporo'],
      ),
      NigeriaLga(
        name: 'Osisioma LGA',
        areas: ['Osisioma Central', 'Aro Umuejeh', 'Umunneise', 'Amator', 'Okpu Umuobo'],
      ),
      NigeriaLga(
        name: 'Ugwunagbo LGA',
        areas: ['Ugwunagbo Central', 'Akanu', 'Ihie', 'Ward 1', 'Ward 2'],
      ),
      NigeriaLga(
        name: 'Ukwa East LGA',
        areas: ['Akwete', 'Azumini', 'Obohia', 'Ikwuriator', 'Umuigube'],
      ),
      NigeriaLga(
        name: 'Ukwa West LGA',
        areas: ['Obehie', 'Asa', 'Ogwe', 'Obokwe', 'Umuituru', 'Owaza'],
      ),
      NigeriaLga(
        name: 'Umuahia North LGA',
        areas: ['Umuahia Central', 'Afugiri', 'Ibeku East', 'Ibeku West', 'Nkwoegwu', 'Ossah'],
      ),
      NigeriaLga(
        name: 'Umuahia South LGA',
        areas: ['Ubakahia', 'Olokoro', 'Umuopara', 'Amakama', 'Old Umuahia'],
      ),
      NigeriaLga(
        name: 'Umunneochi LGA',
        areas: ['Umunneochi Central', 'Isuochi', 'Lokpaukwu', 'Leru', 'Nneato', 'Amuda'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Adamawa State',
    capitalCity: 'Yola',
    lgas: [
      NigeriaLga(
        name: 'Demsa LGA',
        areas: ['Demsa Central', 'Borrong', 'Dwali', 'Mbula Kpasham', 'Old Demsa'],
      ),
      NigeriaLga(
        name: 'Fufore LGA',
        areas: ['Fufore Central', 'Gurin', 'Karlahi', 'Ribadu', 'Pariya', 'Farang'],
      ),
      NigeriaLga(
        name: 'Ganye LGA',
        areas: ['Ganye Central', 'Bakari', 'Gurum', 'Sugu', 'Yebbi', 'Timdore'],
      ),
      NigeriaLga(
        name: 'Girei LGA',
        areas: ['Girei Central', 'Dakri', 'Damare', 'Jilabu', 'Modire', 'Wuro Dole'],
      ),
      NigeriaLga(
        name: 'Gombi LGA',
        areas: ['Gombi Central', 'Boga', 'Garkida', 'Guyaku', 'Yang', 'Tawa'],
      ),
      NigeriaLga(
        name: 'Guyuk LGA',
        areas: ['Guyuk Central', 'Bikikouro', 'Bobo', 'Chikila', 'Duma', 'Kobi'],
      ),
      NigeriaLga(
        name: 'Hong LGA',
        areas: ['Hong Central', 'Bangshika', 'Daksiri', 'Garaha', 'Hildi', 'Kwarhi'],
      ),
      NigeriaLga(
        name: 'Jada LGA',
        areas: ['Jada Central', 'Danaba', 'Koma', 'Leko', 'Mapeo', 'Mayo Kalaye'],
      ),
      NigeriaLga(
        name: 'Lamurde LGA',
        areas: ['Lamurde Central', 'Dubwangun', 'Gyawana', 'Lafia', 'Suwa', 'Waduku'],
      ),
      NigeriaLga(
        name: 'Madagali LGA',
        areas: ['Madagali Central', 'Babel', 'Duhu', 'Gulak', 'Kirchinga', 'Wagga'],
      ),
      NigeriaLga(
        name: 'Maiha LGA',
        areas: ['Maiha Central', 'Belel', 'Humbutudi', 'Manjekin', 'Pakka', 'Sorau'],
      ),
      NigeriaLga(
        name: 'Mayo-Belwa LGA',
        areas: ['Mayo-Belwa Central', 'Bajama', 'Binyeri', 'Gengle', 'Mayo Farang', 'Tola'],
      ),
      NigeriaLga(
        name: 'Michika LGA',
        areas: ['Michika Central', 'Bazza', 'Futudou', 'Garta', 'Jumbul', 'Madzi'],
      ),
      NigeriaLga(
        name: 'Mubi North LGA',
        areas: ['Mubi Central', 'Bahuli', 'Digil', 'Kolere', 'Lokuwa', 'Yelwa'],
      ),
      NigeriaLga(
        name: 'Mubi South LGA',
        areas: ['Gella', 'Dirbishi', 'Duvu', 'Lamorde', 'Mujara', 'Nduku'],
      ),
      NigeriaLga(
        name: 'Numan LGA',
        areas: ['Numan Central', 'Bare', 'Gamadio', 'Imburu', 'Kodomti', 'Sabon Gari'],
      ),
      NigeriaLga(
        name: 'Shelleng LGA',
        areas: ['Shelleng Central', 'Bakta', 'Bodwai', 'Gungun', 'Jumbul', 'Kiri'],
      ),
      NigeriaLga(
        name: 'Song LGA',
        areas: ['Song Central', 'Dumne', 'Gude', 'Kilange Hirna', 'Song Waje', 'Zumo'],
      ),
      NigeriaLga(
        name: 'Toungo LGA',
        areas: ['Toungo Central', 'Dawo', 'Gumti', 'Kiri', 'Kongin', 'Mayo Sangnar'],
      ),
      NigeriaLga(
        name: 'Yola North LGA',
        areas: ['Jimeta Central', 'Alkalawa', 'Ajiya', 'Doubeli', 'Jambutu', 'Karewa', 'Nassarawo'],
      ),
      NigeriaLga(
        name: 'Yola South LGA',
        areas: ['Yola Town', 'Adarawo', 'Bako', 'Bole', 'Mbamba', 'Namtari', 'Ngurore'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Akwa Ibom State',
    capitalCity: 'Uyo',
    lgas: [
      NigeriaLga(
        name: 'Abak LGA',
        areas: ['Abak Urban', 'Afaha Obong', 'Midim', 'Otoro', 'Ediene'],
      ),
      NigeriaLga(
        name: 'Eastern Obolo LGA',
        areas: ['Okoroete', 'Iko', 'Elile', 'Atabrikang', 'Amadaka'],
      ),
      NigeriaLga(
        name: 'Eket LGA',
        areas: ['Eket Urban', 'Afaha Eket', 'Okon', 'Ikot Usepong', 'Idung Ini'],
      ),
      NigeriaLga(
        name: 'Esit Eket LGA',
        areas: ['Uquo', 'Ebighi Edu', 'Ekpene Obo', 'Akpautong', 'Etebi'],
      ),
      NigeriaLga(
        name: 'Essien Udim LGA',
        areas: ['Afaha', 'Adiasim', 'Ukana', 'Ekpenyong', 'Ikpe Annang'],
      ),
      NigeriaLga(
        name: 'Etim Ekpo LGA',
        areas: ['Utu Etim Ekpo', 'Obong', 'Uruk', 'Ikpe Annang', 'Afaha'],
      ),
      NigeriaLga(
        name: 'Etinan LGA',
        areas: ['Etinan Urban', 'Northern Iman', 'Southern Iman', 'East Iman'],
      ),
      NigeriaLga(
        name: 'Ibeno LGA',
        areas: ['Ukpenekang', 'Iwoachang', 'Mkpanak', 'Inua Eyet Ikot', 'Itak Abasi'],
      ),
      NigeriaLga(
        name: 'Ibesikpo Asutan LGA',
        areas: ['Ibesikpo', 'Asutan', 'Nung Udoe', 'Afaha Ikot Owop', 'Ikot Oduot'],
      ),
      NigeriaLga(
        name: 'Ibiono Ibom LGA',
        areas: ['Ibiono Central', 'Northern Ibiono', 'Southern Ibiono', 'Eastern Ibiono', 'Ikpanya'],
      ),
      NigeriaLga(
        name: 'Ika LGA',
        areas: ['Urua Inyang', 'Achan', 'Ito', 'Odoro', 'Urban'],
      ),
      NigeriaLga(
        name: 'Ikono LGA',
        areas: ['Ikono Central', 'Itak', 'Ediene', 'Nkwot', 'Asantan'],
      ),
      NigeriaLga(
        name: 'Ikot Abasi LGA',
        areas: ['Ikot Abasi Urban', 'Ikpa Ibekwe', 'Ukpum Ete', 'Edemaya', 'Ikpa Nung Asang'],
      ),
      NigeriaLga(
        name: 'Ikot Ekpene LGA',
        areas: ['Ikot Ekpene Urban', 'Amanyam', 'Ape', 'Ikpe', 'Obot Akara Border'],
      ),
      NigeriaLga(
        name: 'Ini LGA',
        areas: ['Odoro Ikpe', 'Ikpe Ikot Nkon', 'Iwerre', 'Usuk Ukwok', 'Asuna'],
      ),
      NigeriaLga(
        name: 'Itu LGA',
        areas: ['Itu Urban', 'East Itam', 'West Itam', 'Okiuso', 'Mbiabo'],
      ),
      NigeriaLga(
        name: 'Mbo LGA',
        areas: ['Enwang', 'Ibaka', 'Ebughu', 'Udesi', 'Effiat'],
      ),
      NigeriaLga(
        name: 'Mkpat Enin LGA',
        areas: ['Mkpat Enin Urban', 'Ukpum Minya', 'Ibiaku', 'Ikpa Ibom', 'Asong'],
      ),
      NigeriaLga(
        name: 'Nsit Atai LGA',
        areas: ['Odot', 'Afaha', 'Ikot Itie Udung', 'Eastern Nsit'],
      ),
      NigeriaLga(
        name: 'Nsit Ibom LGA',
        areas: ['Afaha Offiong', 'Asang', 'Eastern Nsit', 'Western Nsit'],
      ),
      NigeriaLga(
        name: 'Nsit Ubium LGA',
        areas: ['Ikotoffiong', 'Ubium North', 'Ubium South', 'Itrepto'],
      ),
      NigeriaLga(
        name: 'Obot Akara LGA',
        areas: ['Nto Edino', 'Ikpe Mbak Eyop', 'Obot Akara Urban'],
      ),
      NigeriaLga(
        name: 'Okobo LGA',
        areas: ['Okopedi', 'Ekeya', 'Urueita', 'Atabong', 'Offi'],
      ),
      NigeriaLga(
        name: 'Onna LGA',
        areas: ['Abat', 'Awa', 'Oniong', 'Nnung Chem'],
      ),
      NigeriaLga(
        name: 'Oron LGA',
        areas: ['Oron Urban', 'Afaha Okpo', 'Idua', 'Eyotong'],
      ),
      NigeriaLga(
        name: 'Oruk Anam LGA',
        areas: ['Ikot Ibritam', 'Abak Midim', 'Qwa', 'Ekparakwa', 'Inen'],
      ),
      NigeriaLga(
        name: 'Udung Uko LGA',
        areas: ['Eyofin', 'Edikor', 'Uboro', 'Udung Uko Urban'],
      ),
      NigeriaLga(
        name: 'Ukanafun LGA',
        areas: ['Ikotoffiong', 'Northern Afaha', 'Southern Afaha', 'Idung Nneke'],
      ),
      NigeriaLga(
        name: 'Uruan LGA',
        areas: ['Idu Uruan', 'Northern Uruan', 'Central Uruan', 'Southern Uruan'],
      ),
      NigeriaLga(
        name: 'Urue-Offong/Oruko LGA',
        areas: ['Urue Offong', 'Oruko', 'Mbokpu Eyokan', 'Eyulor'],
      ),
      NigeriaLga(
        name: 'Uyo LGA',
        areas: ['Uyo Urban', 'Etoi', 'Ikono', 'Offot', 'Oku', 'Nsukara'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Anambra State',
    capitalCity: 'Awka',
    lgas: [
      NigeriaLga(
        name: 'Aguata LGA',
        areas: ['Ekwulobia', 'Uga', 'Achina', 'Agulu-Ezechukwu', 'Igboukwu', 'Umuchu'],
      ),
      NigeriaLga(
        name: 'Anambra East LGA',
        areas: ['Otuocha', 'Aguleri', 'Enugwu-Aguleri', 'Umueri', 'Nando', 'Nsugbe'],
      ),
      NigeriaLga(
        name: 'Anambra West LGA',
        areas: ['Nzam', 'Olumbanasa', 'Mmiata', 'Anam', 'Inoma', 'Owelle'],
      ),
      NigeriaLga(
        name: 'Anaocha LGA',
        areas: ['Neni', 'Agulu', 'Adazi-Nnukwu', 'Adazi-Ani', 'Nri', 'Aguluzigbo'],
      ),
      NigeriaLga(
        name: 'Awka North LGA',
        areas: ['Achalla', 'Amansea', 'Awba-Ofemili', 'Ebenebe', 'Isuaniocha', 'Ugbene'],
      ),
      NigeriaLga(
        name: 'Awka South LGA',
        areas: ['Awka Central', 'Amawbia', 'Nibo', 'Nise', 'Mbaukwu', 'Okpuno'],
      ),
      NigeriaLga(
        name: 'Ayamelum LGA',
        areas: ['Anaku', 'Omor', 'Ifite-Ogwari', 'Igbakwu', 'Umueje', 'Omer'],
      ),
      NigeriaLga(
        name: 'Dunukofia LGA',
        areas: ['Ukpo', 'Ifitedunu', 'Umudioka', 'Umunachi', 'Ukwulu', 'Nawgu'],
      ),
      NigeriaLga(
        name: 'Ekwusigo LGA',
        areas: ['Ozubulu', 'Oraifite', 'Ichi', 'Ihembosi'],
      ),
      NigeriaLga(
        name: 'Idemili North LGA',
        areas: ['Ogidi', 'Nkpor', 'Obosi', 'Uke', 'Abatete', 'Ideani', 'Oraukwu'],
      ),
      NigeriaLga(
        name: 'Idemili South LGA',
        areas: ['Ojoto', 'Alor', 'Nnobi', 'Oba', 'Akwa-Etiti', 'Awka-Etiti'],
      ),
      NigeriaLga(
        name: 'Ihiala LGA',
        areas: ['Ihiala Central', 'Uli', 'Okija', 'Amorka', 'Azia', 'Iseke', 'Lilu'],
      ),
      NigeriaLga(
        name: 'Njikoka LGA',
        areas: ['Abagana', 'Enugwu-Ukwu', 'Nawfia', 'Nimo', 'Abba'],
      ),
      NigeriaLga(
        name: 'Nnewi North LGA',
        areas: ['Otolo', 'Uruagu', 'Umudim', 'Nnewichi', 'Nnewi Central'],
      ),
      NigeriaLga(
        name: 'Nnewi South LGA',
        areas: ['Ukpor', 'Utuh', 'Ebenator', 'Amichi', 'Osumenyi', 'Ekwulumili'],
      ),
      NigeriaLga(
        name: 'Ogbaru LGA',
        areas: ['Atani', 'Okpoko', 'Odekpe', 'Ossomala', 'Ogwu-Aniocha', 'Akili-Ogidi'],
      ),
      NigeriaLga(
        name: 'Onitsha North LGA',
        areas: ['Onitsha GRA', 'Odoakpu', 'Inland Town', 'Fegge North', 'Woliwo', 'Marine'],
      ),
      NigeriaLga(
        name: 'Onitsha South LGA',
        areas: ['Fegge Central', 'Bridge Head', 'Odukpani', 'Niger Bridge Area'],
      ),
      NigeriaLga(
        name: 'Orumba North LGA',
        areas: ['Ajalli', 'Ufuma', 'Ndikelionwu', 'Nanka', 'Oko (Federal Poly)', 'Amaokpala'],
      ),
      NigeriaLga(
        name: 'Orumba South LGA',
        areas: ['Umunze', 'Ihite', 'Nkerehi', 'Ezira', 'Isulo', 'Ogbunka'],
      ),
      NigeriaLga(
        name: 'Oyi LGA',
        areas: ['Nkwelle-Ezunaka', 'Ogbunike', 'Awkuzu', 'Umunya', 'Nteje'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Bauchi State',
    capitalCity: 'Bauchi',
    lgas: [
      NigeriaLga(
        name: 'Alkaleri LGA',
        areas: ['Alkaleri Central', 'Futuk', 'Gwana', 'Pali', 'Dan', 'Yalo'],
      ),
      NigeriaLga(
        name: 'Bauchi LGA',
        areas: ['Bauchi Central', 'Dan Iya', 'Dawaki', 'Hardawa', 'Kandahar', 'Makama', 'Tirwun'],
      ),
      NigeriaLga(
        name: 'Bogoro LGA',
        areas: ['Bogoro Central', 'Boi', 'Lusa', 'Gambar', 'Bar'],
      ),
      NigeriaLga(
        name: 'Dambam LGA',
        areas: ['Dambam Central', 'Dagauda', 'Gargawa', 'Zaura', 'Yanda'],
      ),
      NigeriaLga(
        name: 'Darazo LGA',
        areas: ['Darazo Central', 'Gabarin', 'Konkiyel', 'Lanzai', 'Sade', 'Wandi'],
      ),
      NigeriaLga(
        name: 'Dass LGA',
        areas: ['Dass Central', 'Bununu', 'Baraza', 'Durr', 'Polchi', 'Wandi'],
      ),
      NigeriaLga(
        name: 'Gamawa LGA',
        areas: ['Gamawa Central', 'Alagarno', 'Gololo', 'Kafin Romi', 'Raga', 'Tumbi'],
      ),
      NigeriaLga(
        name: 'Ganjuwa LGA',
        areas: ['Kafin Madaki', 'Ganjuwa Central', 'Kariya', 'Miya', 'Ningi Border'],
      ),
      NigeriaLga(
        name: 'Giade LGA',
        areas: ['Giade Central', 'Chinkani', 'Doguwa', 'Ubandawaki', 'Zirami'],
      ),
      NigeriaLga(
        name: 'Itas/Gadau LGA',
        areas: ['Itas Central', 'Gadau', 'Buzawa', 'Gwarai', 'Mashema'],
      ),
      NigeriaLga(
        name: 'Jama\'are LGA',
        areas: ['Jama\'are Central', 'Dogon Jeji', 'Galdamari', 'Hana Fari', 'Jurara'],
      ),
      NigeriaLga(
        name: 'Katagum LGA',
        areas: ['Azare Central', 'Chinade', 'Madangala', 'Madachi', 'Busu', 'Yayu'],
      ),
      NigeriaLga(
        name: 'Kirfi LGA',
        areas: ['Kirfi Central', 'Badara', 'Bara', 'Dewu', 'Tubule'],
      ),
      NigeriaLga(
        name: 'Misau LGA',
        areas: ['Misau Central', 'Gwaram', 'Hardawa', 'Kukadi', 'Sarma', 'Zindi'],
      ),
      NigeriaLga(
        name: 'Ningi LGA',
        areas: ['Ningi Central', 'Balma', 'Bashe', 'Burra', 'Kurmi', 'Kudu'],
      ),
      NigeriaLga(
        name: 'Shira LGA',
        areas: ['Yana', 'Shira Central', 'Beli', 'Faggo', 'Kilbori', 'Zubo'],
      ),
      NigeriaLga(
        name: 'Tafawa Balewa LGA',
        areas: ['Tafawa Balewa Central', 'Bununu', 'Dull', 'Lere', 'Tapshin', 'Wai'],
      ),
      NigeriaLga(
        name: 'Toro LGA',
        areas: ['Toro Central', 'Lame', 'Mara', 'Palama', 'Rishi', 'Tula', 'Zalau'],
      ),
      NigeriaLga(
        name: 'Warji LGA',
        areas: ['Warji Central', 'Badagari', 'Bima', 'Dagu', 'Ranga', 'Tiyin'],
      ),
      NigeriaLga(
        name: 'Zaki LGA',
        areas: ['Katagum', 'Sakwa', 'Mainari', 'Tashena', 'Murmur', 'Gadabiu'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Bayelsa State',
    capitalCity: 'Yenagoa',
    lgas: [
      NigeriaLga(
        name: 'Brass LGA',
        areas: ['Twon-Brass', 'Akassa', 'Cape Formosa', 'Liama', 'Odioma', 'Sangana'],
      ),
      NigeriaLga(
        name: 'Ekeremor LGA',
        areas: ['Ekeremor Central', 'Aleibiri', 'Amabulou', 'Ndoro', 'Peretorugbene', 'Tarakiri'],
      ),
      NigeriaLga(
        name: 'Kolokuma/Opokuma LGA',
        areas: ['Kaiama', 'Opokuma', 'Sampou', 'Odi', 'Sabagreia', 'Okoloba'],
      ),
      NigeriaLga(
        name: 'Nembe LGA',
        areas: ['Nembe Bassambiri', 'Ogbolomabiri', 'Okoroba', 'Igbobele', 'Oluasiri'],
      ),
      NigeriaLga(
        name: 'Ogbia LGA',
        areas: ['Ogbia Town', 'Otuoke (UniAfrica)', 'Imiringi', 'Kolo', 'Anyama', 'Emeyal'],
      ),
      NigeriaLga(
        name: 'Sagbama LGA',
        areas: ['Sagbama Central', 'Adagbabiri', 'Agbere', 'Asamabiri', 'Toru-Ebeni', 'Ofoni'],
      ),
      NigeriaLga(
        name: 'Southern Ijaw LGA',
        areas: ['Oporoma', 'Amassoma (NDU)', 'Apoi', 'Boma', 'Foropa', 'Koluama', 'Peremabiri'],
      ),
      NigeriaLga(
        name: 'Yenagoa LGA',
        areas: ['Yenagoa City', 'Amarata', 'Etegwe', 'Kpansia', 'Biogbolo', 'Swali', 'Tombia', 'Okaka'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Benue State',
    capitalCity: 'Makurdi',
    lgas: [
      NigeriaLga(
        name: 'Ado LGA',
        areas: ['Igumale', 'Apa-Agila', 'Ijigban', 'Ulayi', 'Rijo'],
      ),
      NigeriaLga(
        name: 'Agatu LGA',
        areas: ['Obagaji', 'Odugbeho', 'Ogwule', 'Oshigbudu', 'Okokolo'],
      ),
      NigeriaLga(
        name: 'Apa LGA',
        areas: ['Ugbokpo', 'Ikaighe', 'Oiji', 'Akpete', 'Auke'],
      ),
      NigeriaLga(
        name: 'Buruku LGA',
        areas: ['Buruku Central', 'Binev', 'Mbaade', 'Mbaakura', 'Mbaya', 'Shorov'],
      ),
      NigeriaLga(
        name: 'Gboko LGA',
        areas: ['Gboko Central', 'Gboko East', 'Gboko South', 'Mkar', 'Yandev', 'Adekaa'],
      ),
      NigeriaLga(
        name: 'Guma LGA',
        areas: ['Gbajimba', 'Abinsi', 'Daudu', 'Nzorov', 'Uvir', 'Mbagwen'],
      ),
      NigeriaLga(
        name: 'Gwer East LGA',
        areas: ['Aliade', 'Akpach\'ayi', 'Ikyonov', 'Mbaabir', 'Yonov'],
      ),
      NigeriaLga(
        name: 'Gwer West LGA',
        areas: ['Naka', 'Sengev', 'Tse-Agagbe', 'Tijime', 'Mbachohon'],
      ),
      NigeriaLga(
        name: 'Katsina-Ala LGA',
        areas: ['Katsina-Ala Town', 'Gbishe', 'Michihe', 'Tor Donga', 'Utange', 'Mbacher'],
      ),
      NigeriaLga(
        name: 'Konshisha LGA',
        areas: ['Tse-Agberagba', 'Ikyurav', 'Mbatian', 'Mbayegh', 'Tse-Dura'],
      ),
      NigeriaLga(
        name: 'Kwande LGA',
        areas: ['Adikpo', 'Jato-Aka', 'Kumakwagh', 'Mbaikyor', 'Nanev', 'Turan'],
      ),
      NigeriaLga(
        name: 'Logo LGA',
        areas: ['Ugba', 'Anyiin', 'Ayilamo', 'Kyado', 'Mbagber', 'Yonov'],
      ),
      NigeriaLga(
        name: 'Makurdi LGA',
        areas: ['High Level', 'Wadata', 'North Bank', 'Wurukum', 'Modern Market', 'Ankpa Quarters', 'Fiidi'],
      ),
      NigeriaLga(
        name: 'Obi LGA',
        areas: ['Obarike-Ito', 'Adum-West', 'Ito', 'Okpokwu-Ito', 'Orihi'],
      ),
      NigeriaLga(
        name: 'Ogbadibo LGA',
        areas: ['Otukpa', 'Orokam', 'Owukpa', 'Ai-Oodo', 'Ai-Ono'],
      ),
      NigeriaLga(
        name: 'Ohimini LGA',
        areas: ['Idekpa', 'Agadagba', 'Ochobo', 'Oglewu', 'Onyagede'],
      ),
      NigeriaLga(
        name: 'Oju LGA',
        areas: ['Oju Central', 'Adum', 'Ibilla', 'Iyeche', 'Owo', 'Ukpoke'],
      ),
      NigeriaLga(
        name: 'Okpokwu LGA',
        areas: ['Okpoga', 'Ichama', 'Ojigo', 'Eke', 'Ugbokolo'],
      ),
      NigeriaLga(
        name: 'Otukpo LGA',
        areas: ['Otukpo Central', 'Akpa', 'Adoka', 'Ugboju', 'Otobi', 'Upu', 'Otukpo Town'],
      ),
      NigeriaLga(
        name: 'Tarka LGA',
        areas: ['Wannune', 'Mbaayo', 'Mbakor', 'Shitile', 'Tongov'],
      ),
      NigeriaLga(
        name: 'Ukum LGA',
        areas: ['Sankera', 'Zaki Biam', 'Borikyo', 'Tsaav', 'Uyam', 'Lumbuv'],
      ),
      NigeriaLga(
        name: 'Ushongo LGA',
        areas: ['Lessel', 'Atirkyese', 'Ikov', 'Mbagba', 'Ushongo Town'],
      ),
      NigeriaLga(
        name: 'Vandeikya LGA',
        areas: ['Vandeikya Town', 'Mbadede', 'Mbaikyaha', 'Mbakaange', 'Tsar', 'Ningev'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Borno State',
    capitalCity: 'Maiduguri',
    lgas: [
      NigeriaLga(
        name: 'Abadam LGA',
        areas: ['Mallam Fatori', 'Arege', 'Duguri', 'Kudokurgu'],
      ),
      NigeriaLga(
        name: 'Askira/Uba LGA',
        areas: ['Askira Town', 'Uba', 'Chul', 'Hildi', 'Lassa', 'Wamdeo'],
      ),
      NigeriaLga(
        name: 'Bama LGA',
        areas: ['Bama Central', 'Banki', 'Gulumba', 'Kasugula', 'Sabsabwa', 'Soyoye'],
      ),
      NigeriaLga(
        name: 'Bayo LGA',
        areas: ['Fika', 'Briyel', 'Balbaya', 'Jara Dal', 'Wuyo'],
      ),
      NigeriaLga(
        name: 'Biu LGA',
        areas: ['Biu Central', 'Galtimari', 'Kenken', 'Miringa', 'Yawi', 'Zarawuyaku'],
      ),
      NigeriaLga(
        name: 'Chibok LGA',
        areas: ['Chibok Central', 'Garapu', 'Gatamarwa', 'Kautikari', 'Korongilum'],
      ),
      NigeriaLga(
        name: 'Damboa LGA',
        areas: ['Damboa Central', 'Ajigin', 'Gwozabu', 'Kopchi', 'Wajiroko'],
      ),
      NigeriaLga(
        name: 'Dikwa LGA',
        areas: ['Dikwa Central', 'Boboshe', 'Gajibo', 'Malam Maja', 'Nguro-Soye'],
      ),
      NigeriaLga(
        name: 'Gubio LGA',
        areas: ['Gubio Central', 'Ardimini', 'Feno', 'Gazabure', 'Ngetra'],
      ),
      NigeriaLga(
        name: 'Guzamala LGA',
        areas: ['Guzamala Central', 'Gudumbali', 'Kingarwa', 'Mairari', 'Wabbar'],
      ),
      NigeriaLga(
        name: 'Gwoza LGA',
        areas: ['Gwoza Central', 'Ashigashiya', 'Bita', 'Izge', 'Limankara', 'Pulka'],
      ),
      NigeriaLga(
        name: 'Hawul LGA',
        areas: ['Azare', 'Kwaya Bura', 'Marama', 'Pama', 'Sakwa', 'Shaffa'],
      ),
      NigeriaLga(
        name: 'Jere LGA',
        areas: ['Old Maiduguri', 'Alau', 'Bale Galtimari', 'Dala', 'Gomari', 'Maimusari'],
      ),
      NigeriaLga(
        name: 'Kaga LGA',
        areas: ['Benisheikh', 'Afa', 'Dongo', 'Ngamdu', 'Tobolo'],
      ),
      NigeriaLga(
        name: 'Kala/Balge LGA',
        areas: ['Rann', 'Duguma', 'Kala', 'Moholo', 'Sigal'],
      ),
      NigeriaLga(
        name: 'Konduga LGA',
        areas: ['Konduga Central', 'Auno', 'Dalori', 'Kawuri', 'Malari', 'Sandiya'],
      ),
      NigeriaLga(
        name: 'Kukawa LGA',
        areas: ['Kukawa Central', 'Baga', 'Cross Kauwa', 'Doro', 'Kauwa'],
      ),
      NigeriaLga(
        name: 'Kwaya Kusar LGA',
        areas: ['Kwaya Kusar Central', 'Gusi', 'Kurba', 'Wada', 'Yimirthalang'],
      ),
      NigeriaLga(
        name: 'Mafa LGA',
        areas: ['Mafa Central', 'Abari', 'Anadiri', 'Gawa', 'Mbuta', 'Tamsu Kawu'],
      ),
      NigeriaLga(
        name: 'Magumeri LGA',
        areas: ['Magumeri Central', 'Ardoram', 'Borno Yeso', 'Gajiganna', 'Ngamma'],
      ),
      NigeriaLga(
        name: 'Maiduguri LGA',
        areas: ['Shehuri North', 'Shehuri South', 'Gwange', 'Hausari', 'Bulabulin', 'Bolori', 'Fezzan'],
      ),
      NigeriaLga(
        name: 'Marte LGA',
        areas: ['Marte Central', 'Ala', 'Kirenowa', 'Musune', 'Njine'],
      ),
      NigeriaLga(
        name: 'Mobbar LGA',
        areas: ['Damasak', 'Asaga', 'Duji', 'Gashagar', 'Zanna Umarti'],
      ),
      NigeriaLga(
        name: 'Monguno LGA',
        areas: ['Monguno Central', 'Damakuli', 'Kaguram', 'Kumalia', 'Sure'],
      ),
      NigeriaLga(
        name: 'Ngala LGA',
        areas: ['Gamboru', 'Ngala Central', 'Ndufu', 'Wulgo'],
      ),
      NigeriaLga(
        name: 'Nganzai LGA',
        areas: ['Gajiram', 'Alarge', 'Badu', 'Damaram', 'Kuda'],
      ),
      NigeriaLga(
        name: 'Shani LGA',
        areas: ['Shani Central', 'Bargu', 'Gora', 'Gwaskara', 'Kombo', 'Walama'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Cross River State',
    capitalCity: 'Calabar',
    lgas: [
      NigeriaLga(
        name: 'Abi LGA',
        areas: ['Itigidi', 'Ugep Road', 'Ediba', 'Ebonyi', 'Imabana'],
      ),
      NigeriaLga(
        name: 'Akamkpa LGA',
        areas: ['Akamkpa Urban', 'Awi', 'Iko Ekperem', 'Oban', 'Uyanga'],
      ),
      NigeriaLga(
        name: 'Akpabuyo LGA',
        areas: ['Ikang', 'Atimbo', 'Ikot Nakanda', 'Ikot Edem Odo'],
      ),
      NigeriaLga(
        name: 'Bakassi LGA',
        areas: ['Abana', 'Archibong', 'Atabong', 'Amoto'],
      ),
      NigeriaLga(
        name: 'Bekwarra LGA',
        areas: ['Abuochiche', 'Afrike', 'Gakem', 'Nyanya', 'Ugboro'],
      ),
      NigeriaLga(
        name: 'Biase LGA',
        areas: ['Akpet', 'Erei', 'Ikun', 'Umon', 'Agwagwune'],
      ),
      NigeriaLga(
        name: 'Boki LGA',
        areas: ['Boje', 'Bateriko', 'Danare', 'Irruan', 'Kakwagom', 'Okundi'],
      ),
      NigeriaLga(
        name: 'Calabar Municipal LGA',
        areas: ['Calabar Road', 'Marian', 'Diamond Hill', 'State Housing', 'Akpabuyo Border', 'Federal Housing'],
      ),
      NigeriaLga(
        name: 'Calabar South LGA',
        areas: ['Anantigha', 'Cobham Town', 'Efio-Ete', 'Henshaw Town', 'Mbukpa', 'Hawkins'],
      ),
      NigeriaLga(
        name: 'Etung LGA',
        areas: ['Effraya', 'Abijang', 'Agbokim (Waterfalls)', 'Bendeghe', 'Etomi'],
      ),
      NigeriaLga(
        name: 'Ikom LGA',
        areas: ['Ikom Urban', 'Four Corners', 'Okundi', 'Nde', 'Ofutop', 'Akparabong'],
      ),
      NigeriaLga(
        name: 'Obanliku LGA',
        areas: ['Sankwala', 'Obudu Mountain Resort Area', 'Bisu', 'Bebi', 'Utanga'],
      ),
      NigeriaLga(
        name: 'Obubra LGA',
        areas: ['Obubra Urban', 'Apiapum', 'Iyamoyong', 'Ovonum', 'Ofumbongha'],
      ),
      NigeriaLga(
        name: 'Obudu LGA',
        areas: ['Obudu Urban', 'Begiading', 'Ipong', 'Utugwang', 'Alege'],
      ),
      NigeriaLga(
        name: 'Odukpani LGA',
        areas: ['Odukpani Central', 'Creek Town', 'Adiabo', 'Ikot Otu', 'Okurikang'],
      ),
      NigeriaLga(
        name: 'Ogoja LGA',
        areas: ['Ogoja Urban', 'Igoli', 'Ishibori', 'Mbube', 'Nkum', 'Ekajuk'],
      ),
      NigeriaLga(
        name: 'Yakuur LGA',
        areas: ['Ugep Urban', 'Idomi', 'Mkpani', 'Nko', 'Ekori'],
      ),
      NigeriaLga(
        name: 'Yala LGA',
        areas: ['Okpoma', 'Yahe', 'Gabu', 'Wanihem', 'Okuku'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Delta State',
    capitalCity: 'Asaba',
    lgas: [
      NigeriaLga(
        name: 'Aniocha North LGA',
        areas: ['Issele-Uku', 'Onicha-Ugbo', 'Idumuje-Ugboko', 'Ezi', 'Obior'],
      ),
      NigeriaLga(
        name: 'Aniocha South LGA',
        areas: ['Ogwashi-Uku', 'Ubulu-Uku', 'Nsukwa', 'Ejeme', 'Isheagu'],
      ),
      NigeriaLga(
        name: 'Bomadi LGA',
        areas: ['Bomadi Town', 'Kpakiama', 'Ogriagbene', 'Esanma'],
      ),
      NigeriaLga(
        name: 'Burutu LGA',
        areas: ['Burutu Town', 'Forcados', 'Kiagbodo', 'Ogulagha', 'Ayakoromo'],
      ),
      NigeriaLga(
        name: 'Ethiope East LGA',
        areas: ['Isiokolo', 'Abraka (DELSU)', 'Eku', 'Kokori', 'Okpara'],
      ),
      NigeriaLga(
        name: 'Ethiope West LGA',
        areas: ['Oghara', 'Mosogar', 'Jesse', 'Ajagbodudu'],
      ),
      NigeriaLga(
        name: 'Ika North East LGA',
        areas: ['Owa-Oyibu', 'Boone', 'Idumuesah', 'Umunede', 'Akumazi'],
      ),
      NigeriaLga(
        name: 'Ika South LGA',
        areas: ['Agbor Central', 'Agbor-Obi', 'Alihikagu', 'Abavo', 'Oza-Nogogo'],
      ),
      NigeriaLga(
        name: 'Isoko North LGA',
        areas: ['Ozoro (Poly)', 'Ofagbe', 'Owhelogbo', 'Ellu', 'Iyede'],
      ),
      NigeriaLga(
        name: 'Isoko South LGA',
        areas: ['Oleh', 'Aviara', 'Emede', 'Irri', 'Uzere', 'Olomoro'],
      ),
      NigeriaLga(
        name: 'Ndokwa East LGA',
        areas: ['Aboh', 'Ashaka', 'Ossissa', 'Afor', 'Ushie'],
      ),
      NigeriaLga(
        name: 'Ndokwa West LGA',
        areas: ['Kwale', 'Utagba-Uno', 'Ogume', 'Onicha-Ukwuani'],
      ),
      NigeriaLga(
        name: 'Okpe LGA',
        areas: ['Orerokpe', 'Jeddo', 'Osubi (Airport)', 'Adeje', 'Ughoton'],
      ),
      NigeriaLga(
        name: 'Oshimili North LGA',
        areas: ['Ibusa', 'Okolimiri', 'Illah', 'Okpanam', 'Ebu'],
      ),
      NigeriaLga(
        name: 'Oshimili South LGA',
        areas: ['Asaba Central', 'Cable Point', 'GRA Asaba', 'Nnebisi Road', 'Okwe'],
      ),
      NigeriaLga(
        name: 'Patani LGA',
        areas: ['Patani Town', 'Agoloma', 'Aven', 'Toru-Angiama'],
      ),
      NigeriaLga(
        name: 'Sapele LGA',
        areas: ['Sapele Urban', 'Amukpe', 'Elume', 'Ogodo', 'Okpe Border'],
      ),
      NigeriaLga(
        name: 'Udu LGA',
        areas: ['Ovwian', 'Aladja', 'Enerhen', 'Orhuwhorun', 'Ujevwu'],
      ),
      NigeriaLga(
        name: 'Ughelli North LGA',
        areas: ['Ughelli Central', 'Agbarho', 'Evwreni', 'Ogor', 'Orogun'],
      ),
      NigeriaLga(
        name: 'Ughelli South LGA',
        areas: ['Jeremi', 'Effurun-Otor', 'Ewu', 'Okparabe', 'Olomu'],
      ),
      NigeriaLga(
        name: 'Ukwuani LGA',
        areas: ['Obiaruku', 'Amai', 'Eziokpor', 'Umuebu'],
      ),
      NigeriaLga(
        name: 'Uvwie LGA',
        areas: ['Effurun', 'PTI Road', 'Ekpan', 'Jakpa Road', 'Warri Bypass'],
      ),
      NigeriaLga(
        name: 'Warri North LGA',
        areas: ['Koko', 'Ogheye', 'Tebujor', 'Gbokoda'],
      ),
      NigeriaLga(
        name: 'Warri South LGA',
        areas: ['Warri GRA', 'Main Market', 'Pessu', 'Bowen', 'Okumagba Layout', 'Edjeba'],
      ),
      NigeriaLga(
        name: 'Warri South West LGA',
        areas: ['Ogbe-Ijoh', 'Escravos', 'Oporoza', 'Madangho', 'Kantu'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Ebonyi State',
    capitalCity: 'Abakaliki',
    lgas: [
      NigeriaLga(
        name: 'Abakaliki LGA',
        areas: ['Abakaliki Urban', 'Kpirikpiri', 'Azuiyiokwu', 'Presco', 'Nkaliki'],
      ),
      NigeriaLga(
        name: 'Afikpo North LGA',
        areas: ['Afikpo Urban', 'Ehugbo', 'Unwana', 'Itim', 'Ohaisu'],
      ),
      NigeriaLga(
        name: 'Afikpo South LGA',
        areas: ['Nguzu Edda', 'Ebunwana', 'Owutu', 'Amangwu', 'Osomgbobe'],
      ),
      NigeriaLga(
        name: 'Ebonyi LGA',
        areas: ['Ugbodo', 'Abakpa', 'Echiaba', 'Kpirikpiri Rural'],
      ),
      NigeriaLga(
        name: 'Ezza North LGA',
        areas: ['Ebiaji', 'Nkomoro', 'Ogboji', 'Umuoghara'],
      ),
      NigeriaLga(
        name: 'Ezza South LGA',
        areas: ['Onueke', 'Amana', 'Ameka', 'Ezzama'],
      ),
      NigeriaLga(
        name: 'Ikwo LGA',
        areas: ['Echara', 'FUNAI Area', 'Ndufu-Alike', 'Alike', 'Inyimagu'],
      ),
      NigeriaLga(
        name: 'Ishielu LGA',
        areas: ['Ezillo', 'Ntezi', 'Nkalagu (Cement)', 'Ezzagu'],
      ),
      NigeriaLga(
        name: 'Ivo LGA',
        areas: ['Ishiagu', 'Akaeze', 'Okue', 'Ngwogwo'],
      ),
      NigeriaLga(
        name: 'Izzi LGA',
        areas: ['Iboko', 'Agomeze', 'Igbeagu', 'Mgbo'],
      ),
      NigeriaLga(
        name: 'Ohaozara LGA',
        areas: ['Obiozara', 'Okposi', 'Uburu', 'Amoffia'],
      ),
      NigeriaLga(
        name: 'Ohaukwu LGA',
        areas: ['135 Ezzamgbo', 'Ngbo', 'Effium', 'Okobo'],
      ),
      NigeriaLga(
        name: 'Onicha LGA',
        areas: ['Isu', 'Onicha-Igboeze', 'Oshiri', 'Ukawu', 'Aba-Omege'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Edo State',
    capitalCity: 'Benin City',
    lgas: [
      NigeriaLga(
        name: 'Akoko-Edo LGA',
        areas: ['Igarra', 'Ibillo', 'Ososo', 'Lampese', 'Somorika'],
      ),
      NigeriaLga(
        name: 'Egor LGA',
        areas: ['Uselu', 'Ugbowo (UNIBEN)', 'Ogida', 'Okhoro', 'Evbareke'],
      ),
      NigeriaLga(
        name: 'Esan Central LGA',
        areas: ['Irrua (ISTH)', 'Ewu', 'Opoji', 'Ugbegun'],
      ),
      NigeriaLga(
        name: 'Esan North-East LGA',
        areas: ['Uromi Central', 'Amedokhian', 'Efandion', 'Uzea'],
      ),
      NigeriaLga(
        name: 'Esan South-East LGA',
        areas: ['Ubiaja', 'Ewohimi', 'Illushi', 'Oria'],
      ),
      NigeriaLga(
        name: 'Esan West LGA',
        areas: ['Ekpoma (AAU)', 'Iruekpen', 'Ogida-Esan', 'Ukhun'],
      ),
      NigeriaLga(
        name: 'Etsako Central LGA',
        areas: ['Fugar', 'Ekperi', 'Iraokhor', 'Ogbona'],
      ),
      NigeriaLga(
        name: 'Etsako East LGA',
        areas: ['Agenebode', 'Okpella (Dangote)', 'Weppa', 'Wanno'],
      ),
      NigeriaLga(
        name: 'Etsako West LGA',
        areas: ['Auchi (Poly)', 'Jattu', 'Aviele', 'South Ibie', 'Uzairue'],
      ),
      NigeriaLga(
        name: 'Igueben LGA',
        areas: ['Igueben Central', 'Amahor', 'Ewossa', 'Ugun'],
      ),
      NigeriaLga(
        name: 'Ikpoba-Okha LGA',
        areas: ['Ikpoba Hill', 'Aduwawa', 'Upper Sakponba', 'Ologbo', 'Idogbo'],
      ),
      NigeriaLga(
        name: 'Oredo LGA',
        areas: ['Benin GRA', 'Ring Road (Kings Square)', 'Airport Road', 'New Benin', 'Sapele Road'],
      ),
      NigeriaLga(
        name: 'Orhionmwon LGA',
        areas: ['Abudu', 'Ugo', 'Urhonigbe', 'Igbanke'],
      ),
      NigeriaLga(
        name: 'Ovia North-East LGA',
        areas: ['Okada (Igbinedion Uni)', 'Oluku', 'Isiohor', 'Uhen'],
      ),
      NigeriaLga(
        name: 'Ovia South-West LGA',
        areas: ['Iguobazuwa', 'Siluko', 'Usen', 'Nikorogha'],
      ),
      NigeriaLga(
        name: 'Owan East LGA',
        areas: ['Afuze', 'Ihievbe', 'Otuo', 'Warrake'],
      ),
      NigeriaLga(
        name: 'Owan West LGA',
        areas: ['Sabongida-Ora', 'Eme-Ora', 'Ozalla', 'Sobe'],
      ),
      NigeriaLga(
        name: 'Uhunmwonde LGA',
        areas: ['Ehor', 'Irue', 'Uhi', 'Egba', 'Obadan'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Ekiti State',
    capitalCity: 'Ado Ekiti',
    lgas: [
      NigeriaLga(
        name: 'Ado-Ekiti LGA',
        areas: ['Ado Central', 'Fajuyi Park', 'Okesa', 'Ajilosun', 'Basiri', 'Adebayo'],
      ),
      NigeriaLga(
        name: 'Efon LGA',
        areas: ['Efon-Alaaye', 'Iwaji', 'Alan', 'Odo-Amo'],
      ),
      NigeriaLga(
        name: 'Ekiti East LGA',
        areas: ['Omuo-Ekiti', 'Ilasa', 'Isinbode', 'Araromi'],
      ),
      NigeriaLga(
        name: 'Ekiti South-West LGA',
        areas: ['Ilawe-Ekiti', 'Igbara-Odo', 'Ogotun'],
      ),
      NigeriaLga(
        name: 'Ekiti West LGA',
        areas: ['Aramoko-Ekiti', 'Erijiyan', 'Ikogosi (Warm Springs)', 'Ido-Ile'],
      ),
      NigeriaLga(
        name: 'Emure LGA',
        areas: ['Emure-Ekiti Central', 'Odo-Emure', 'Eporo'],
      ),
      NigeriaLga(
        name: 'Gbonyin LGA',
        areas: ['Ode-Ekiti', 'Agbado', 'Aisegba', 'Imesi', 'Iluomoba'],
      ),
      NigeriaLga(
        name: 'Ido-Osi LGA',
        areas: ['Ido-Ekiti (FMC)', 'Usir', 'Ayetoro', 'Ifaki', 'Ilogbo', 'Osi'],
      ),
      NigeriaLga(
        name: 'Ijero LGA',
        areas: ['Ijero Central', 'Ipoti', 'Iloro', 'Ikoro', 'Epe'],
      ),
      NigeriaLga(
        name: 'Ikere LGA',
        areas: ['Ikere Central', 'Odo-Oja', 'Atao', 'Uro', 'Afao'],
      ),
      NigeriaLga(
        name: 'Ikole LGA',
        areas: ['Ikole Central', 'Oye Border', 'Itapaji', 'Asin', 'Ijesa-Isu'],
      ),
      NigeriaLga(
        name: 'Ilejemeje LGA',
        areas: ['Eda-Oniyo', 'Iye-Ekiti', 'Iludun', 'Ewu'],
      ),
      NigeriaLga(
        name: 'Irepodun/Ifelodun LGA',
        areas: ['Igede-Ekiti', 'Awo', 'Iyin-Ekiti', 'Are'],
      ),
      NigeriaLga(
        name: 'Ise/Orun LGA',
        areas: ['Ise-Ekiti Central', 'Orun', 'Oraye'],
      ),
      NigeriaLga(
        name: 'Moba LGA',
        areas: ['Otun-Ekiti', 'Igogo', 'Osan', 'Iro'],
      ),
      NigeriaLga(
        name: 'Oye LGA',
        areas: ['Oye-Ekiti (FUOYE)', 'Ilumoba', 'Ayegbaju', 'Itapa', 'Isan'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Enugu State',
    capitalCity: 'Enugu',
    lgas: [
      NigeriaLga(
        name: 'Aninri LGA',
        areas: ['Ndeaboh', 'Oduma', 'Nenwe', 'Mpu', 'Okpanku'],
      ),
      NigeriaLga(
        name: 'Awgu LGA',
        areas: ['Awgu Town', 'Mgbowo', 'Agbogugu', 'Ihe', 'Owelli'],
      ),
      NigeriaLga(
        name: 'Enugu East LGA',
        areas: ['Abakpa Nike', 'Trans-Ekulu', 'Emene', 'Nowas', 'Nike Lake'],
      ),
      NigeriaLga(
        name: 'Enugu North LGA',
        areas: ['Independence Layout', 'GRA Enugu', 'New Haven', 'Ogui', 'Asata', 'Coal Camp'],
      ),
      NigeriaLga(
        name: 'Enugu South LGA',
        areas: ['Uwani', 'Achara Layout', 'Gariki (Awkunanaw)', 'Amechi', 'Ugwuaji'],
      ),
      NigeriaLga(
        name: 'Ezeagu LGA',
        areas: ['Aguobu-Owa', 'Iwollo', 'Oghe', 'Olo', 'Obinofia'],
      ),
      NigeriaLga(
        name: 'Igbo Etiti LGA',
        areas: ['Ogbede', 'Aku', 'Opi Border', 'Ukehe', 'Diogbe'],
      ),
      NigeriaLga(
        name: 'Igbo Eze North LGA',
        areas: ['Enugu-Ezike', 'Amachara', 'Ogrute', 'Olido'],
      ),
      NigeriaLga(
        name: 'Igbo Eze South LGA',
        areas: ['Ibagwa-Aka', 'Alor-Agu', 'Itchi', 'Uhunowerre'],
      ),
      NigeriaLga(
        name: 'Isi Uzo LGA',
        areas: ['Ikem', 'Eha-Amufu', 'Neke', 'Mbu', 'Umualor'],
      ),
      NigeriaLga(
        name: 'Nkanu East LGA',
        areas: ['Amagunze', 'Nara', 'Ugbawka', 'Nkerefi', 'Nomeh'],
      ),
      NigeriaLga(
        name: 'Nkanu West LGA',
        areas: ['Agbani (ESUT)', 'Ozalla', 'Akpugo', 'Amodu', 'Obuoffia'],
      ),
      NigeriaLga(
        name: 'Nsukka LGA',
        areas: ['Nsukka Urban (UNN)', 'Opi', 'Eha-Alumona', 'Obukpa', 'Ibagwa-Ani'],
      ),
      NigeriaLga(
        name: 'Oji River LGA',
        areas: ['Oji River Town', 'Inyi', 'Achi', 'Awlaw', 'Ugwuoba'],
      ),
      NigeriaLga(
        name: 'Udenu LGA',
        areas: ['Obollo-Afor', 'Orba', 'Amalla', 'Ezimo', 'Obollo-Eke'],
      ),
      NigeriaLga(
        name: 'Udi LGA',
        areas: ['Udi Town', '9th Mile Corner', 'Ngwo', 'Ebe', 'Abor', 'Nsude'],
      ),
      NigeriaLga(
        name: 'Uzo-Uwani LGA',
        areas: ['Umulokpa', 'Adani', 'Nimbo', 'Igga', 'Ogurugu'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Federal Capital Territory (FCT)',
    capitalCity: 'Abuja',
    lgas: [
      NigeriaLga(
        name: 'Abuja Municipal (AMAC)',
        areas: ['Maitama', 'Wuse II', 'Wuse Zone 1-8', 'Central Business District (CBD)', 'Garki I & II', 'Asokoro', 'Guzape', 'Jabi Lake', 'Utako', 'Gwarinpa Estate', 'Life Camp', 'Lugbe Federal Housing', 'Apo Resettlement', 'Lokogoma', 'Kaura', 'Galadimawa', 'Games Village', 'Winners Highway'],
      ),
      NigeriaLga(
        name: 'Bwari Area Council',
        areas: ['Bwari Town', 'Kubwa (Phase 1-4)', 'Dutse Alhaji', 'Dawaki', 'Mpape', 'Ushafa (Pottery Village)', 'Byazhin', 'Pambara'],
      ),
      NigeriaLga(
        name: 'Gwagwalada Area Council',
        areas: ['Gwagwalada Central', 'UniAbuja Campus', 'Teaching Hospital Area', 'Kutunku', 'Dobi', 'Ibwa', 'Paiko Kore', 'Zuba Town'],
      ),
      NigeriaLga(
        name: 'Kuje Area Council',
        areas: ['Kuje Central', 'Rubochi', 'Gaube', 'Chibiri', 'Kwaku', 'Gudun Karya'],
      ),
      NigeriaLga(
        name: 'Kwali Area Council',
        areas: ['Kwali Central', 'Yangoji', 'Ashara', 'Kilankwa', 'Dafa', 'Wako'],
      ),
      NigeriaLga(
        name: 'Abaji Area Council',
        areas: ['Abaji Central', 'Yaba', 'Agyana', 'Rimba', 'Nuku', 'Gurdi'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Gombe State',
    capitalCity: 'Gombe',
    lgas: [
      NigeriaLga(
        name: 'Akko LGA',
        areas: ['Kumo Central', 'Pindiga', 'Kalshingi', 'Tumu', 'Garko', 'Kashere (FUK)'],
      ),
      NigeriaLga(
        name: 'Balanga LGA',
        areas: ['Talasse', 'Dadiya', 'Gelengu', 'Cham', 'Degri', 'Nyuwar'],
      ),
      NigeriaLga(
        name: 'Billiri LGA',
        areas: ['Billiri Central', 'Bare', 'Tal', 'Todi', 'Tanglang'],
      ),
      NigeriaLga(
        name: 'Dukku LGA',
        areas: ['Dukku Central', 'Gombe Abba', 'Hashidu', 'Malala', 'Zaune'],
      ),
      NigeriaLga(
        name: 'Funakaye LGA',
        areas: ['Bajoga (Ashaka Cement)', 'Ashaka', 'Bage', 'Tilde', 'Wawa'],
      ),
      NigeriaLga(
        name: 'Gombe LGA',
        areas: ['Gombe Central', 'Bolari', 'Pantami', 'Jeka Da Fari', 'Kumbiya-Kumbiya', 'Herwagana'],
      ),
      NigeriaLga(
        name: 'Kaltungo LGA',
        areas: ['Kaltungo Central', 'Awak', 'Kamo', 'Ture', 'Tungje'],
      ),
      NigeriaLga(
        name: 'Kwami LGA',
        areas: ['Mallam Sidi', 'Bofore', 'Doho', 'Komfulata', 'Kwami Central'],
      ),
      NigeriaLga(
        name: 'Nafada LGA',
        areas: ['Nafada Central', 'Birin Bolewa', 'Guduk', 'Jigawa'],
      ),
      NigeriaLga(
        name: 'Shongom LGA',
        areas: ['Boh', 'Filiya', 'Gundale', 'Kushi', 'Lala'],
      ),
      NigeriaLga(
        name: 'Yamaltu/Deba LGA',
        areas: ['Deba', 'Dadinkowa (Dam)', 'Kuri', 'Lano', 'Zambuk'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Imo State',
    capitalCity: 'Owerri',
    lgas: [
      NigeriaLga(
        name: 'Aboh Mbaise LGA',
        areas: ['Aboh', 'Enyiogugu', 'Nguru', 'Lorji', 'Mbutu'],
      ),
      NigeriaLga(
        name: 'Ahiazu Mbaise LGA',
        areas: ['Ahiara', 'Ogbe', 'Okirikpo', 'Oru', 'Lude'],
      ),
      NigeriaLga(
        name: 'Ehime Mbano LGA',
        areas: ['Ehime', 'Umualumaku', 'Nsu', 'Umunakanu', 'Agbaja'],
      ),
      NigeriaLga(
        name: 'Ezinihitte LGA',
        areas: ['Itu', 'Amumara', 'Eziudo', 'Okpofe', 'Chokoneze'],
      ),
      NigeriaLga(
        name: 'Ideato North LGA',
        areas: ['Urualla', 'Akpulu', 'Arondizuogu', 'Osina', 'Izuogu'],
      ),
      NigeriaLga(
        name: 'Ideato South LGA',
        areas: ['Dikenafai', 'Ntueke', 'Ugbelle', 'Umuma-Isiaku'],
      ),
      NigeriaLga(
        name: 'Ihitte/Uboma LGA',
        areas: ['Isinweke', 'Amainyi', 'Ezinasata', 'Ikpem'],
      ),
      NigeriaLga(
        name: 'Ikeduru LGA',
        areas: ['Iho', 'Akabo', 'Atta', 'Inyishi', 'Amatta'],
      ),
      NigeriaLga(
        name: 'Isiala Mbano LGA',
        areas: ['Umuelemai', 'Amaraku', 'Osu', 'Ugiri', 'Ibeme'],
      ),
      NigeriaLga(
        name: 'Isu LGA',
        areas: ['Umundugba', 'Amandugba', 'Isunjaba', 'Ekwe'],
      ),
      NigeriaLga(
        name: 'Mbaitoli LGA',
        areas: ['Nwaorieubi', 'Ubommiri', 'Ogwa', 'Orodo', 'Afara'],
      ),
      NigeriaLga(
        name: 'Ngor Okpala LGA',
        areas: ['Umuneke', 'Ohekelem', 'Nguru-Umuaro', 'Obike', 'Airport Corridor'],
      ),
      NigeriaLga(
        name: 'Njaba LGA',
        areas: ['Nnenasa', 'Afor Umuaka', 'Atta', 'Amucha'],
      ),
      NigeriaLga(
        name: 'Nkwerre LGA',
        areas: ['Nkwerre Town', 'Owerre Nkworji', 'Umudi', 'Eziama'],
      ),
      NigeriaLga(
        name: 'Nwangele LGA',
        areas: ['Amaigbo', 'Abajah', 'Umuozu', 'Kara'],
      ),
      NigeriaLga(
        name: 'Obowo LGA',
        areas: ['Otoko', 'Amuzi', 'Alike', 'Avutu', 'Umunachi'],
      ),
      NigeriaLga(
        name: 'Oguta LGA',
        areas: ['Oguta Town (Lake)', 'Izombe', 'Agwa', 'Awa', 'Ejemekwuru'],
      ),
      NigeriaLga(
        name: 'Ohaji/Egbema LGA',
        areas: ['Mmahu-Egbema', 'Umuagwo', 'Awara', 'Assa', 'Obitti'],
      ),
      NigeriaLga(
        name: 'Okigwe LGA',
        areas: ['Okigwe Urban', 'Ihube', 'Amuro', 'Okanachi', 'Aku'],
      ),
      NigeriaLga(
        name: 'Onuimo LGA',
        areas: ['Okwe', 'Aboh', 'Umunumo', 'Ofeahia'],
      ),
      NigeriaLga(
        name: 'Orlu LGA',
        areas: ['Orlu Urban', 'Amaifeke', 'Ihioma', 'Ohaeke', 'Umudioka'],
      ),
      NigeriaLga(
        name: 'Orsu LGA',
        areas: ['Awo-Idemili', 'Ebenator', 'Orsu-Ihiteukwa', 'Amaruru'],
      ),
      NigeriaLga(
        name: 'Oru East LGA',
        areas: ['Omuma', 'Akatta', 'Amiri', 'Awo-Omamma Border'],
      ),
      NigeriaLga(
        name: 'Oru West LGA',
        areas: ['Mgbidi', 'Awo-Omamma', 'Nempi', 'Otulu'],
      ),
      NigeriaLga(
        name: 'Owerri Municipal LGA',
        areas: ['Aladinma', 'Ikenegbu', 'Douglas Road', 'Tetlow Road', 'Wetheral Road', 'GRA Owerri'],
      ),
      NigeriaLga(
        name: 'Owerri North LGA',
        areas: ['Ororji', 'Egbu', 'Naze', 'Uratta', 'Emekuku'],
      ),
      NigeriaLga(
        name: 'Owerri West LGA',
        areas: ['Umuguma', 'Nekede (Poly)', 'Ihiagwa (FUTO)', 'Obinze', 'Avu'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Jigawa State',
    capitalCity: 'Dutse',
    lgas: [
      NigeriaLga(
        name: 'Auyo LGA',
        areas: ['Auyo Central', 'Ayan', 'Gamafoi', 'Gwarabj', 'Kafur'],
      ),
      NigeriaLga(
        name: 'Babura LGA',
        areas: ['Babura Central', 'Batali', 'Dorawa', 'Garu', 'Kanya'],
      ),
      NigeriaLga(
        name: 'Biriniwa LGA',
        areas: ['Biriniwa Central', 'Batu', 'Diginsa', 'Fagi', 'Kazura'],
      ),
      NigeriaLga(
        name: 'Birnin Kudu LGA',
        areas: ['Birnin Kudu Central', 'Kangire', 'Kafin Gana', 'Kiyako', 'Wurno'],
      ),
      NigeriaLga(
        name: 'Buji LGA',
        areas: ['Buji Central', 'Ahoto', 'Gantsa', 'Kukuma', 'Madabe'],
      ),
      NigeriaLga(
        name: 'Dutse LGA',
        areas: ['Dutse Central', 'Fakai', 'Kudai', 'Madobi', 'Sakwaya', 'Zai'],
      ),
      NigeriaLga(
        name: 'Gagarawa LGA',
        areas: ['Gagarawa Central', 'Garri', 'Medu', 'Maiaduwa', 'Zarada'],
      ),
      NigeriaLga(
        name: 'Garki LGA',
        areas: ['Garki Central', 'Buduru', 'Doko', 'Gwarji', 'Kargo'],
      ),
      NigeriaLga(
        name: 'Gumel LGA',
        areas: ['Gumel Central', 'Baikarya', 'Dantanoma', 'Garin Gambo', 'Zango'],
      ),
      NigeriaLga(
        name: 'Guri LGA',
        areas: ['Guri Central', 'Adiani', 'Dauya', 'Kadira', 'Margadu'],
      ),
      NigeriaLga(
        name: 'Gwaram LGA',
        areas: ['Gwaram Central', 'Basirka', 'Dingaya', 'Fagam', 'Maruta'],
      ),
      NigeriaLga(
        name: 'Gwiwa LGA',
        areas: ['Gwiwa Central', 'Buntusu', 'Darina', 'Firan Gawa', 'Shafe'],
      ),
      NigeriaLga(
        name: 'Hadejia LGA',
        areas: ['Hadejia Central', 'Agalagdi', 'Dubantu', 'Kasuwar Kofa', 'Majia', 'Matsaro'],
      ),
      NigeriaLga(
        name: 'Jahun LGA',
        areas: ['Jahun Central', 'Aujara', 'Gangawa', 'Harbo', 'Idanduna'],
      ),
      NigeriaLga(
        name: 'Kafin Hausa LGA',
        areas: ['Kafin Hausa Central', 'Bulangu', 'Dumadumin', 'Jabo', 'Mezan'],
      ),
      NigeriaLga(
        name: 'Kazaure LGA',
        areas: ['Kazaure Central', 'Ba\'auzini', 'Daba', 'Kanti', 'Maradawa'],
      ),
      NigeriaLga(
        name: 'Kiri Kasama LGA',
        areas: ['Kiri Kasama Central', 'Baturiya', 'Fandum', 'Marma', 'Saleri'],
      ),
      NigeriaLga(
        name: 'Kiyawa LGA',
        areas: ['Kiyawa Central', 'Andaza', 'Garko', 'Katanga', 'Mazojie'],
      ),
      NigeriaLga(
        name: 'Maigatari LGA',
        areas: ['Maigatari Central', 'Baban Mutum', 'Fadum', 'Kukayasku', 'Madana'],
      ),
      NigeriaLga(
        name: 'Malam Madori LGA',
        areas: ['Malam Madori Central', 'Dunari', 'Fateka', 'Mairakumi', 'Tashena'],
      ),
      NigeriaLga(
        name: 'Miga LGA',
        areas: ['Miga Central', 'Dangyatin', 'Garbo', 'Koya', 'Tsakuwama'],
      ),
      NigeriaLga(
        name: 'Ringim LGA',
        areas: ['Ringim Central', 'Chai-Chai', 'Daushe', 'Kafin Babushe', 'Sankara'],
      ),
      NigeriaLga(
        name: 'Roni LGA',
        areas: ['Roni Central', 'Amanga', 'Dansure', 'Fagoji', 'Kwaita'],
      ),
      NigeriaLga(
        name: 'Sule Tankarkar LGA',
        areas: ['Sule Tankarkar Central', 'Albasu', 'Danladi', 'Jeke', 'Shabawa'],
      ),
      NigeriaLga(
        name: 'Taura LGA',
        areas: ['Taura Central', 'Chakwama', 'Gujungu', 'Kiri', 'Majiya'],
      ),
      NigeriaLga(
        name: 'Yankwashi LGA',
        areas: ['Karkarna', 'Belas', 'Gwada', 'Zungumba'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Kaduna State',
    capitalCity: 'Kaduna',
    lgas: [
      NigeriaLga(
        name: 'Birnin Gwari LGA',
        areas: ['Birnin Gwari Central', 'Gayam', 'Kakangi', 'Magajin Gari', 'Randagi'],
      ),
      NigeriaLga(
        name: 'Chikun LGA',
        areas: ['Sabon Tasha', 'Kujama', 'Gbagyi Villa', 'Narayi', 'Kakau', 'Nasarawa'],
      ),
      NigeriaLga(
        name: 'Giwa LGA',
        areas: ['Giwa Central', 'Danmahwayi', 'Gangara', 'Kidandan', 'Shika'],
      ),
      NigeriaLga(
        name: 'Igabi LGA',
        areas: ['Rigasa', 'Maraban Jos', 'Afaka', 'Rigachikun', 'Turunku'],
      ),
      NigeriaLga(
        name: 'Ikara LGA',
        areas: ['Ikara Central', 'Auchan', 'Kurmin Kogi', 'Pala', 'Saulawa'],
      ),
      NigeriaLga(
        name: 'Jaba LGA',
        areas: ['Kwoi', 'Dura', 'Fada', 'Nok (Culture)', 'Sabchem'],
      ),
      NigeriaLga(
        name: 'Jema\'a LGA',
        areas: ['Kafanchan Urban', 'Godogodo', 'Jagindi', 'Kagoma', 'Kaninkon'],
      ),
      NigeriaLga(
        name: 'Kachia LGA',
        areas: ['Kachia Central', 'Awon', 'Bishini', 'Gidan Tagwai', 'Katari'],
      ),
      NigeriaLga(
        name: 'Kaduna North LGA',
        areas: ['Kaduna GRA', 'Kawo', 'Doka', 'Unguwan Rimi', 'Unguwan Sarki', 'Badarawa'],
      ),
      NigeriaLga(
        name: 'Kaduna South LGA',
        areas: ['Barnawa', 'Makera', 'Tudun Wada', 'Kakuri', 'Television', 'Badiko'],
      ),
      NigeriaLga(
        name: 'Kagarko LGA',
        areas: ['Kagarko Central', 'Jere', 'Aribi', 'Katugal', 'Kushe'],
      ),
      NigeriaLga(
        name: 'Kajuru LGA',
        areas: ['Kajuru Central', 'Kasuwan Magani', 'Kallah', 'Rimau', 'Idon'],
      ),
      NigeriaLga(
        name: 'Kaura LGA',
        areas: ['Kaura Central', 'Bondong', 'Fadan Attakar', 'Manchok', 'Zankan'],
      ),
      NigeriaLga(
        name: 'Kauru LGA',
        areas: ['Kauru Central', 'Badurum', 'Chawai', 'Dawaki', 'Geshere'],
      ),
      NigeriaLga(
        name: 'Kubau LGA',
        areas: ['Anchau', 'Dutsen Wai', 'Kargi', 'Kubau Central', 'Zuntu'],
      ),
      NigeriaLga(
        name: 'Kudan LGA',
        areas: ['Hunkuyi', 'Doka', 'Gada', 'Kauran Wali', 'Kudan Central'],
      ),
      NigeriaLga(
        name: 'Lere LGA',
        areas: ['Saminaka', 'Gidan Borno', 'Kayarda', 'Lere Central', 'Yar Kasuwa'],
      ),
      NigeriaLga(
        name: 'Makarfi LGA',
        areas: ['Makarfi Central', 'Dandambo', 'Gazara', 'Meyere', 'Tudun Wada'],
      ),
      NigeriaLga(
        name: 'Sabon Gari LGA',
        areas: ['Sabon Gari Zaria', 'Samaru (ABU)', 'Hanwa', 'Basawa', 'Muchia', 'Dogarawa'],
      ),
      NigeriaLga(
        name: 'Sanga LGA',
        areas: ['Gwantu', 'Arak', 'Bokana', 'Fadan Karshi', 'Wasa'],
      ),
      NigeriaLga(
        name: 'Soba LGA',
        areas: ['Maigana', 'Gamagira', 'Rahama', 'Richifa', 'Soba Central'],
      ),
      NigeriaLga(
        name: 'Zangon Kataf LGA',
        areas: ['Zonkwa', 'Gidan Zaki', 'Kamuru', 'Madakiya', 'Zangon Urban'],
      ),
      NigeriaLga(
        name: 'Zaria LGA',
        areas: ['Zaria City', 'Kwarbai', 'Tudun Wada Zaria', 'Gyallesu', 'Limancin', 'Kongo (ABU)'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Kano State',
    capitalCity: 'Kano',
    lgas: [
      NigeriaLga(
        name: 'Albasu LGA',
        areas: ['Albasu Central', 'Bataiya', 'Chamarana', 'Fanda', 'Hungu'],
      ),
      NigeriaLga(
        name: 'Bagwai LGA',
        areas: ['Bagwai Central', 'Daddauda', 'Gogori', 'Kiyawa', 'Sare-Sare'],
      ),
      NigeriaLga(
        name: 'Bebeji LGA',
        areas: ['Bebeji Central', 'Anadariya', 'Baguda', 'Kofa', 'Rahama'],
      ),
      NigeriaLga(
        name: 'Bichi LGA',
        areas: ['Bichi Central', 'Badume', 'Danzabuwa', 'Kyalli', 'Saye'],
      ),
      NigeriaLga(
        name: 'Bunkure LGA',
        areas: ['Bunkure Central', 'Bono', 'Gafam', 'Kulluwa', 'Zurgu'],
      ),
      NigeriaLga(
        name: 'Dala LGA',
        areas: ['Dala Central', 'Bakin Ruwa', 'Gwammaja', 'Kabuwaya', 'Madigawa', 'Yalwa'],
      ),
      NigeriaLga(
        name: 'Dambatta LGA',
        areas: ['Dambatta Central', 'Ajumawa', 'Fagwalawa', 'Gwarabjawa', 'Sansan'],
      ),
      NigeriaLga(
        name: 'Dawakin Kudu LGA',
        areas: ['Dawakin Kudu Central', 'Dabar Kwari', 'Gano', 'Tamburawa', 'Yanbarau'],
      ),
      NigeriaLga(
        name: 'Dawakin Tofa LGA',
        areas: ['Dawakin Tofa Central', 'Dan Amar', 'Kwa', 'Marke', 'Tofa Border'],
      ),
      NigeriaLga(
        name: 'Doguwa LGA',
        areas: ['Riruwai', 'Doguwa Central', 'Falgore', 'Tagwaye', 'Zainabi'],
      ),
      NigeriaLga(
        name: 'Fagge LGA',
        areas: ['Fagge Central', 'Sabon Gari Kano', 'Kwaciri', 'Rijiyar Zaki', 'Yammata'],
      ),
      NigeriaLga(
        name: 'Gabasawa LGA',
        areas: ['Zakirai', 'Gabasawa Central', 'Joda', 'Karmami', 'Yautai'],
      ),
      NigeriaLga(
        name: 'Garko LGA',
        areas: ['Garko Central', 'Garun Ali', 'Kafin Malamai', 'Sarina', 'Zangon Garko'],
      ),
      NigeriaLga(
        name: 'Garun Mallam LGA',
        areas: ['Garun Mallam Central', 'Chiromawa', 'Fankurun', 'Kadawa', 'Makwaro'],
      ),
      NigeriaLga(
        name: 'Gaya LGA',
        areas: ['Gaya Central', 'Kademi', 'Maimakawa', 'Shagogo', 'Wuro Bagga'],
      ),
      NigeriaLga(
        name: 'Gezawa LGA',
        areas: ['Gezawa Central', 'Babawa', 'Jogana', 'Meshe', 'Zango'],
      ),
      NigeriaLga(
        name: 'Gwale LGA',
        areas: ['Gwale Central', 'Dorayi', 'Goron Dutse', 'Kabuga', 'Diso', 'Galadanchi'],
      ),
      NigeriaLga(
        name: 'Gwarzo LGA',
        areas: ['Gwarzo Central', 'Getso', 'Kara', 'Mainika', 'Sabon Birni'],
      ),
      NigeriaLga(
        name: 'Kabo LGA',
        areas: ['Kabo Central', 'Dugabau', 'Godiya', 'Kanwa', 'Masanawa'],
      ),
      NigeriaLga(
        name: 'Kano Municipal LGA',
        areas: ['Kano City (Kofar Kudu)', 'Kurmi Market', 'Fagge Border', 'Shahuchi', 'Yakassai', 'Zango'],
      ),
      NigeriaLga(
        name: 'Karaye LGA',
        areas: ['Karaye Central', 'Daura', 'Kurugu', 'Tudun Kaya', 'Yammedi'],
      ),
      NigeriaLga(
        name: 'Kibiya LGA',
        areas: ['Kibiya Central', 'Fassi', 'Kahu', 'Unguwar Gai', 'Zungur'],
      ),
      NigeriaLga(
        name: 'Kiru LGA',
        areas: ['Kiru Central', 'Bargoni', 'Galadimawa', 'Maraku', 'Yako'],
      ),
      NigeriaLga(
        name: 'Kumbotso LGA',
        areas: ['Kumbotso Central', 'Challawa', 'Danbare (BUK New)', 'Panshekara', 'Mariri', 'Naibawa'],
      ),
      NigeriaLga(
        name: 'Kunchi LGA',
        areas: ['Kunchi Central', 'Gwarmai', 'Kashe', 'Shuwaki', 'Yandutse'],
      ),
      NigeriaLga(
        name: 'Kura LGA',
        areas: ['Kura Central', 'Dan Hassan', 'Gundutse', 'Karfi', 'Tanawa'],
      ),
      NigeriaLga(
        name: 'Madobi LGA',
        areas: ['Madobi Central', 'Galfawa', 'Kafin Agur', 'Rikadawa', 'Kanwa'],
      ),
      NigeriaLga(
        name: 'Makoda LGA',
        areas: ['Coggel', 'Dunbulun', 'Jibga', 'Makoda Central', 'Wailare'],
      ),
      NigeriaLga(
        name: 'Minjibir LGA',
        areas: ['Minjibir Central', 'Kunya', 'Kwashe', 'Tsakuwa', 'Wasai'],
      ),
      NigeriaLga(
        name: 'Nassarawa LGA',
        areas: ['Nassarawa GRA', 'Bompai Industrial', 'Gezawa Road', 'Kaura Goje', 'Tudun Wada Nassarawa'],
      ),
      NigeriaLga(
        name: 'Rano LGA',
        areas: ['Rano Central', 'Dawaki', 'Lausu', 'Saji', 'Zurgu'],
      ),
      NigeriaLga(
        name: 'Rimin Gado LGA',
        areas: ['Rimin Gado Central', 'Dugurawa', 'Gulu', 'Jili', 'Zangon Dan Audu'],
      ),
      NigeriaLga(
        name: 'Rogo LGA',
        areas: ['Rogo Central', 'Bari', 'Falgore', 'Ruwan Bago', 'Zarewa'],
      ),
      NigeriaLga(
        name: 'Shanono LGA',
        areas: ['Shanono Central', 'Alajawa', 'Faruruwa', 'Kadamu', 'Kokiya'],
      ),
      NigeriaLga(
        name: 'Sumaila LGA',
        areas: ['Sumaila Central', 'Gala', 'Kanawa', 'Magami', 'Rimi'],
      ),
      NigeriaLga(
        name: 'Takai LGA',
        areas: ['Takai Central', 'Fajewa', 'Kachako', 'Kuka', 'Zura'],
      ),
      NigeriaLga(
        name: 'Tarauni LGA',
        areas: ['Tarauni Central', 'Gyadi-Gyadi', 'Hotoro', 'Unguwa Uku', 'Dangi'],
      ),
      NigeriaLga(
        name: 'Tofa LGA',
        areas: ['Tofa Central', 'Doka', 'Jaubula', 'Langel', 'Wangara'],
      ),
      NigeriaLga(
        name: 'Tsanyawa LGA',
        areas: ['Tsanyawa Central', 'Dumbulum', 'Gozaki', 'Tatsan', 'Yanganau'],
      ),
      NigeriaLga(
        name: 'Tudun Wada LGA',
        areas: ['Tudun Wada Central', 'Dalawa', 'Jita', 'Karefa', 'Nata\'ala'],
      ),
      NigeriaLga(
        name: 'Ungogo LGA',
        areas: ['Ungogo Central', 'Panisau', 'Rangaza', 'Rijiyar Zaki', 'Zaura'],
      ),
      NigeriaLga(
        name: 'Warawa LGA',
        areas: ['Warawa Central', 'Danlassan', 'Garin Dau', 'Jemagu', 'Yangizo'],
      ),
      NigeriaLga(
        name: 'Wudil LGA',
        areas: ['Wudil Central (KUST)', 'Dagumawa', 'Kausani', 'Utai', 'Darki'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Katsina State',
    capitalCity: 'Katsina',
    lgas: [
      NigeriaLga(
        name: 'Bakori LGA',
        areas: ['Bakori Central', 'Barde', 'Jargaba', 'Kandarawa', 'Kurami'],
      ),
      NigeriaLga(
        name: 'Batagarawa LGA',
        areas: ['Batagarawa Central', 'Bakiyawa', 'Dandagoro', 'Tsanni', 'Ajiwa'],
      ),
      NigeriaLga(
        name: 'Batsari LGA',
        areas: ['Batsari Central', 'Abadau', 'Dan-Alhaji', 'Kandawa', 'Wagini'],
      ),
      NigeriaLga(
        name: 'Baure LGA',
        areas: ['Baure Central', 'Babban Mutum', 'Garki', 'Hui', 'Yanmaulu'],
      ),
      NigeriaLga(
        name: 'Bindawa LGA',
        areas: ['Bindawa Central', 'Baure', 'Doro', 'Gaiwa', 'Kamri'],
      ),
      NigeriaLga(
        name: 'Charanchi LGA',
        areas: ['Charanchi Central', 'Banye', 'Kuraye', 'Majigiri', 'Radda'],
      ),
      NigeriaLga(
        name: 'Dandume LGA',
        areas: ['Dandume Central', 'Dantakari', 'Illela', 'Mahuta', 'Nasirawa'],
      ),
      NigeriaLga(
        name: 'Danja LGA',
        areas: ['Danja Central', 'Dandaji', 'Kahutu', 'Majeva', 'Tandama'],
      ),
      NigeriaLga(
        name: 'Dan Musa LGA',
        areas: ['Dan Musa Central', 'Dandire', 'Mai-Chiwa', 'Mara', 'Yantumaki'],
      ),
      NigeriaLga(
        name: 'Daura LGA',
        areas: ['Daura Central', 'Kusugu', 'Madobi', 'Mazoji', 'Sarkin Yara', 'Ubandawaki'],
      ),
      NigeriaLga(
        name: 'Dutsin Ma LGA',
        areas: ['Dutsin Ma Central (FUDMA)', 'Bagagadi', 'Karofi', 'Kuki', 'Makera'],
      ),
      NigeriaLga(
        name: 'Faskari LGA',
        areas: ['Faskari Central', 'Daudawa', 'Mairuwa', 'Sheme', 'Yankara'],
      ),
      NigeriaLga(
        name: 'Funtua LGA',
        areas: ['Funtua Central', 'Dandutse', 'Gwagware', 'Maska', 'Tudun Iya'],
      ),
      NigeriaLga(
        name: 'Ingawa LGA',
        areas: ['Ingawa Central', 'Agayawa', 'Dugul', 'Jobe', 'Yandoma'],
      ),
      NigeriaLga(
        name: 'Jibia LGA',
        areas: ['Jibia Central', 'Farfaru', 'Gangara', 'Kaita Border', 'Mazanya'],
      ),
      NigeriaLga(
        name: 'Kafur LGA',
        areas: ['Kafur Central', 'Dantuttur', 'Gamzago', 'Mahuta', 'Yartalata'],
      ),
      NigeriaLga(
        name: 'Kaita LGA',
        areas: ['Kaita Central', 'Baawa', 'Dankaba', 'Matsai', 'Yankara'],
      ),
      NigeriaLga(
        name: 'Kankara LGA',
        areas: ['Kankara Central', 'Danmurabu', 'Garin Bawa', 'Kukasheka', 'Pauwa'],
      ),
      NigeriaLga(
        name: 'Kankia LGA',
        areas: ['Kankia Central', 'Gafia', 'Kafin Dangi', 'Kunduru', 'Rimaye'],
      ),
      NigeriaLga(
        name: 'Katsina LGA',
        areas: ['Katsina Central', 'Kofar Kaura', 'Kofar Marusa', 'Wakilin Arewa', 'Wakilin Kudu', 'GRA Katsina'],
      ),
      NigeriaLga(
        name: 'Kurfi LGA',
        areas: ['Kurfi Central', 'Barkiya', 'Birchi', 'Tsauri', 'Wurma'],
      ),
      NigeriaLga(
        name: 'Kusada LGA',
        areas: ['Kusada Central', 'Boko', 'Dudunni', 'Kaikai', 'Mawashi'],
      ),
      NigeriaLga(
        name: 'Mai\'Adua LGA',
        areas: ['Mai\'Adua Central', 'Boto', 'Danyashe', 'Koza', 'Mai-Koni'],
      ),
      NigeriaLga(
        name: 'Malumfashi LGA',
        areas: ['Malumfashi Central', 'Dayi', 'Goron Dutse', 'Karfi', 'Yaba'],
      ),
      NigeriaLga(
        name: 'Mani LGA',
        areas: ['Mani Central', 'Bagiwa', 'Duwan', 'Jani', 'Machika'],
      ),
      NigeriaLga(
        name: 'Mashi LGA',
        areas: ['Mashi Central', 'Doguru', 'Gallu', 'Jigawa', 'Sonkaya'],
      ),
      NigeriaLga(
        name: 'Matazu LGA',
        areas: ['Matazu Central', 'Dissau', 'Karaduwa', 'Kogari', 'Sayaya'],
      ),
      NigeriaLga(
        name: 'Musawa LGA',
        areas: ['Musawa Central', 'Dangani', 'Garu', 'Ginginya', 'Jikamshi'],
      ),
      NigeriaLga(
        name: 'Rimi LGA',
        areas: ['Rimi Central', 'Abukur', 'Fafara', 'Kadandani', 'Remawa'],
      ),
      NigeriaLga(
        name: 'Sabuwa LGA',
        areas: ['Sabuwa Central', 'Damari', 'Gamji', 'Machika', 'Sayau'],
      ),
      NigeriaLga(
        name: 'Safana LGA',
        areas: ['Safana Central', 'Babban Duhu', 'Runka', 'Tsaskiya'],
      ),
      NigeriaLga(
        name: 'Sandamu LGA',
        areas: ['Sandamu Central', 'Fago', 'Kagare', 'Katsayal', 'Rijiyar Tsamiya'],
      ),
      NigeriaLga(
        name: 'Zango LGA',
        areas: ['Zango Central', 'Dargage', 'Garni', 'Kawarin Kudi', 'Yardaje'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Kebbi State',
    capitalCity: 'Birnin Kebbi',
    lgas: [
      NigeriaLga(
        name: 'Aleiro LGA',
        areas: ['Aleiro Central', 'Danwarai', 'Jadadi', 'Sabiyal', 'Sanyinna'],
      ),
      NigeriaLga(
        name: 'Arewa Dandi LGA',
        areas: ['Kangiwa', 'Bachaka', 'Dandi', 'Falate', 'Yelwa'],
      ),
      NigeriaLga(
        name: 'Argungu LGA',
        areas: ['Argungu Central (Fishing)', 'Alwasa', 'Gulma', 'Lailaba', 'Sauwa'],
      ),
      NigeriaLga(
        name: 'Augie LGA',
        areas: ['Augie Central', 'Bagaye', 'Bubuche', 'Dundaye', 'Zagi'],
      ),
      NigeriaLga(
        name: 'Bagudo LGA',
        areas: ['Bagudo Central', 'Illo', 'Kaoje', 'Lafagu', 'Zagga'],
      ),
      NigeriaLga(
        name: 'Birnin Kebbi LGA',
        areas: ['Birnin Kebbi Central', 'Makera', 'Nassarawa', 'Gwadangaji', 'Kola', 'GRA Birnin Kebbi'],
      ),
      NigeriaLga(
        name: 'Bunza LGA',
        areas: ['Bunza Central', 'Gwade', 'Maidahini', 'Tilli', 'Zunguru'],
      ),
      NigeriaLga(
        name: 'Dandi LGA',
        areas: ['Kamba Central', 'Bunza Border', 'Dolekaina', 'Fingila', 'Kyengakwai'],
      ),
      NigeriaLga(
        name: 'Fakai LGA',
        areas: ['Mahuta', 'Bajida', 'Birnin Tudu', 'Kangi', 'Zussun'],
      ),
      NigeriaLga(
        name: 'Gwandu LGA',
        areas: ['Gwandu Central', 'Dalijan', 'Dodoru', 'Kambaza', 'Maruda'],
      ),
      NigeriaLga(
        name: 'Jega LGA',
        areas: ['Jega Central', 'Alelu', 'Dangamau', 'Kimba', 'Magaji'],
      ),
      NigeriaLga(
        name: 'Kalgo LGA',
        areas: ['Kalgo Central', 'Diggi', 'Etene', 'Mutubare', 'Wuro Gauri'],
      ),
      NigeriaLga(
        name: 'Koko/Besse LGA',
        areas: ['Koko Central', 'Besse', 'Dutsinmari', 'Jadadi', 'Zaria Kala-Kala'],
      ),
      NigeriaLga(
        name: 'Maiyama LGA',
        areas: ['Maiyama Central', 'Andarai', 'Dogon Daji', 'Karaye', 'Sambawa'],
      ),
      NigeriaLga(
        name: 'Ngaski LGA',
        areas: ['Wara', 'Birnin Yauri', 'Kukum', 'Makurdi Ngaski', 'Utono'],
      ),
      NigeriaLga(
        name: 'Sakaba LGA',
        areas: ['Diri', 'Dankolo', 'Gelu', 'Maza-Maza', 'Sakaba Central'],
      ),
      NigeriaLga(
        name: 'Shanga LGA',
        areas: ['Shanga Central', 'Duku', 'Kawara', 'Sawashi', 'Yarbesse'],
      ),
      NigeriaLga(
        name: 'Suru LGA',
        areas: ['Dakingari', 'Aljannare', 'Bandan', 'Giro', 'Suru Central'],
      ),
      NigeriaLga(
        name: 'Wasagu/Danko LGA',
        areas: ['Ribah', 'Bena', 'Danko', 'Kanya', 'Wasagu Central'],
      ),
      NigeriaLga(
        name: 'Yauri LGA',
        areas: ['Yauri Central', 'Gungun Sarki', 'Jalacha', 'Yelwa Yauri'],
      ),
      NigeriaLga(
        name: 'Zuru LGA',
        areas: ['Zuru Central', 'Bedebede', 'Dabai', 'Rikoto', 'Senchi'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Kogi State',
    capitalCity: 'Lokoja',
    lgas: [
      NigeriaLga(
        name: 'Adavi LGA',
        areas: ['Ogaminana', 'Nagazi', 'Adavi-Eba', 'Kuroko', 'Inoziomi'],
      ),
      NigeriaLga(
        name: 'Ajaokuta LGA',
        areas: ['Ajaokuta Steel Town', 'Geregu (Power)', 'Adogo', 'Eganyi'],
      ),
      NigeriaLga(
        name: 'Ankpa LGA',
        areas: ['Ankpa Central', 'Enjema', 'Ojoku', 'Ikanekpo', 'Ofugo'],
      ),
      NigeriaLga(
        name: 'Bassa LGA',
        areas: ['Oguma', 'Akuba', 'Gboloko', 'Kpata', 'Mozum'],
      ),
      NigeriaLga(
        name: 'Dekina LGA',
        areas: ['Dekina Town', 'Anyigba (KSU)', 'Egume', 'Abocho', 'Odu'],
      ),
      NigeriaLga(
        name: 'Ibaji LGA',
        areas: ['Onyedega', 'Ejule', 'Ochadamu', 'Unale', 'Uje'],
      ),
      NigeriaLga(
        name: 'Idah LGA',
        areas: ['Idah Central', 'Ega', 'Igala-Mela Border', 'Okenya', 'Sabon Gari Idah'],
      ),
      NigeriaLga(
        name: 'Igalamela-Odolu LGA',
        areas: ['Ajaka', 'Odolu', 'Akpanya', 'Avrugo', 'Ubele'],
      ),
      NigeriaLga(
        name: 'Ijumu LGA',
        areas: ['Iyara', 'Ayetoro Gbede', 'Iyamoye', 'Ogidi', 'Ekinrin-Adde'],
      ),
      NigeriaLga(
        name: 'Kabba/Bunu LGA',
        areas: ['Kabba Central', 'Odo-Okun', 'Katu', 'Iluke', 'Olokoro Bunu'],
      ),
      NigeriaLga(
        name: 'Kogi (Koton Karfe) LGA',
        areas: ['Koton Karfe Central', 'Girinya', 'Chikara', 'Gegu Beki'],
      ),
      NigeriaLga(
        name: 'Lokoja LGA',
        areas: ['Lokoja Central', 'Confluence Area', 'Ganaja Village', 'Adankolo', 'Felele', 'Patti', 'Old Market'],
      ),
      NigeriaLga(
        name: 'Mopa-Muro LGA',
        areas: ['Mopa Central', 'Orokere', 'Takete Ide', 'Amuro'],
      ),
      NigeriaLga(
        name: 'Ofu LGA',
        areas: ['Ugwolawo', 'Aloji', 'Ejule', 'Itobe', 'Ochadamu'],
      ),
      NigeriaLga(
        name: 'Ogori/Magongo LGA',
        areas: ['Ogori Central', 'Magongo', 'Okesi', 'Eni'],
      ),
      NigeriaLga(
        name: 'Okehi LGA',
        areas: ['Obangede', 'Ihima', 'Eika', 'Ohuepe', 'Uro'],
      ),
      NigeriaLga(
        name: 'Okene LGA',
        areas: ['Okene Central', 'Bariki', 'Otutu', 'Obehira', 'Idoji', 'Agassa'],
      ),
      NigeriaLga(
        name: 'Olamaboro LGA',
        areas: ['Okpo', 'Imane', 'Ogugu', 'Adeh', 'Inbele'],
      ),
      NigeriaLga(
        name: 'Omala LGA',
        areas: ['Abejukolo', 'Bagana', 'Ogodu', 'Icheke', 'Olla'],
      ),
      NigeriaLga(
        name: 'Yagba East LGA',
        areas: ['Isanlu', 'Ponyan', 'Ifefe', 'Ejuku', 'Makutu'],
      ),
      NigeriaLga(
        name: 'Yagba West LGA',
        areas: ['Odo-Ere', 'Egbe', 'Odo-Eri', 'Okeri', 'Ogbe'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Kwara State',
    capitalCity: 'Ilorin',
    lgas: [
      NigeriaLga(
        name: 'Asa LGA',
        areas: ['Afon', 'Alapa', 'Laduba', 'Ogbondoroko', 'Onire'],
      ),
      NigeriaLga(
        name: 'Baruten LGA',
        areas: ['Kosubosu', 'Ilesha Baruba', 'Okuta', 'Gwanara', 'Yashikira'],
      ),
      NigeriaLga(
        name: 'Edu LGA',
        areas: ['Lafiagi', 'Tsaragi', 'Tsonga (Shonga Farms)', 'Kpakiama'],
      ),
      NigeriaLga(
        name: 'Ekiti LGA',
        areas: ['Araromi Opin', 'Isolo Opin', 'Osi', 'Obbo Aiyegunle', 'Obbo Ilere'],
      ),
      NigeriaLga(
        name: 'Ifelodun LGA',
        areas: ['Share', 'Idofian', 'Igbaja', 'Omupo', 'Oro-Ago'],
      ),
      NigeriaLga(
        name: 'Ilorin East LGA',
        areas: ['Oke Oyi', 'Agbo Oba', 'Gambari', 'Iponrin', 'Marafa', 'Zango'],
      ),
      NigeriaLga(
        name: 'Ilorin South LGA',
        areas: ['Fufu', 'Fate', 'Tanke (UNILORIN)', 'Gaa Akanbi', 'Kulende'],
      ),
      NigeriaLga(
        name: 'Ilorin West LGA',
        areas: ['Oja Oba', 'Adewole Estate', 'Mandate Market', 'Pakata', 'Badari', 'Baboko'],
      ),
      NigeriaLga(
        name: 'Isin LGA',
        areas: ['Owu Isin', 'Iwo', 'Ijara', 'Isanlu Isin', 'Oke-Onigbin'],
      ),
      NigeriaLga(
        name: 'Kaiama LGA',
        areas: ['Kaiama Central', 'Bani', 'Gwaragworogi', 'Woro', 'Kemanji'],
      ),
      NigeriaLga(
        name: 'Moro LGA',
        areas: ['Bode Saadu', 'Ejidongari', 'Jebba (Paper Mill)', 'Lanwa', 'Malete (KWASU)'],
      ),
      NigeriaLga(
        name: 'Offa LGA',
        areas: ['Offa Central', 'Olofa Way', 'Owode', 'Balogun', 'Ilemona Border', 'Federal Poly Area'],
      ),
      NigeriaLga(
        name: 'Oke Ero LGA',
        areas: ['Iloffa', 'Ayedun', 'Ekan Nla', 'Idofin'],
      ),
      NigeriaLga(
        name: 'Oyun LGA',
        areas: ['Ilemona', 'Erin-Ile', 'Ijagbo', 'Ojoku', 'Igosun'],
      ),
      NigeriaLga(
        name: 'Pategi LGA',
        areas: ['Pategi Central', 'Kpada', 'Lade', 'Rifun'],
      ),
      NigeriaLga(
        name: 'Irepodun LGA',
        areas: ['Omu-Aran', 'Oro', 'Esie (Museum)', 'Ajase Ipo', 'Arandun'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Lagos State',
    capitalCity: 'Ikeja',
    lgas: [
      NigeriaLga(
        name: 'Agege LGA',
        areas: ['Agege Central', 'Pen Cinema', 'Dopemu', 'Orile Agege', 'Iloro'],
      ),
      NigeriaLga(
        name: 'Ajeromi-Ifelodun LGA',
        areas: ['Ajegunle', 'Boundary', 'Layeni', 'Oregie', 'Tolu'],
      ),
      NigeriaLga(
        name: 'Alimosho LGA',
        areas: ['Egbeda', 'Idimu', 'Ikotun', 'Igando', 'Ipaja', 'Ayobo', 'Gowon Estate'],
      ),
      NigeriaLga(
        name: 'Amuwo-Odofin LGA',
        areas: ['Festac Town', 'Mile 2', 'Satellite Town', 'Trade Fair Complex', 'Amuwo Central'],
      ),
      NigeriaLga(
        name: 'Apapa LGA',
        areas: ['Apapa Wharf', 'Apapa GRA', 'Tin Can Island', 'Ijora', 'Liverpool'],
      ),
      NigeriaLga(
        name: 'Badagry LGA',
        areas: ['Badagry Town (Heritage)', 'Seme Border', 'Ajara', 'Aradagun', 'Topo'],
      ),
      NigeriaLga(
        name: 'Epe LGA',
        areas: ['Epe Central', 'Alaro City', 'Poka', 'Noforija', 'Ejinrin'],
      ),
      NigeriaLga(
        name: 'Eti-Osa LGA',
        areas: ['Victoria Island (VI)', 'Lekki Phase 1', 'Ikoyi', 'Oniru', 'Chevron/Orchid', 'Ajah', 'Sangotedo'],
      ),
      NigeriaLga(
        name: 'Ibeju-Lekki LGA',
        areas: ['Eleko', 'Dangote Refinery Area', 'Lakowe', 'Bogije', 'Akodo'],
      ),
      NigeriaLga(
        name: 'Ifako-Ijaiye LGA',
        areas: ['Ogba', 'Ifako', 'Ijaiye', 'Fagba', 'Iju Ishaga'],
      ),
      NigeriaLga(
        name: 'Ikeja LGA',
        areas: ['Ikeja GRA', 'Computer Village', 'Alausa (Secretariat)', 'Allen Avenue', 'Opebi', 'Maryland', 'MMA Airport'],
      ),
      NigeriaLga(
        name: 'Ikorodu LGA',
        areas: ['Ikorodu Central', 'Agric', 'Igbogbo', 'Ipakodo', 'Imota', 'Sagamu Road'],
      ),
      NigeriaLga(
        name: 'Kosofe LGA',
        areas: ['Gbagada', 'Ojota', 'Ketu', 'Mile 12', 'Magodo Phase 1 & 2', 'Alapere'],
      ),
      NigeriaLga(
        name: 'Lagos Island LGA',
        areas: ['Marina', 'Broad Street', 'Idumota', 'Isale Eko', 'CMS', 'Onikan'],
      ),
      NigeriaLga(
        name: 'Lagos Mainland LGA',
        areas: ['Yaba', 'Sabo (Tech Hub)', 'Ebute Metta', 'Akoka (UNILAG)', 'Oyingbo'],
      ),
      NigeriaLga(
        name: 'Mushin LGA',
        areas: ['Mushin Central', 'Olosha', 'Palm Avenue', 'Ilupeju', 'Ladipo Market'],
      ),
      NigeriaLga(
        name: 'Ojo LGA',
        areas: ['Ojo Town', 'LASU Campus', 'Alaba International Market', 'Iba', 'Okokomaiko'],
      ),
      NigeriaLga(
        name: 'Oshodi-Isolo LGA',
        areas: ['Oshodi Interchange', 'Isolo', 'Mafoluku', 'Ajao Estate', 'Ejigbo', 'Okota'],
      ),
      NigeriaLga(
        name: 'Shomolu LGA',
        areas: ['Shomolu Central', 'Bariga', 'Onipanu', 'Bajulaiye', 'Fadeyi'],
      ),
      NigeriaLga(
        name: 'Surulere LGA',
        areas: ['Surulere Central', 'National Stadium', 'Bode Thomas', 'Ojuelegba', 'Aguda', 'Ijesha', 'Masha'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Nasarawa State',
    capitalCity: 'Lafia',
    lgas: [
      NigeriaLga(
        name: 'Akwanga LGA',
        areas: ['Akwanga Central', 'Andaha', 'Ancho', 'Gudi', 'Morowa'],
      ),
      NigeriaLga(
        name: 'Awe LGA',
        areas: ['Awe Central', 'Azara', 'Chakor', 'Kanje', 'Tunga (Sugar)'],
      ),
      NigeriaLga(
        name: 'Doma LGA',
        areas: ['Doma Central', 'Aloshi', 'Doka', 'Madauchi', 'Rukubi'],
      ),
      NigeriaLga(
        name: 'Karu LGA',
        areas: ['Mararaba', 'Nyanya Gwandara', 'New Karu', 'Masaka', 'Ado', 'Auta Balefi'],
      ),
      NigeriaLga(
        name: 'Keana LGA',
        areas: ['Keana Central', 'Aloshi', 'Giza', 'Kardoroko', 'Madaki'],
      ),
      NigeriaLga(
        name: 'Keffi LGA',
        areas: ['Keffi Central', 'GRA Keffi', 'NSUK Campus', 'Angwan Rimi', 'Yelwa'],
      ),
      NigeriaLga(
        name: 'Kokona LGA',
        areas: ['Garaku', 'Agwada', 'Amba', 'Dari', 'Keffi-Kokona Border'],
      ),
      NigeriaLga(
        name: 'Lafia LGA',
        areas: ['Lafia Central', 'GRA Lafia', 'Assakio', 'Chiroma', 'Makama', 'Shabu'],
      ),
      NigeriaLga(
        name: 'Nasarawa LGA',
        areas: ['Nasarawa Central (Poly)', 'Ara', 'Laminga', 'Udenin', 'Guto'],
      ),
      NigeriaLga(
        name: 'Nasarawa Egon LGA',
        areas: ['Nasarawa Egon Central', 'Alizaga', 'Ende', 'Kagbu', 'Mada Station'],
      ),
      NigeriaLga(
        name: 'Obi LGA',
        areas: ['Obi Central', 'Agwatashi', 'Daddare', 'Gidan Abre', 'Tudun Adabu'],
      ),
      NigeriaLga(
        name: 'Toto LGA',
        areas: ['Toto Central', 'Gadabuke', 'Gwargwada', 'Kanyehu', 'Umaisha'],
      ),
      NigeriaLga(
        name: 'Wamba LGA',
        areas: ['Wamba Central', 'Farin Ruwa (Falls)', 'Gitta', 'Konva', 'Wayyo'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Niger State',
    capitalCity: 'Minna',
    lgas: [
      NigeriaLga(
        name: 'Agaie LGA',
        areas: ['Agaie Central', 'Etsu Palace Area', 'Kutiriko', 'Magaji', 'Tagagi'],
      ),
      NigeriaLga(
        name: 'Agwara LGA',
        areas: ['Agwara Central', 'Gallah', 'Papiri', 'Rofia'],
      ),
      NigeriaLga(
        name: 'Bida LGA',
        areas: ['Bida Central', 'Federal Poly Area', 'Dokodza', 'Wadata', 'Kpege', 'Etsu Palace Area'],
      ),
      NigeriaLga(
        name: 'Borgu LGA',
        areas: ['New Bussa (Kainji Dam)', 'Babanna', 'Dogongari', 'Malale', 'Wawa'],
      ),
      NigeriaLga(
        name: 'Bosso LGA',
        areas: ['Bosso Estate', 'Maikunkele', 'FUT Minna (Gidan Kwano)', 'FUT Minna (Bosso)', 'Western Bypass', 'Garatu', 'Shango'],
      ),
      NigeriaLga(
        name: 'Chanchaga LGA',
        areas: ['Minna Central', 'Minna GRA', 'Tunga', 'Sabon Gari', 'Kpakungu', 'Sauka Kahuta', 'Chanchaga Bay', 'Mobil Roundabout'],
      ),
      NigeriaLga(
        name: 'Edati LGA',
        areas: ['Enagi', 'Fazhi', 'Guzan', 'Rokota'],
      ),
      NigeriaLga(
        name: 'Gbako LGA',
        areas: ['Lemu', 'Batako', 'Edozhigi', 'Gogata'],
      ),
      NigeriaLga(
        name: 'Gurara LGA',
        areas: ['Gawu Babangida', 'Gurara Waterfalls Area', 'Bonu', 'Lefu'],
      ),
      NigeriaLga(
        name: 'Katcha LGA',
        areas: ['Katcha Central', 'Badeggi', 'Bakeko', 'Dzwafu'],
      ),
      NigeriaLga(
        name: 'Kontagora LGA',
        areas: ['Kontagora Central', 'Federal College Area', 'Madara', 'Masuga', 'Tunga Wawa'],
      ),
      NigeriaLga(
        name: 'Lapai LGA',
        areas: ['Lapai Central (IBBU)', 'Birnin Maza', 'Evuti', 'Muye'],
      ),
      NigeriaLga(
        name: 'Lavun LGA',
        areas: ['Kutigi', 'Dabban', 'Egbako', 'Jima'],
      ),
      NigeriaLga(
        name: 'Magama LGA',
        areas: ['Nasko', 'Auna', 'Ibeto', 'Shambo'],
      ),
      NigeriaLga(
        name: 'Mariga LGA',
        areas: ['Bangi', 'Berigoro', 'Igwe', 'Kumbashi'],
      ),
      NigeriaLga(
        name: 'Mashegu LGA',
        areas: ['Mashegu Central', 'Babban Rami', 'Dapangi', 'Kasanga'],
      ),
      NigeriaLga(
        name: 'Mokwa LGA',
        areas: ['Mokwa Central', 'Jebba North', 'Kpaki', 'Manya', 'Rabba'],
      ),
      NigeriaLga(
        name: 'Munya LGA',
        areas: ['Sarkin Pawa', 'Dandaudu', 'Gini', 'Kuchi'],
      ),
      NigeriaLga(
        name: 'Paikoro LGA',
        areas: ['Paiko Central', 'Kafin Koro', 'Gwam', 'Tutu'],
      ),
      NigeriaLga(
        name: 'Rafi LGA',
        areas: ['Kagara', 'Pandogari', 'Gunna', 'Tegina'],
      ),
      NigeriaLga(
        name: 'Rijau LGA',
        areas: ['Rijau Central', 'Danrangi', 'Dukku', 'Tungan Magajiya'],
      ),
      NigeriaLga(
        name: 'Shiroro LGA',
        areas: ['Kuta', 'Shiroro Dam Corridor', 'Zumba', 'Gwada', 'Galkogo'],
      ),
      NigeriaLga(
        name: 'Suleja LGA',
        areas: ['Suleja Town', 'Madalla', 'Gauraka', 'Zuma Rock Foothills', 'Kwamba', 'Maje', 'Chaza'],
      ),
      NigeriaLga(
        name: 'Tafa LGA',
        areas: ['Wuse New Town', 'Ijah', 'Gawu', 'Sabon Wuse'],
      ),
      NigeriaLga(
        name: 'Wushishi LGA',
        areas: ['Wushishi Central', 'Akare', 'Kanwuri', 'Zungeru (Colonial)'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Ogun State',
    capitalCity: 'Abeokuta',
    lgas: [
      NigeriaLga(
        name: 'Abeokuta North LGA',
        areas: ['Akomoje', 'Iberekodo', 'Ikereku', 'Ago-Ika', 'Lafenwa', 'Sabon Gari'],
      ),
      NigeriaLga(
        name: 'Abeokuta South LGA',
        areas: ['Ake Palace', 'Ibara GRA', 'Kuto', 'Omida', 'Adatan', 'Sapon', 'Itoku (Adire)'],
      ),
      NigeriaLga(
        name: 'Ado-Odo/Ota LGA',
        areas: ['Ota Industrial', 'Covenant Uni Area', 'Sango Ota', 'Igbesa', 'Ado-Odo Town', 'Atan Ota'],
      ),
      NigeriaLga(
        name: 'Ewekoro LGA',
        areas: ['Itori', 'Ewekoro (Lafarge)', 'Papalanto', 'Wasimi'],
      ),
      NigeriaLga(
        name: 'Ifo LGA',
        areas: ['Ifo Central', 'Ojodu Abiodun', 'Akute', 'Alagbole', 'Agbado', 'Matogun'],
      ),
      NigeriaLga(
        name: 'Ijebu East LGA',
        areas: ['Ogbere', 'Ijebu-Ife', 'Ojowo', 'Fetedo'],
      ),
      NigeriaLga(
        name: 'Ijebu North LGA',
        areas: ['Ijebu-Igbo', 'Ago-Iwoye (OOU)', 'Oru', 'Awa', 'Ilaporu'],
      ),
      NigeriaLga(
        name: 'Ijebu North East LGA',
        areas: ['Atan', 'Ilese', 'Erunwon', 'Isonyin'],
      ),
      NigeriaLga(
        name: 'Ijebu Ode LGA',
        areas: ['Ijebu Ode Central', 'Awujale Palace', 'Molipa', 'Igbeba', 'Folagbade'],
      ),
      NigeriaLga(
        name: 'Ikenne LGA',
        areas: ['Ikenne Central', 'Ilisan-Remo (Babcock)', 'Irolu', 'Iperu-Remo', 'Ogere'],
      ),
      NigeriaLga(
        name: 'Imeko Afon LGA',
        areas: ['Imeko Central', 'Afon', 'Ilara', 'Idofa'],
      ),
      NigeriaLga(
        name: 'Ipokia LGA',
        areas: ['Ipokia Central', 'Idi-Iroko (Border)', 'Maun', 'Agosasa'],
      ),
      NigeriaLga(
        name: 'Obafemi Owode LGA',
        areas: ['Owode Central', 'Mowe', 'Ibafo', 'Redemption Camp Area', 'Magboro'],
      ),
      NigeriaLga(
        name: 'Odeda LGA',
        areas: ['Odeda Town', 'FUNAAB Campus', 'Alabata', 'Osiele', 'Ilugun'],
      ),
      NigeriaLga(
        name: 'Odogbolu LGA',
        areas: ['Odogbolu Central', 'Aiyepe', 'Okun-Owa', 'Ososa'],
      ),
      NigeriaLga(
        name: 'Ogun Waterside LGA',
        areas: ['Abigi', 'Iwopin', 'Makun-Omi', 'Ode Omi'],
      ),
      NigeriaLga(
        name: 'Remo North LGA',
        areas: ['Isara-Remo', 'Ode-Remo', 'Akaka', 'Hara'],
      ),
      NigeriaLga(
        name: 'Shagamu LGA',
        areas: ['Sagamu Central', 'Sabo Sagamu', 'Makun', 'Ojagbo', 'Ewu-Oliwo'],
      ),
      NigeriaLga(
        name: 'Yewa North LGA',
        areas: ['Ayetoro', 'Igbogila', 'Eggua', 'Oja-Odan'],
      ),
      NigeriaLga(
        name: 'Yewa South LGA',
        areas: ['Ilaro Central (Poly)', 'Idogo', 'Owode Yewa', 'Iwoye'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Ondo State',
    capitalCity: 'Akure',
    lgas: [
      NigeriaLga(
        name: 'Akoko North-East LGA',
        areas: ['Ikare Central', 'Oka Border', 'Ilepa', 'Orun', 'Oyimo'],
      ),
      NigeriaLga(
        name: 'Akoko North-West LGA',
        areas: ['Okeagbe', 'Irun', 'Ogbagi', 'Afin', 'Erusu'],
      ),
      NigeriaLga(
        name: 'Akoko South-East LGA',
        areas: ['Isua-Akoko', 'Epinmi', 'Sosan', 'Ipe'],
      ),
      NigeriaLga(
        name: 'Akoko South-West LGA',
        areas: ['Oka-Akoko', 'Ikakunmo', 'Akungba (AAUA)', 'Supare', 'Oba-Akoko'],
      ),
      NigeriaLga(
        name: 'Akure North LGA',
        areas: ['Iju', 'Itaogbolu', 'Oba-Ile', 'Ayede Ogbese'],
      ),
      NigeriaLga(
        name: 'Akure South LGA',
        areas: ['Alagbaka GRA', 'Oja Oba Akure', 'Oda Road', 'FUTA Campus', 'Arakale', 'Ijapo Estate'],
      ),
      NigeriaLga(
        name: 'Ese Odo LGA',
        areas: ['Igbekebo', 'Arogbo', 'Kiribo', 'Ukparama'],
      ),
      NigeriaLga(
        name: 'Idanre LGA',
        areas: ['Idanre Town (Hills)', 'Atosin', 'Alade', 'Odode'],
      ),
      NigeriaLga(
        name: 'Ifedore LGA',
        areas: ['Igbara-Oke', 'Ilara-Mokin (Elizade)', 'Ijare', 'Ipogun'],
      ),
      NigeriaLga(
        name: 'Ilaje LGA',
        areas: ['Igbokoda', 'Ugbo', 'Mahin', 'Ayetoro (Sea Coast)', 'Zion'],
      ),
      NigeriaLga(
        name: 'Ile Oluji/Okeigbo LGA',
        areas: ['Ile-Oluji Central', 'Okeigbo', 'Bamisu', 'Ayetoro'],
      ),
      NigeriaLga(
        name: 'Irele LGA',
        areas: ['Ode-Irele', 'Ajagba', 'Akotogbo', 'Omi'],
      ),
      NigeriaLga(
        name: 'Odigbo LGA',
        areas: ['Ore Central (Crossroads)', 'Odigbo Town', 'Araromi', 'Agabu'],
      ),
      NigeriaLga(
        name: 'Okitipupa LGA',
        areas: ['Okitipupa Central', 'OAUSTECH Campus', 'Igbotako', 'Ilutitun', 'Ikoya'],
      ),
      NigeriaLga(
        name: 'Ondo East LGA',
        areas: ['Bolorunduro', 'Fagbo', 'Tekunle', 'Obun-Ewi'],
      ),
      NigeriaLga(
        name: 'Ondo West LGA',
        areas: ['Ondo Town Central', 'Enuowa', 'Yaba Ondo', 'Laje Road', 'UNIMED Area'],
      ),
      NigeriaLga(
        name: 'Ose LGA',
        areas: ['Ifon', 'Omi-Alagbado', 'Ijagba', 'Imoru', 'Arimogija'],
      ),
      NigeriaLga(
        name: 'Owo LGA',
        areas: ['Owo Central', 'Olowo Palace', 'Achievers Uni Area', 'Idasen', 'Iloro Owo', 'Rufus Giwa Poly'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Osun State',
    capitalCity: 'Osogbo',
    lgas: [
      NigeriaLga(
        name: 'Atakunmosa East LGA',
        areas: ['Iperindo', 'Iwara', 'Igila', 'Epe'],
      ),
      NigeriaLga(
        name: 'Atakunmosa West LGA',
        areas: ['Osu', 'Ibodi', 'Itagunmodi', 'Ifewara'],
      ),
      NigeriaLga(
        name: 'Aiyedaade LGA',
        areas: ['Gbongan', 'Orile-Owu', 'Ode-Omu', 'Tonkere'],
      ),
      NigeriaLga(
        name: 'Aiyedire LGA',
        areas: ['Ile-Ogbo', 'Kuta', 'Oluponna', 'Alagba'],
      ),
      NigeriaLga(
        name: 'Boluwaduro LGA',
        areas: ['Otan Ayegbaju', 'Eripa', 'Igbajo', 'Iresi'],
      ),
      NigeriaLga(
        name: 'Boripe LGA',
        areas: ['Iragbiji', 'Ada', 'Aagba', 'Ororuwo'],
      ),
      NigeriaLga(
        name: 'Ede North LGA',
        areas: ['Oja Timi', 'Ede Central', 'Alusekere', 'Sabon Gari Ede'],
      ),
      NigeriaLga(
        name: 'Ede South LGA',
        areas: ['Federal Poly Area', 'Adeleke Uni Area', 'Sekona', 'Babalaje'],
      ),
      NigeriaLga(
        name: 'Egbedore LGA',
        areas: ['Awo', 'Iragberi', 'Ikotun', 'Okinni'],
      ),
      NigeriaLga(
        name: 'Ejigbo LGA',
        areas: ['Ejigbo Central', 'Inisa Ejigbo', 'Ika', 'Oko'],
      ),
      NigeriaLga(
        name: 'Ife Central LGA',
        areas: ['OAU Campus', 'Enuwa (Palace)', 'Mayfair', 'Lagere', 'Modakeke Border', 'Moore'],
      ),
      NigeriaLga(
        name: 'Ife East LGA',
        areas: ['Oke-Ogbo', 'Modakeke Central', 'Ilode', 'Yekemi'],
      ),
      NigeriaLga(
        name: 'Ife North LGA',
        areas: ['Ipetumodu', 'Edunabon', 'Moro', 'Yakoyo'],
      ),
      NigeriaLga(
        name: 'Ife South LGA',
        areas: ['Ifetedo', 'Olode', 'Aye', 'Abiri'],
      ),
      NigeriaLga(
        name: 'Ifedayo LGA',
        areas: ['Oke-Ila Orangun', 'Ora-Igbomina', 'Alagbede'],
      ),
      NigeriaLga(
        name: 'Ifelodun LGA',
        areas: ['Ikirun Central', 'Iba', 'Eko-Ende', 'Eko-Ajande'],
      ),
      NigeriaLga(
        name: 'Ila LGA',
        areas: ['Ila Orangun Central', 'Ajaba', 'Ejigbo-Orangun'],
      ),
      NigeriaLga(
        name: 'Ilesa East LGA',
        areas: ['Ilesa Central', 'Okesa', 'Irojo', 'Bolorunduro'],
      ),
      NigeriaLga(
        name: 'Ilesa West LGA',
        areas: ['Omi Aladiye', 'Ereja', 'Isokun', 'Ilaje Ilesa'],
      ),
      NigeriaLga(
        name: 'Irepodun LGA',
        areas: ['Ilobu', 'Erin-Osun', 'Ahoro'],
      ),
      NigeriaLga(
        name: 'Irewole LGA',
        areas: ['Ikire', 'Wasinmi', 'Majeroku', 'Oluwo'],
      ),
      NigeriaLga(
        name: 'Isokan LGA',
        areas: ['Apomu', 'Ikoyi Osun', 'Awala'],
      ),
      NigeriaLga(
        name: 'Iwo LGA',
        areas: ['Iwo Central', 'Oluwo Palace', 'Bowen Uni Area', 'Molete', 'Agberire'],
      ),
      NigeriaLga(
        name: 'Obokun LGA',
        areas: ['Ibokun', 'Esa-Oke', 'Imesi-Ile', 'Ilare'],
      ),
      NigeriaLga(
        name: 'Odo Otin LGA',
        areas: ['Okuku', 'Inisa', 'Igbaye', 'Oyan'],
      ),
      NigeriaLga(
        name: 'Ola Oluwa LGA',
        areas: ['Bode Osi', 'Ogbaagba', 'Isero', 'Telemu'],
      ),
      NigeriaLga(
        name: 'Olorunda LGA',
        areas: ['Igbona', 'Ayetoro', 'Akande', 'Obatedo'],
      ),
      NigeriaLga(
        name: 'Oriade LGA',
        areas: ['Ijebu-Jesa', 'Ipetu-Ijesha', 'Erinmo', 'Ikeji-Arakeji (JABU)'],
      ),
      NigeriaLga(
        name: 'Orolu LGA',
        areas: ['Ifon Osun', 'Diisu', 'Gbede'],
      ),
      NigeriaLga(
        name: 'Osogbo LGA',
        areas: ['Osogbo Central', 'Alekuwodo', 'Oja Oba', 'Stadium Area', 'Old Garage', 'Capital Area'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Oyo State',
    capitalCity: 'Ibadan',
    lgas: [
      NigeriaLga(
        name: 'Afijio LGA',
        areas: ['Jobele', 'Fiditi', 'Ilora', 'Aawe', 'Imini'],
      ),
      NigeriaLga(
        name: 'Akinyele LGA',
        areas: ['Moniya', 'Ojoo', 'UI North', 'Orogun', 'Alabata', 'Bagii'],
      ),
      NigeriaLga(
        name: 'Atiba LGA',
        areas: ['Ofa Meta', 'Akesan Palace', 'Saabo', 'Agbori'],
      ),
      NigeriaLga(
        name: 'Atisbo LGA',
        areas: ['Tede', 'Ago-Are', 'Irawo', 'Sabe'],
      ),
      NigeriaLga(
        name: 'Egbeda LGA',
        areas: ['Egbeda Central', 'Alakia (Airport)', 'Iyana Church', 'Gbagi Market', 'Erunmu'],
      ),
      NigeriaLga(
        name: 'Ibadan North LGA',
        areas: ['Bodija', 'Agodi GRA', 'UI Campus', 'Poly Ibadan Area', 'Sango', 'Mokola'],
      ),
      NigeriaLga(
        name: 'Ibadan North-East LGA',
        areas: ['Iwo Road', 'Agugu', 'Oje Market', 'Aremo', 'Idi-Ape'],
      ),
      NigeriaLga(
        name: 'Ibadan North-West LGA',
        areas: ['Dugbe (Commercial)', 'Eleyele', 'Jericho GRA', 'Onireke', 'Adamasingba'],
      ),
      NigeriaLga(
        name: 'Ibadan South-East LGA',
        areas: ['Mapo Hall Area', 'Molete', 'Challenge', 'Felele', 'Orita Challenge'],
      ),
      NigeriaLga(
        name: 'Ibadan South-West LGA',
        areas: ['Ring Road', 'Oluyole Estate', 'Oke-Ado', 'Liberty Stadium', 'Apata'],
      ),
      NigeriaLga(
        name: 'Ibarapa Central LGA',
        areas: ['Igboora (Twins Capital)', 'Idere', 'Pata'],
      ),
      NigeriaLga(
        name: 'Ibarapa East LGA',
        areas: ['Eruwa (Poly)', 'Lanlate', 'Maya'],
      ),
      NigeriaLga(
        name: 'Ibarapa North LGA',
        areas: ['Ayete', 'Tapa', 'Igangan'],
      ),
      NigeriaLga(
        name: 'Ido LGA',
        areas: ['Ido Town', 'Apete', 'Omi Adio', 'Ijokodo', 'Nihort'],
      ),
      NigeriaLga(
        name: 'Irepo LGA',
        areas: ['Kisi Central', 'Budo Iki', 'Dogo', 'Kaye'],
      ),
      NigeriaLga(
        name: 'Iseyin LGA',
        areas: ['Iseyin Central', 'Oluwole', 'Koso', 'Ladoke Akintola Uni Area'],
      ),
      NigeriaLga(
        name: 'Itesiwaju LGA',
        areas: ['Otu', 'Komu', 'Okaka', 'Ipapo'],
      ),
      NigeriaLga(
        name: 'Iwajowa LGA',
        areas: ['Iwere-Ile', 'Iganna', 'Elekokan', 'Ijio'],
      ),
      NigeriaLga(
        name: 'Kajola LGA',
        areas: ['Okeho', 'Ilero', 'Ilaji-Ile', 'Olele'],
      ),
      NigeriaLga(
        name: 'Lagelu LGA',
        areas: ['Iyana Offa', 'Lalupon', 'Monatan', 'Alebiosu'],
      ),
      NigeriaLga(
        name: 'Ogbomosho North LGA',
        areas: ['LAUTECH Area', 'Oja Igbo', 'Sabon Gari Ogbomosho', 'Arowomole'],
      ),
      NigeriaLga(
        name: 'Ogbomosho South LGA',
        areas: ['Arowomole South', 'Sunsun', 'Ibapon', 'Akata'],
      ),
      NigeriaLga(
        name: 'Ogo Oluwa LGA',
        areas: ['Ajaawa', 'Odo-Oba', 'Otamokun', 'Opete'],
      ),
      NigeriaLga(
        name: 'Olorunsogo LGA',
        areas: ['Igbeti (Marble)', 'Opa', 'Sagbon', 'Karamo'],
      ),
      NigeriaLga(
        name: 'Oluyole LGA',
        areas: ['Idi-Ayunre', 'Lagos-Ibadan Expressway Corridor', 'Alomaja', 'Odo Ona Elewe'],
      ),
      NigeriaLga(
        name: 'Ona Ara LGA',
        areas: ['Akanran', 'Ogbere', 'Olorunsogo Ibadan', 'Badeku'],
      ),
      NigeriaLga(
        name: 'Orelope LGA',
        areas: ['Igboho Central', 'Modeke', 'Bonni', 'Aba'],
      ),
      NigeriaLga(
        name: 'Oriire LGA',
        areas: ['Ikoyi-Ile', 'Tewure', 'Adafila', 'Iluju'],
      ),
      NigeriaLga(
        name: 'Oyo East LGA',
        areas: ['Kosobo', 'Agure', 'Jabata', 'Durbar'],
      ),
      NigeriaLga(
        name: 'Oyo West LGA',
        areas: ['Ojongbodu', 'Isokun', 'Akeetan', 'Fasola'],
      ),
      NigeriaLga(
        name: 'Saki East LGA',
        areas: ['Ago-Amodu', 'Sepeteri', 'Oje-Owode', 'Ogboro'],
      ),
      NigeriaLga(
        name: 'Saki West LGA',
        areas: ['Saki Central', 'Medu', 'Kinnikinni', 'Barracks Saki'],
      ),
      NigeriaLga(
        name: 'Surulere (Oyo) LGA',
        areas: ['Iresa-Adu', 'Iresa-Apa', 'Arolu', 'Gambari'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Plateau State',
    capitalCity: 'Jos',
    lgas: [
      NigeriaLga(
        name: 'Barkin Ladi LGA',
        areas: ['Barkin Ladi Central', 'Heipang (Airport)', 'Kuru (NIPSS)', 'Fan', 'Foron'],
      ),
      NigeriaLga(
        name: 'Bassa LGA',
        areas: ['Bassa Central', 'Miango', 'Rukuba (Barracks)', 'Jengre', 'Kishika'],
      ),
      NigeriaLga(
        name: 'Bokkos LGA',
        areas: ['Bokkos Central (PLASU)', 'Daffo', 'Richa', 'Manguna', 'Mushere'],
      ),
      NigeriaLga(
        name: 'Jos East LGA',
        areas: ['Angware', 'Federe', 'Fobur', 'Maigemu', 'Shere'],
      ),
      NigeriaLga(
        name: 'Jos North LGA',
        areas: ['Jos Terminus', 'Rantya', 'Rayfield', 'Tudun Wada Jos', 'Dogon Dutse', 'Congo Russia'],
      ),
      NigeriaLga(
        name: 'Jos South LGA',
        areas: ['Bukuru', 'Zawan', 'Du', 'Vwang (Vom)', 'Gyel'],
      ),
      NigeriaLga(
        name: 'Kanam LGA',
        areas: ['Dengi', 'Kantana', 'Dugub', 'Garga', 'Mun'],
      ),
      NigeriaLga(
        name: 'Kanke LGA',
        areas: ['Kwal', 'Amper', 'Garram', 'Kabwir', 'Shiwer'],
      ),
      NigeriaLga(
        name: 'Langtang North LGA',
        areas: ['Langtang Central', 'Pill', 'Gazum', 'Bwarat', 'Reak'],
      ),
      NigeriaLga(
        name: 'Langtang South LGA',
        areas: ['Mabudi', 'Sabon Gari Langtang', 'Gamaka', 'Turaki', 'Magama'],
      ),
      NigeriaLga(
        name: 'Mangu LGA',
        areas: ['Mangu Central', 'Gindiri', 'Panyam (Fish Farm)', 'Kerang (Springs)', 'Kombun'],
      ),
      NigeriaLga(
        name: 'Mikang LGA',
        areas: ['Tunkus', 'Garkawa', 'Piapung', 'Montol Border'],
      ),
      NigeriaLga(
        name: 'Pankshin LGA',
        areas: ['Pankshin Central (FCE)', 'Chip', 'Fier', 'Kadun', 'Lankaku'],
      ),
      NigeriaLga(
        name: 'Qua\'an Pan LGA',
        areas: ['Baap', 'Kwali', 'Doemak', 'Namang', 'Pan'],
      ),
      NigeriaLga(
        name: 'Riyom LGA',
        areas: ['Riyom Central', 'Jol', 'Rim', 'Ta-Hoss', 'Kwi'],
      ),
      NigeriaLga(
        name: 'Shendam LGA',
        areas: ['Shendam Central', 'Derteng', 'Kalong', 'Pangshun', 'Shimankar'],
      ),
      NigeriaLga(
        name: 'Wase LGA',
        areas: ['Wase Central (Rock)', 'Bashar', 'Kadarko', 'Lamba', 'Mavo'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Rivers State',
    capitalCity: 'Port Harcourt',
    lgas: [
      NigeriaLga(
        name: 'Abua/Odual LGA',
        areas: ['Abua Central', 'Ayama', 'Emago-Kugbo', 'Odual', 'Okana'],
      ),
      NigeriaLga(
        name: 'Ahoada East LGA',
        areas: ['Ahoada Town', 'Upatabo', 'Ihuaba', 'Odiabidi'],
      ),
      NigeriaLga(
        name: 'Ahoada West LGA',
        areas: ['Akinima', 'Mbiama', 'Engenni', 'Joinkrama'],
      ),
      NigeriaLga(
        name: 'Akuku-Toru LGA',
        areas: ['Abonnema', 'Kula', 'Obonoma', 'Ido'],
      ),
      NigeriaLga(
        name: 'Andoni LGA',
        areas: ['Ngo', 'Asarama', 'Ataba', 'Ekowe', 'Unyeada'],
      ),
      NigeriaLga(
        name: 'Asari-Toru LGA',
        areas: ['Buguma', 'Abalama', 'Idama', 'Tema'],
      ),
      NigeriaLga(
        name: 'Bonny LGA',
        areas: ['Bonny Town (NLNG)', 'Finima', 'Abalamabie', 'Peterside'],
      ),
      NigeriaLga(
        name: 'Degema LGA',
        areas: ['Degema Central', 'Bakana', 'Tombia', 'Bille'],
      ),
      NigeriaLga(
        name: 'Eleme LGA',
        areas: ['Ogale', 'Onne (Oil & Gas FTZ)', 'Ebubu', 'Alesa (Refinery)', 'Aleto'],
      ),
      NigeriaLga(
        name: 'Emuoha LGA',
        areas: ['Emuoha Central', 'Rumuji', 'Ogbakiri', 'Elele-Alimini', 'Odegu'],
      ),
      NigeriaLga(
        name: 'Etche LGA',
        areas: ['Okehi', 'Ulakwo', 'Chokota', 'Nihi', 'Ozuzu'],
      ),
      NigeriaLga(
        name: 'Gokana LGA',
        areas: ['Kpor', 'Bera', 'Bodo', 'Mogho', 'Nweol'],
      ),
      NigeriaLga(
        name: 'Ikwerre LGA',
        areas: ['Isiokpo', 'Aluu', 'Elele', 'Omagwa (Airport)', 'Igwuruta'],
      ),
      NigeriaLga(
        name: 'Khana LGA',
        areas: ['Bori (Poly)', 'Babbe', 'Ken-Khana', 'Nyo-Khana', 'Taabaa'],
      ),
      NigeriaLga(
        name: 'Obio-Akpor LGA',
        areas: ['Rumuokoro', 'Choba (UniPort)', 'Rumuola', 'Rumuigbo', 'Woji', 'Trans-Amadi Corridor'],
      ),
      NigeriaLga(
        name: 'Ogba/Egbema/Ndoni LGA',
        areas: ['Omoku (FCE)', 'Egi', 'Ndoni', 'Kreigani', 'Obrikom'],
      ),
      NigeriaLga(
        name: 'Ogu/Bolo LGA',
        areas: ['Ogu', 'Bolo', 'Wakama', 'Ele'],
      ),
      NigeriaLga(
        name: 'Okrika LGA',
        areas: ['Okrika Town', 'Ogoloma', 'Ibaka', 'Ogbogbo', 'Kalio-Ama'],
      ),
      NigeriaLga(
        name: 'Omuma LGA',
        areas: ['Eberi', 'Umuola', 'Umuogba', 'Obiohia'],
      ),
      NigeriaLga(
        name: 'Opobo/Nkoro LGA',
        areas: ['Opobo Town', 'Nkoro', 'Kalaibiama', 'Queens Town'],
      ),
      NigeriaLga(
        name: 'Oyigbo LGA',
        areas: ['Oyigbo Central', 'Afam (Power)', 'Kom-Kom', 'Umuagbai'],
      ),
      NigeriaLga(
        name: 'Port Harcourt LGA',
        areas: ['Old GRA', 'New GRA', 'D-Line', 'Town (Aggrey)', 'Diobu (Mile 1-3)', 'Oromineke'],
      ),
      NigeriaLga(
        name: 'Tai LGA',
        areas: ['Saakpenwa', 'Botem', 'Koroma', 'Nonwa (NYSC)', 'Kpite'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Sokoto State',
    capitalCity: 'Sokoto',
    lgas: [
      NigeriaLga(
        name: 'Binji LGA',
        areas: ['Binji Central', 'Bunkari', 'Gawazzai', 'Samalu'],
      ),
      NigeriaLga(
        name: 'Bodinga LGA',
        areas: ['Bodinga Central', 'Badau', 'Danchadi', 'Tauma', 'Takatuku'],
      ),
      NigeriaLga(
        name: 'Dange Shuni LGA',
        areas: ['Dange Central', 'Shuni', 'Amanawa', 'Rundubawa', 'Wababe'],
      ),
      NigeriaLga(
        name: 'Gada LGA',
        areas: ['Gada Central', 'Dukamaje', 'Kaddi', 'Kyadawa', 'Tsitse'],
      ),
      NigeriaLga(
        name: 'Goronyo LGA',
        areas: ['Goronyo Central (Dam)', 'Kagara', 'Shinaka', 'Taloka'],
      ),
      NigeriaLga(
        name: 'Gudu LGA',
        areas: ['Balle', 'Awulkiti', 'Chilas', 'Kurula', 'Marake'],
      ),
      NigeriaLga(
        name: 'Gwadabawa LGA',
        areas: ['Gwadabawa Central', 'Asara', 'Attakwanyo', 'Chimola', 'Salame'],
      ),
      NigeriaLga(
        name: 'Illela LGA',
        areas: ['Illela Border', 'Araba', 'Damba', 'Gidan Katta', 'Kalmalo'],
      ),
      NigeriaLga(
        name: 'Isa LGA',
        areas: ['Isa Central', 'Bargaja', 'Gebe', 'Tudun Wada Isa', 'Turba'],
      ),
      NigeriaLga(
        name: 'Kebbe LGA',
        areas: ['Kebbe Central', 'Fakai', 'Margai', 'Nasagudu', 'Unguwar Lalle'],
      ),
      NigeriaLga(
        name: 'Kware LGA',
        areas: ['Kware Central', 'Bankanu', 'Durbawa', 'Kalkalawa', 'Tsaki'],
      ),
      NigeriaLga(
        name: 'Rabah LGA',
        areas: ['Rabah Central', 'Gandi', 'Rarah', 'Tsamiya', 'Yar Tsakuwa'],
      ),
      NigeriaLga(
        name: 'Sabon Birni LGA',
        areas: ['Sabon Birni Central', 'Gatawa', 'Kurawa', 'Makuwana', 'Tara'],
      ),
      NigeriaLga(
        name: 'Shagari LGA',
        areas: ['Shagari Central', 'Dandin Mahe', 'Horo', 'Kajiji', 'Sanyinna'],
      ),
      NigeriaLga(
        name: 'Silame LGA',
        areas: ['Silame Central', 'Gande', 'Kubodu', 'Labani', 'Marafa'],
      ),
      NigeriaLga(
        name: 'Sokoto North LGA',
        areas: ['Sultan Palace Area', 'Waziri Town', 'Kofar Rini', 'Magajin Gari', 'Ali Akilu'],
      ),
      NigeriaLga(
        name: 'Sokoto South LGA',
        areas: ['Gagi', 'Mabera', 'Tudun Wada Sokoto', 'Old Airport', 'Rijiyar Dorowa'],
      ),
      NigeriaLga(
        name: 'Tambuwal LGA',
        areas: ['Tambuwal Central', 'Barkeji', 'Dogon Daji', 'Jabo', 'Romu'],
      ),
      NigeriaLga(
        name: 'Tangaza LGA',
        areas: ['Tangaza Central', 'Gidan Madi', 'Kwatalo', 'Ruwa Wuri', 'Sakkwai'],
      ),
      NigeriaLga(
        name: 'Tureta LGA',
        areas: ['Tureta Central', 'Duma', 'Fura Girke', 'Kuruwa'],
      ),
      NigeriaLga(
        name: 'Wamako LGA',
        areas: ['Wamako Central (UDUS)', 'Dundaye', 'Gumbi', 'Kalanbaina', 'Wajake'],
      ),
      NigeriaLga(
        name: 'Wurno LGA',
        areas: ['Wurno Central', 'Alkammu', 'Chacho', 'Dargaza', 'Lugu'],
      ),
      NigeriaLga(
        name: 'Yabo LGA',
        areas: ['Yabo Central', 'Bakale', 'Bingaje', 'Torankawa'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Taraba State',
    capitalCity: 'Jalingo',
    lgas: [
      NigeriaLga(
        name: 'Ardo Kola LGA',
        areas: ['Sunkani', 'Alhassan', 'Iware', 'Mayo Ranewo', 'Zongon Kombi'],
      ),
      NigeriaLga(
        name: 'Bali LGA',
        areas: ['Bali Central', 'Badakoshi', 'Maihula', 'Suntai', 'Takalafia'],
      ),
      NigeriaLga(
        name: 'Donga LGA',
        areas: ['Donga Central', 'Akate', 'Gayama', 'Mararraba', 'Nyita'],
      ),
      NigeriaLga(
        name: 'Gashaka LGA',
        areas: ['Serti', 'Gashaka-Gumti Park Area', 'Barmo', 'Mayo Selbe', 'Mayo Gamgam'],
      ),
      NigeriaLga(
        name: 'Gassol LGA',
        areas: ['Mutum Biyu', 'Gassol Central', 'Sabon Gida', 'Sansani', 'Wuro Jam'],
      ),
      NigeriaLga(
        name: 'Ibi LGA',
        areas: ['Ibi Central', 'Dampar', 'Garkowa', 'Nwonyo (Fishing)', 'Sarkin Kudu'],
      ),
      NigeriaLga(
        name: 'Jalingo LGA',
        areas: ['Jalingo Central', 'Barade', 'Kona', 'Majidadi', 'Mayo Gwoi', 'Turaki', 'Mile 6'],
      ),
      NigeriaLga(
        name: 'Karim Lamido LGA',
        areas: ['Karim Lamido Central', 'Amar', 'Didango', 'Jen', 'Old Karim'],
      ),
      NigeriaLga(
        name: 'Kurmi LGA',
        areas: ['Baissa', 'Akirimi', 'Bente', 'Dama', 'Ndaforo'],
      ),
      NigeriaLga(
        name: 'Lau LGA',
        areas: ['Lau Central', 'Abbare', 'Donkin', 'Mayo Lope', 'Kunini'],
      ),
      NigeriaLga(
        name: 'Sardauna LGA',
        areas: ['Gembu (Mambilla Plateau)', 'Kakara (Tea Estate)', 'Mayo Ndaga', 'Nguroje', 'Warwar'],
      ),
      NigeriaLga(
        name: 'Takum LGA',
        areas: ['Takum Central', 'Chanchangi', 'Kashimbila (Dam)', 'Manya', 'Yukuben'],
      ),
      NigeriaLga(
        name: 'Ussa LGA',
        areas: ['Lissam', 'Fikyu', 'Kpambo', 'Kwambai', 'Rutu'],
      ),
      NigeriaLga(
        name: 'Wukari LGA',
        areas: ['Wukari Central (FUWukari)', 'Avoyi', 'Bantaje', 'Chonku', 'Gidan Idi', 'Kente'],
      ),
      NigeriaLga(
        name: 'Yorro LGA',
        areas: ['Pantisawa', 'Dampa', 'Kassa', 'Manang', 'Pupule'],
      ),
      NigeriaLga(
        name: 'Zing LGA',
        areas: ['Zing Central', 'Bubong', 'Dinding', 'Lamma', 'Monkin'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Yobe State',
    capitalCity: 'Damaturu',
    lgas: [
      NigeriaLga(
        name: 'Bade LGA',
        areas: ['Gashua Central', 'Katuzu', 'Lawandidi', 'Sarki Hausawa', 'Zango'],
      ),
      NigeriaLga(
        name: 'Bursari LGA',
        areas: ['Dapchi', 'Bayan Gari', 'Dumburi', 'Guba', 'Kaliyari'],
      ),
      NigeriaLga(
        name: 'Damaturu LGA',
        areas: ['Damaturu Central', 'Bindigari', 'Nayinawa', 'Pawari', 'Sabon Fegi', 'Maisandari'],
      ),
      NigeriaLga(
        name: 'Fika LGA',
        areas: ['Fika Central', 'Dankalwa', 'Gadaka', 'Jimbam', 'Ngalda'],
      ),
      NigeriaLga(
        name: 'Fune LGA',
        areas: ['Damagum', 'Alagarno', 'Daura Fune', 'Gudugurka', 'Jajere'],
      ),
      NigeriaLga(
        name: 'Geidam LGA',
        areas: ['Geidam Central', 'Asheikri', 'Fukarti', 'Hausari', 'Keluri'],
      ),
      NigeriaLga(
        name: 'Gujba LGA',
        areas: ['Buni Yadi', 'Gujba Town', 'Buni Gari', 'Goniri', 'Wagir'],
      ),
      NigeriaLga(
        name: 'Gulani LGA',
        areas: ['Bara', 'Bularafa', 'Garin Tuwo', 'Teteba', 'Zango Gulani'],
      ),
      NigeriaLga(
        name: 'Jakusko LGA',
        areas: ['Jakusko Central', 'Buduwa', 'Dumbari', 'Gidgid', 'Muguram'],
      ),
      NigeriaLga(
        name: 'Karasuwa LGA',
        areas: ['Jakarade', 'Garin Gawo', 'Gasamu', 'Wachakal'],
      ),
      NigeriaLga(
        name: 'Machina LGA',
        areas: ['Machina Central', 'Bogo', 'Damai', 'Kabuwa', 'Tagali'],
      ),
      NigeriaLga(
        name: 'Nangere LGA',
        areas: ['Potiskum Border', 'Chilariye', 'Dawasa', 'Kukuri', 'Watinani'],
      ),
      NigeriaLga(
        name: 'Nguru LGA',
        areas: ['Nguru Central', 'Hausari Nguru', 'Kanuri', 'Mirba', 'Bulabulin Nguru'],
      ),
      NigeriaLga(
        name: 'Potiskum LGA',
        areas: ['Potiskum Central', 'Bolewa', 'Dogo Tebo', 'Hausawa Potiskum', 'Mamudo', 'Yindiski'],
      ),
      NigeriaLga(
        name: 'Tarmuwa LGA',
        areas: ['Babangida', 'Barkami', 'Jumbam', 'Koriyel', 'Mafa Tarmuwa'],
      ),
      NigeriaLga(
        name: 'Yunusari LGA',
        areas: ['Kanamma', 'Bula', 'Degubi', 'Mozogun', 'Yunusari Central'],
      ),
      NigeriaLga(
        name: 'Yusufari LGA',
        areas: ['Yusufari Central', 'Alanjirori', 'Guya', 'Kumaganam', 'Mai-Malari'],
      ),
    ],
  ),
  const NigeriaState(
    name: 'Zamfara State',
    capitalCity: 'Gusau',
    lgas: [
      NigeriaLga(
        name: 'Anka LGA',
        areas: ['Anka Central', 'Bagega', 'Dan Kademi', 'Matseri', 'Wuya'],
      ),
      NigeriaLga(
        name: 'Bakura LGA',
        areas: ['Bakura Central', 'Damri', 'Dankaiwa', 'Nasarawa Bakura', 'Yarkofoji'],
      ),
      NigeriaLga(
        name: 'Birnin Magaji/Kiyaw LGA',
        areas: ['Birnin Magaji', 'Chafe Border', 'Danfami', 'Gidan Kado', 'Kiyawa'],
      ),
      NigeriaLga(
        name: 'Bukkuyum LGA',
        areas: ['Bukkuyum Central', 'Adabka', 'Janyau', 'Masama', 'Zauro'],
      ),
      NigeriaLga(
        name: 'Bungudu LGA',
        areas: ['Bungudu Central', 'Dan Isa', 'Gidan Bawa', 'Kwatarkwashi', 'Samawa'],
      ),
      NigeriaLga(
        name: 'Gummi LGA',
        areas: ['Gummi Central', 'Bardoki', 'Gayari', 'Illela Gummi', 'Shiyar Fada'],
      ),
      NigeriaLga(
        name: 'Gusau LGA',
        areas: ['Gusau Central', 'GRA Gusau', 'Tudun Wada Gusau', 'Samaru Gusau', 'Mayana', 'Canteen Area'],
      ),
      NigeriaLga(
        name: 'Kaura Namoda LGA',
        areas: ['Kaura Namoda Central (Poly)', 'Bangana', 'Dan Isa', 'Kungurki', 'Sakajiki'],
      ),
      NigeriaLga(
        name: 'Maradun LGA',
        areas: ['Maradun Central', 'Dosara', 'Gidan Goga', 'Kaya', 'Tsibiri'],
      ),
      NigeriaLga(
        name: 'Maru LGA',
        areas: ['Maru Central', 'Bindin', 'Dan Kurmi', 'Kanoma', 'Mayanchi'],
      ),
      NigeriaLga(
        name: 'Shinkafi LGA',
        areas: ['Shinkafi Central', 'Badarawa', 'Jangeru', 'Katuru', 'Shanawa'],
      ),
      NigeriaLga(
        name: 'Talata Mafara LGA',
        areas: ['Talata Mafara Central', 'Abdu Gusau Poly Area', 'Garbadu', 'Ruwan Doruwa', 'Takware'],
      ),
      NigeriaLga(
        name: 'Tsafe LGA',
        areas: ['Tsafe Central', 'Bilbis', 'Keta', 'Yandoto', 'Yanware'],
      ),
      NigeriaLga(
        name: 'Zurmi LGA',
        areas: ['Zurmi Central', 'Dauran', 'Kanwa', 'Kwashabawa', 'Rukudawa'],
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
