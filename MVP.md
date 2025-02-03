# Etkinlik Takip Uygulaması MVP Dokümanı

Versiyon: 1.0

Tarih: [03.02.2025]

Kullanıcıların konser, teknoloji, sinema, tiyatro gibi kategorilerde etkinlikler ekleyebileceği, takvim üzerinden yaklaşan etkinlikleri görebileceği ve etkinliklere bağlı not/fotoğraf saklayabileceği basit bir mobil uygulama.

## 2. MVP Hedefleri

### Temel İşlevsellik:
- Kullanıcıların etkinlik ekleme, düzenleme, silme
- Takvimde yakın tarihli etkinlikleri görüntüleme
- Not ve galeriden fotoğraf ekleme

### Basitlik:
- Karmaşık filtreler/istatistikler MVP dışında tutulacak
- Kamera entegrasyonu sonraki aşamalara bırakılacak

## 3. Temel Özellikler

### A. Etkinlik Yönetimi

| Özellik | Detay |
|---------|--------|
| Kategoriler | Konser, Teknoloji, Sinema, Tiyatro, Spor (kullanıcı özel kategori ekleyemez) |
| Etkinlik Ekleme | - Başlık, tarih, saat, kategori, konum (opsiyonel), açıklama |
| Takvim Görünümü | - Aylık/günlük takvim. Yaklaşan etkinlikler renkli vurgu ile gösterilir |
| Bildirimler | - Etkinlik tarihinden 1 gün önce basit bir push bildirim (MVP için opsiyonel) |

### B. Not ve Fotoğraf Ekleme

| Özellik | Detay |
|---------|--------|
| Not Ekleme | - Metin tabanlı notlar (başlık + içerik) |
| Fotoğraf Ekleme | - Galeriden fotoğraf seçme (max 3 fotoğraf/etkinlik) |
| İlişkilendirme | - Not/fotoğraflar etkinlikle bağlantılı olarak saklanır |

## 4. MVP Dışındaki Özellikler

- Kullanıcı profili oluşturma (anonim kullanım)
- Sosyal paylaşım veya etkinlik keşfetme
- Kamera ile direkt fotoğraf çekme
- Detaylı istatistikler (örn: "Ayda kaç sinema etkinliği ekledim?")

*Bu kısım projenin ilk hali bittikten sonra düşünülecek updateler*

## 5. Teknik Gereksinimler

### Frontend
- Platform: iOS/Android Flutter
- Takvim Entegrasyonu: table_calendar veya syncfusion_flutter_calendar
- Fotoğraf Yükleme: image_picker ve photo_view kütüphaneleri
- State Yönetimi: Provider veya Riverpod
- UI Bileşenleri: Material Design 3

### Backend
- Veritabanı: Firebase Firestore (hızlı MVP için ideal)
- Depolama: Firebase Storage (fotoğraflar için)
- Kimlik Doğrulama: E-posta/şifre veya anonim giriş (opsiyonel)

## 6. Kullanıcı Akışı

### Ana Ekran:
- Takvim görünümü + "Etkinlik Ekle" butonu

### Etkinlik Ekleme:
- Kategori seçimi → Bilgileri doldur → Kaydet

### Etkinlik Detayı:
- Not/fotoğraf ekleme → Düzenle/Sil

## 7. Tasarım İpuçları

- Renk Paleti: 
  - Konser: #9C27B0 (Mor)
  - Teknoloji: #2196F3 (Mavi)
  - Sinema: #E91E63 (Pembe)
  - Tiyatro: #FF9800 (Turuncu)
  - Spor: #4CAF50 (Yeşil)
- Basit UI: Ana ekranda takvim + "ekle" butonu öne çıksın
- Tipografi: 
  - Başlıklar: Roboto Bold
  - İçerik: Roboto Regular
- İkonlar: Material Design Icons
- Boşluk ve Hizalama: Material Design kurallarına uygun 8dp grid sistemi

## 8. Test Senaryoları

- Senaryo 1: Kullanıcı 10 Aralık'a bir sinema etkinliği ekler. Takvimde görünür mü?
- Senaryo 2: Galeriden fotoğraf eklenip etkinlikle ilişkilendirilebiliyor mu?

## 9. Riskler ve Çözümler

| Risk | Çözüm |
|------|--------|
| Takvim senkronizasyon hataları | Yerel bir takvim kütüphanesi kullanmak |
| Fotoğraf yükleme performansı | Firebase Storage ile sıkıştırılmış görseller saklamak |

## 10. Sonraki Adımlar

### Faz 1 - Frontend ve UI (İlk Sprint)
1. Tasarım mockup'ları oluşturma (Figma)
2. Temel UI bileşenlerinin geliştirilmesi:
   - Ana ekran takvim görünümü
   - Etkinlik ekleme formu
   - Etkinlik detay sayfası
3. Yerel veri yönetimi ile çalışan prototip
   - Geçici olarak SharedPreferences/Hive kullanımı
   - Offline-first yaklaşım

### Faz 2 - Backend Entegrasyonu (İkinci Sprint)
1. Firebase projesi kurulumu
2. Firestore veritabanı yapılandırması
3. Storage sistemi entegrasyonu
4. Offline-first yaklaşımdan backend sistemine geçiş

### Backend Geçiş Stratejisi
#### Veri Modeli Yaklaşımı
- Başlangıçtan itibaren Firebase uyumlu model sınıfları tasarlanacak
- Her model için `toJson` ve `fromJson` metodları implement edilecek
- Veri modelleri local ve remote storage için uyumlu olacak

#### Repository Pattern Kullanımı
```dart
abstract class IEventRepository {
    Future<List<Event>> getEvents();
    Future<void> addEvent(Event event);
    Future<void> updateEvent(Event event);
    Future<void> deleteEvent(String id);
}

// Local Storage Implementation
class LocalEventRepository implements IEventRepository {
    // Hive veya SharedPreferences implementasyonu
}

// Firebase Implementation
class FirebaseEventRepository implements IEventRepository {
    // Firebase implementasyonu
}
```

#### Aşamalı Geçiş Planı
1. Okuma İşlemleri
   - Önce read operasyonları Firebase'e taşınacak
   - Veri tutarlılığı kontrolleri yapılacak
   
2. Yazma İşlemleri
   - Create, Update, Delete operasyonları taşınacak
   - Her operasyon için hata kontrolü eklenecek
   
3. Senkronizasyon
   - Offline-online senkronizasyon mekanizması kurulacak
   - Conflict resolution stratejileri belirlenecek

#### Dependency Injection
- Repository'ler DI ile yönetilecek
- Geçiş sırasında minimum kod değişikliği hedeflenecek
- GetIt veya Riverpod kullanılacak

### Faz 3 - İyileştirmeler ve Test (Üçüncü Sprint)
1. Performance optimizasyonları
2. UI/UX iyileştirmeleri
3. Hata yakalama ve kullanıcı geri bildirimleri
4. Test senaryolarının uygulanması

## 11. Git ve Branch Stratejisi

### GitHub Repository
- Repository URL: https://github.com/eyupece/event-track

### Branch Yapısı
| Branch | Açıklama |
|--------|----------|
| main | Kararlı sürümler için ana branch |
| develop | Geliştirme branch'i |
| feature/* | Yeni özellikler için branch'ler |
| bugfix/* | Hata düzeltmeleri için branch'ler |

### Branch Kuralları
- Main branch'e direkt push yapılmayacak
- Yeni özellikler için feature/ önekli branch'ler kullanılacak
- Her commit mesajı açıklayıcı ve atomic commit kuralına uygun olacak
- Sürüm etiketleri (git tags) kullanılacak 

## 12. Mevcut Durum ve İlerleyiş

### Tamamlanan Adımlar
1. Proje yapısı (Clean Architecture) ✅
   - Core katmanı (tema, sabitler)
   - Features katmanı (events modülü)
   - Shared katmanı (widgets, utils)

2. Temel Konfigürasyonlar ✅
   - Tema ve renk paleti
   - Uygulama sabitleri
   - Event model
   - Repository pattern

3. Git Yapılandırması ✅
   - Repository oluşturuldu
   - Branch stratejisi belirlendi
   - İlk commit yapıldı

### Sıradaki Adımlar
1. UI Geliştirmeleri
   - Ana ekran tasarımı
   - Takvim entegrasyonu
   - Etkinlik kartı tasarımı

2. Local Storage
   - Hive konfigürasyonu
   - CRUD operasyonları
   - Offline-first yaklaşım

3. State Management
   - Riverpod kurulumu
   - Event provider'ları
   - UI state yönetimi 

## 13. Clean Architecture Yapısı

### Katmanlar

#### 1. Domain Layer
- İş mantığının kalbi
- Use case'ler ve entity'ler
- Framework'ten bağımsız
- `lib/features/events/domain/`
  - `models/` - Event, Note gibi entity'ler
  - `repositories/` - Repository interface'leri
  - `usecases/` - İş mantığı operasyonları

#### 2. Data Layer
- Veri işlemleri ve dış dünya ile iletişim
- Repository implementasyonları
- `lib/features/events/data/`
  - `repositories/` - Repository implementasyonları
  - `datasources/` - Local ve remote veri kaynakları
  - `models/` - API/DB modelleri

#### 3. Presentation Layer
- UI bileşenleri ve state yönetimi
- `lib/features/events/presentation/`
  - `screens/` - Uygulama ekranları
  - `widgets/` - UI bileşenleri
  - `providers/` - State yönetimi

### Core Katmanı
- `lib/core/`
  - `theme/` - Uygulama teması
  - `constants/` - Sabit değerler
  - `errors/` - Hata tipleri
  - `utils/` - Yardımcı fonksiyonlar

### Shared Katmanı
- `lib/shared/`
  - `widgets/` - Ortak UI bileşenleri
  - `utils/` - Genel yardımcı fonksiyonlar

### Dependency Rule
1. Domain Layer <- Data Layer
2. Domain Layer <- Presentation Layer
3. Data Layer <- Presentation Layer

### Veri Akışı
1. UI -> Provider -> UseCase -> Repository -> DataSource
2. DataSource -> Repository -> UseCase -> Provider -> UI

### Avantajları
- Yüksek test edilebilirlik
- Bağımlılıkların yönetimi
- Kod organizasyonu
- Ölçeklenebilirlik
- Maintainability 
=======
1. Tasarım mockup'ları oluşturma (Figma)
2. Firebase projesi kurulumu
3. Temel ekranların kodlanması (Ana ekran → Etkinlik Ekleme → Detay) 
