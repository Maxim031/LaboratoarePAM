# Ce explici la profesor — Lab4

„Am continuat aplicația cu doctori de la laboratorul 3. Am păstrat designul și funcțiile, dar am înlocuit JSON-ul local cu două cereri GET către API-ul variantei 2. Am separat proiectul în Presentation, Domain și Data și am folosit Cubit pentru starea interfeței.”

## Demonstrație

1. Deschide aplicația: se execută GET /v2/feed și apare lista.
2. Trage lista în jos: se execută o nouă cerere.
3. Caută Sonja; caută xyz pentru Empty și resetează.
4. Adaugă o favorită, filtrează și sortează.
5. Deschide un medic: se execută GET /v2/feed/details, cu Loading separat.
6. Selectează data și ora. Explică faptul că confirmarea este locală deoarece API-ul oferit nu documentează salvarea.
7. Fără conexiune, reîncarcă: apare Error; restabilește conexiunea și apasă Try again.

## Funcții esențiale

- `DoctorsRemoteDataSource._get()` trimite cererea HTTP, verifică statusul, aplică timeout, decodează UTF-8 și JSON.
- `FeedDto.fromJson()` / `AppointmentDto.fromJson()` convertesc și validează structura primită.
- `toJson()` produce un Map serializabil; `jsonEncode()` îl transformă în text JSON.
- `HttpDoctorsRepository.getFeed()` transformă DTO în entitate Domain; `_guard()` transformă erorile tehnice în `AppFailure`.
- `GetDoctors.call()` și `GetAppointmentDetails.call()` exprimă operațiile aplicației fără dependență de HTTP.
- `DoctorsCubit.load()` / `DetailsCubit.load()` emit Loading, așteaptă rezultatul, apoi Success/Empty sau Error.
- `SelectDoctors.call()` aplică regulile de căutare, filtrare și sortare.
- `BlocBuilder` ascultă Cubit și actualizează widgeturile.
- `main.dart` construiește dependențele și închide clientul HTTP la eliberarea aplicației.

## Întrebări posibile

**De ce Domain nu importă HTTP?** Pentru că regulile aplicației nu trebuie să depindă de transport sau de implementarea serverului.

**Ce este un repository?** Un contract de acces la date. Domain declară ce are nevoie; Data decide cum obține acele date.

**DTO vs Entity?** DTO descrie formatul extern și conversia JSON. Entity este modelul folosit de logica aplicației, fără metode de parsare HTTP/JSON.

**Dependency injection?** Clasele primesc dependențele prin constructor. În aplicație folosesc un client HTTP real; în teste pot injecta MockClient fără rețea reală.

**Serializare vs deserializare?** Obiect → Map → text JSON, respectiv text JSON → Map → obiect.

**async/await creează un thread?** Nu. Așteaptă rezultatul Future fără a bloca interfața în perioada așteptării; nu mută automat parsarea pe un alt fir.

**Ce înseamnă HTTP 200, 404, 500?** Succes, resursă negăsită, eroare internă a serverului. Codul acceptă statusuri 2xx și gestionează restul ca erori.

**De ce două Cubit-uri de încărcare?** Lista și detaliile au cicluri independente. Un eșec la detalii nu trebuie să distrugă lista deja încărcată.

**Ce se întâmplă fără internet?** Apare un mesaj de conexiune sau timeout și butonul de reîncercare. Nu se maschează eroarea prin JSON local.

**De ce nu trimiți POST la rezervare?** În enunț au fost date doar URL-urile de citire; nu există un contract de scriere verificat. Confirmarea rămâne explicit demonstrativă, iar serializarea toJson este implementată și testată.

**Cum demonstrezi testarea?** `flutter test` pentru comportamente deterministe cu MockClient; `dart run tool/check_api.dart` pentru API-ul real.
