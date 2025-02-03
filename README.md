# Event Track

Etkinlik takibi için geliştirilmiş bir mobil uygulama. Kullanıcılar konser, teknoloji, sinema, tiyatro gibi kategorilerde etkinlikler ekleyebilir, takvim üzerinden yaklaşan etkinlikleri görebilir ve etkinliklere bağlı not/fotoğraf saklayabilir.

## Özellikler

- 📅 Etkinlik ekleme, düzenleme ve silme
- 🗓️ Takvim üzerinden etkinlik takibi
- 📝 Etkinliklere not ekleme
- 📸 Etkinliklere fotoğraf ekleme (galeri üzerinden)
- 🏷️ Kategori bazlı etkinlik yönetimi
- 🔔 Etkinlik bildirimleri

## Teknolojiler

- Flutter/Dart
- Firebase (Backend)
- Provider/Riverpod (State Management)
- Material Design 3

## Kurulum

1. Flutter'ı yükleyin (https://flutter.dev/docs/get-started/install)
2. Repository'yi klonlayın:
```bash
git clone https://github.com/eyupece/event-track.git
```
3. Bağımlılıkları yükleyin:
```bash
flutter pub get
```
4. Uygulamayı çalıştırın:
```bash
flutter run
```

## Proje Yapısı

```
lib/
├── core/              # Temel bileşenler
│   ├── constants/     # Sabitler
│   └── theme/        # Tema ayarları
├── features/          # Özellik modülleri
│   └── events/       # Etkinlik modülü
│       ├── data/     # Veri katmanı
│       ├── domain/   # İş mantığı
│       └── presentation/ # UI katmanı
└── shared/           # Paylaşılan bileşenler
    ├── utils/        # Yardımcı fonksiyonlar
    └── widgets/      # Paylaşılan widget'lar
```

## Katkıda Bulunma

1. Bir feature branch'i oluşturun (`git checkout -b feature/yeni-ozellik`)
2. Değişikliklerinizi commit edin (`git commit -m 'Yeni özellik: Açıklama'`)
3. Branch'inizi push edin (`git push origin feature/yeni-ozellik`)
4. Bir Pull Request oluşturun

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## İletişim

Eyüp Ece - [@eyupece](https://github.com/eyupece)

Proje Linki: [https://github.com/eyupece/event-track](https://github.com/eyupece/event-track)
