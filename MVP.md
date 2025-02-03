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

1. Tasarım mockup'ları oluşturma (Figma)
2. Firebase projesi kurulumu
3. Temel ekranların kodlanması (Ana ekran → Etkinlik Ekleme → Detay) 