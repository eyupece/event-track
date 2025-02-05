# Etkinlik Takip Uygulaması MVP Dokümanı

Versiyon: 0.2.2
Son Güncelleme: [05.02.2024]

## 1. Proje Özeti
Kullanıcıların etkinliklerini kategorize edip takip edebileceği, takvim üzerinden yönetebileceği ve etkinliklere not/fotoğraf ekleyebileceği bir mobil uygulama.

## 2. Mevcut Durum

### Tamamlanan (✅)
- Modern UI tasarımı
  - Material Design 3 uyumlu tema
  - Gradient arka planlar ve gölgeli kartlar
  - Responsive tasarım
  - Özel takvim seçici dialog
  - İlerleme kartı ve istatistikler
  - Mini takvim widget'ı
  - Gelişmiş filtreleme arayüzü
    - Durum filtreleri (Tamamlanan/Bekleyen)
    - Tarih filtreleri (Bugün/Hafta/Ay)
    - Görsel iyileştirmeler ve kullanıcı deneyimi
- Form Validasyonları
  - Karakter limitleri (Başlık: 50, Açıklama: 500, Konum: 50, Notlar: 500)
  - Anlık form validasyonu
  - Karakter sayacı gösterimi
  - Loading state
  - Türkçe hata mesajları
- Takvim entegrasyonu
  - Aylık/haftalık görünüm
  - Türkçe dil desteği
  - Pazartesiden başlayan hafta görünümü
  - Mini takvim görünümü
- Clean Architecture yapısı
  - Core katmanı
  - Features katmanı
  - Shared katmanı
- Ana Ekran Özellikleri
  - Kişiselleştirilmiş karşılama mesajı
  - Etkinlik arama çubuğu
  - Kategori kartları
  - Etkinlik listesi
  - Tamamlanan/Bekleyen istatistikleri
- Etkinlik Tamamlanma Sistemi
  - Modern checkbox tasarımı
  - Animasyonlu geçişler
  - Özel görsel efektler
  - Tamamlanma durumu göstergeleri
  - Yeşil tema renkleri ve etiketler
- Etkinlik Düzenleme
  - Tek form yapısı
  - Otomatik değer doldurma
  - Hero animasyonları
- Etkinlik Silme ve Geri Alma
  - Native tasarımlı bottom snackbar
  - Anlık görsel geri bildirim
  - Optimize edilmiş silme işlemi
  - Kolay geri alma özelliği
  - Performans optimizasyonu

### Geliştirme Aşamasında (🚧)
- Etkinlik ekleme formu
- Kategori sistemi
- State management (Riverpod)
- Veri modeli ve repository pattern

### Planlanmış (⏳)
- Local storage (Hive)
- Not ve fotoğraf ekleme
- Bildirim sistemi
- Test kapsamı

## 3. Temel Özellikler

### A. Etkinlik Yönetimi
| Özellik | Durum | Öncelik | Detay |
|---------|--------|---------|--------|
| Takvim Görünümü | ✅ | P0 | Aylık/haftalık görünüm, tarih seçimi |
| Etkinlik Ekleme | 🚧 | P0 | Başlık, tarih, saat, kategori, konum |
| Kategori Sistemi | 🚧 | P1 | Konser, Teknoloji, Sinema, Tiyatro, Spor |
| Bildirimler | ⏳ | P2 | Etkinlikten 1 gün önce bildirim |

### B. Medya ve Notlar
| Özellik | Durum | Öncelik | Detay |
|---------|--------|---------|--------|
| Not Ekleme | ⏳ | P1 | Başlık ve içerik desteği |
| Fotoğraf | ⏳ | P2 | Galeriden seçim (max 3 fotoğraf) |

## 4. Teknik Altyapı

### Frontend
- [✅] Flutter & Dart
- [✅] Material Design 3
- [✅] table_calendar
- [🚧] Riverpod (state management)
- [⏳] Hive (local storage)
- [⏳] image_picker

### Mimari
- Clean Architecture
- Repository Pattern
- SOLID Prensipleri
- Dependency Injection

## 5. Yayın Planı

### v0.1.0 - Alpha (Şubat 2024)
- [✅] Modern UI
- [✅] Takvim entegrasyonu
- [🚧] Etkinlik ekleme
- [⏳] Local storage

### v0.2.0 - Beta (Mart 2024)
- [ ] Kategori sistemi
- [ ] Not/fotoğraf desteği
- [ ] Bildirimler
- [ ] Test kapsamı

### v1.0.0 - Release (Nisan 2024)
- [ ] Tüm temel özellikler
- [ ] Performance optimizasyonu
- [ ] Store hazırlığı

## 6. Geliştirme Kuralları

### Git Stratejisi
- `main`: Kararlı sürümler
- `develop`: Geliştirme branch'i
- `feature/*`: Yeni özellikler
- `bugfix/*`: Hata düzeltmeleri

### Kod Standartları
- Dart/Flutter lint kuralları
- İngilizce değişken/fonksiyon isimleri
- Açıklayıcı commit mesajları
- Code review zorunluluğu

### Test Kapsamı
- Unit testler
- Widget testler
- Integration testler

## 7. Sonraki Aşama Özellikleri
- Kullanıcı profili
- Çevrimdışı çalışma
- İstatistikler
- Sosyal paylaşım
- Yedekleme/senkronizasyon
- Etkilnik ekleye basılınca çıkan ve takvimde bir iki ui güncellemesi unutma

## 8. Güncellemeler
- 04.02.2024: Filtreleme arayüzü iyileştirildi
  - Filtreler arası boşluklar optimize edildi
  - Seçili olmayan filtrelerin görünümü iyileştirildi
  - Tema renkleriyle uyum sağlandı
- 03.02.2024: Modern UI ve takvim entegrasyonu tamamlandı
- 03.02.2024: MVP dokümanı güncellendi
- 03.02.2024: Clean Architecture yapısı oluşturuldu
- 03.02.2024: Ana ekran tasarımı yenilendi
  - İlerleme kartı ve istatistikler eklendi
  - Özel takvim seçici eklendi
  - Kategori kartları güncellendi
  - Etkinlik listesi tasarımı iyileştirildi
- 04.02.2024: Form validasyonları ve karakter limitleri eklendi
  - Tüm form alanları için karakter limitleri tanımlandı
  - Anlık validasyon ve karakter sayacı eklendi
  - Loading state ve kullanıcı geri bildirimleri iyileştirildi
- 05.02.2024: Etkinlik Tamamlanma Sistemi İyileştirildi
  - Modern, yuvarlak checkbox tasarımı eklendi
  - Tamamlanan etkinlikler için özel görsel efektler eklendi
  - Animasyonlu geçişler ve kullanıcı deneyimi iyileştirildi
  - Tamamlanan etkinlikler için yeşil tema renkleri ve özel etiket eklendi
  - Liste görünümünde tamamlanma durumu göstergeleri eklendi
- 05.02.2024: AddEventScreen → EventFormScreen dönüşümü tamamlandı
  - Tek form üzerinden hem ekleme hem düzenleme yapılabilir hale getirildi
  - Form validasyonları ve karakter limitleri korundu
  - Düzenleme modunda mevcut değerler otomatik dolduruluyor
  - Hero animasyonu ile geçiş efektleri eklendi
- 05.02.2024: Etkinlik silme sistemi iyileştirildi
  - Bottom snackbar tasarımı eklendi
  - Silme işlemi optimize edildi
  - Geri alma özelliği eklendi
  - Performans iyileştirmeleri yapıldı
