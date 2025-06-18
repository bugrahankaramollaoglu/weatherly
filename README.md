# 🌤️ Weatherly

> Get up-to-date weather data for all 81 provinces of Turkey!  
> **Weatherly** is a sleek and user-friendly weather app powered by [CollectAPI](https://collectapi.com/tr/api/weather/hava-durumu-api).

<div style="display: flex;">
  <div style="flex: 50%; padding: 5px;">
    <img src="https://github.com/bugrahankaramollaoglu/weatherly/blob/main/assets/header.png" width="500" />
  </div>
</div>

---

## 🚀 Features

✅ Real-time weather data for all 81 Turkish cities  
✅ City-based weather filtering  
✅ Fast and reliable API calls  
✅ Clean and intuitive UI  
✅ Mobile-friendly and responsive design

---

## 📦 Built With

- **Flutter** – Cross-platform UI toolkit  
- **Dart** – Programming language  
- **CollectAPI** – Weather API provider  
- **Provider / Bloc** – (Add if applicable) state management  
- **HTTP** – For REST API calls

---

## 🛠️ Installation

```bash
git clone https://github.com/bugrahankaramollaoglu/weatherly.git
cd weatherly
flutter pub get
flutter run
```

## 💻 API Example 

```bash
curl -X GET "https://api.collectapi.com/weather/getWeather?data.city=Ankara" \
-H "content-type: application/json" \
-H "authorization: apikey YOUR_API_KEY"
