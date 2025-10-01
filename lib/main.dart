import 'package:flutter/material.dart';
import 'weather_service.dart';
import 'weather_home_page.dart';
import 'dart:ui';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  WeatherData? _weatherData;
  List<ForecastData>? _forecastData;
  bool _isLoading = false;
  String _errorMessage = '';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Load default city
    _fetchWeather('London');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _fetchWeather(String cityName) async {
    if (cityName.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final weather = await _weatherService.getWeather(cityName);
      final forecast = await _weatherService.getForecast(cityName);

      setState(() {
        _weatherData = weather;
        _forecastData = forecast;
        _isLoading = false;
      });

      _fadeController.reset();
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'City not found. Please try again.';
        _isLoading = false;
      });
    }
  }

  Color _getBackgroundGradientStart() {
    if (_weatherData == null) return const Color(0xFF4A90E2);

    final condition = _weatherData!.mainCondition.toLowerCase();
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) {
      // Morning
      if (condition.contains('clear')) return const Color(0xFFFFB347);
      if (condition.contains('cloud')) return const Color(0xFF87CEEB);
      if (condition.contains('rain')) return const Color(0xFF5F6F81);
    } else if (hour >= 12 && hour < 18) {
      // Afternoon
      if (condition.contains('clear')) return const Color(0xFF4A90E2);
      if (condition.contains('cloud')) return const Color(0xFF708090);
      if (condition.contains('rain')) return const Color(0xFF4B5D6E);
    } else {
      // Evening/Night
      if (condition.contains('clear')) return const Color(0xFF1e3c72);
      if (condition.contains('cloud')) return const Color(0xFF2C3E50);
      if (condition.contains('rain')) return const Color(0xFF2C3E50);
    }

    return const Color(0xFF4A90E2);
  }

  Color _getBackgroundGradientEnd() {
    if (_weatherData == null) return const Color(0xFF7B68EE);

    final condition = _weatherData!.mainCondition.toLowerCase();
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) {
      if (condition.contains('clear')) return const Color(0xFFFFCC33);
      if (condition.contains('cloud')) return const Color(0xFFB0C4DE);
      if (condition.contains('rain')) return const Color(0xFF7C8FA1);
    } else if (hour >= 12 && hour < 18) {
      if (condition.contains('clear')) return const Color(0xFF7B68EE);
      if (condition.contains('cloud')) return const Color(0xFF95A5A6);
      if (condition.contains('rain')) return const Color(0xFF6B7D8F);
    } else {
      if (condition.contains('clear')) return const Color(0xFF2a5298);
      if (condition.contains('cloud')) return const Color(0xFF34495E);
      if (condition.contains('rain')) return const Color(0xFF34495E);
    }

    return const Color(0xFF7B68EE);
  }

  IconData _getWeatherIcon() {
    if (_weatherData == null) return Icons.wb_sunny;

    final condition = _weatherData!.mainCondition.toLowerCase();

    if (condition.contains('clear')) return Icons.wb_sunny;
    if (condition.contains('cloud')) return Icons.cloud;
    if (condition.contains('rain')) return Icons.grain;
    if (condition.contains('snow')) return Icons.ac_unit;
    if (condition.contains('thunder')) return Icons.flash_on;
    if (condition.contains('mist') || condition.contains('fog'))
      return Icons.blur_on;

    return Icons.wb_cloudy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getBackgroundGradientStart(),
              _getBackgroundGradientEnd(),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child:
                    _isLoading
                        ? _buildLoadingWidget()
                        : _errorMessage.isNotEmpty
                        ? _buildErrorWidget()
                        : _weatherData != null
                        ? _buildWeatherContent()
                        : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search city...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  onPressed: () {
                    // Add location functionality
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              onSubmitted: _fetchWeather,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Fetching weather data...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 20),
          Text(
            _errorMessage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _buildMainWeatherCard(),
              const SizedBox(height: 20),
              _buildDetailsGrid(),
              const SizedBox(height: 20),
              if (_forecastData != null && _forecastData!.isNotEmpty)
                _buildForecastSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white.withOpacity(0.9),
                size: 20,
              ),
              const SizedBox(width: 5),
              Text(
                '${_weatherData!.cityName}, ${_weatherData!.country}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            _weatherData!.getLocalDate(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          Text(
            _weatherData!.getLocalTime(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 30),
          Icon(_getWeatherIcon(), size: 120, color: Colors.white),
          const SizedBox(height: 20),
          Text(
            '${_weatherData!.temperature.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontWeight: FontWeight.w300,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _weatherData!.description.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Feels like ${_weatherData!.feelsLike.round()}°',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMinMaxTemp(
                'Min',
                '${_weatherData!.tempMin.round()}°',
                Icons.arrow_downward,
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _buildMinMaxTemp(
                'Max',
                '${_weatherData!.tempMax.round()}°',
                Icons.arrow_upward,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinMaxTemp(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildDetailCard(
          'Humidity',
          '${_weatherData!.humidity}%',
          Icons.water_drop,
        ),
        _buildDetailCard(
          'Wind Speed',
          '${_weatherData!.windSpeed} m/s',
          Icons.air,
        ),
        _buildDetailCard(
          'Pressure',
          '${_weatherData!.pressure} hPa',
          Icons.compress,
        ),
        _buildDetailCard(
          'Cloudiness',
          '${_weatherData!.cloudiness}%',
          Icons.cloud_queue,
        ),
        _buildDetailCard(
          'Sunrise',
          _weatherData!.getSunriseTime(),
          Icons.wb_sunny,
        ),
        _buildDetailCard(
          'Sunset',
          _weatherData!.getSunsetTime(),
          Icons.nightlight_round,
        ),
      ],
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection() {
    final dailyForecasts = <ForecastData>[];
    final seenDays = <String>{};

    for (var forecast in _forecastData!) {
      final day = forecast.dateTime.day.toString();
      if (!seenDays.contains(day) && dailyForecasts.length < 5) {
        dailyForecasts.add(forecast);
        seenDays.add(day);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 5, bottom: 15),
          child: Text(
            '5-Day Forecast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children:
                dailyForecasts
                    .map((forecast) => _buildForecastItem(forecast))
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastItem(ForecastData forecast) {
    final day =
        forecast.dateTime.day == DateTime.now().day
            ? 'Today'
            : _getDayName(forecast.dateTime.weekday);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              day,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            _getWeatherIconForCondition(forecast.description),
            color: Colors.white,
            size: 30,
          ),
          Text(
            '${forecast.temperature.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  IconData _getWeatherIconForCondition(String description) {
    final condition = description.toLowerCase();
    if (condition.contains('clear')) return Icons.wb_sunny;
    if (condition.contains('cloud')) return Icons.cloud;
    if (condition.contains('rain')) return Icons.grain;
    if (condition.contains('snow')) return Icons.ac_unit;
    if (condition.contains('thunder')) return Icons.flash_on;
    return Icons.wb_cloudy;
  }
}
