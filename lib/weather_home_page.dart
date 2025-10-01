import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'weather_service.dart';
import 'dart:ui';
import 'dart:math' as math;

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
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotateController);

    _fetchWeather('London');
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _fetchWeather(String cityName) async {
    if (cityName.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final weather = await _weatherService.getWeather(cityName.trim());
      final forecast = await _weatherService.getForecast(cityName.trim());

      setState(() {
        _weatherData = weather;
        _forecastData = forecast;
        _isLoading = false;
      });

      _fadeController.reset();
      _fadeController.forward();

      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() {
        _errorMessage =
            'Unable to find weather data for "$cityName".\nPlease check the city name and try again.';
        _isLoading = false;
      });
      HapticFeedback.heavyImpact();
    }
  }

  Color _getBackgroundGradientStart() {
    if (_weatherData == null) return const Color(0xFF4A90E2);

    final condition = _weatherData!.mainCondition.toLowerCase();
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      if (condition.contains('clear')) return const Color(0xFFFF9A56);
      if (condition.contains('cloud')) return const Color(0xFF87CEEB);
      if (condition.contains('rain')) return const Color(0xFF5F6F81);
      if (condition.contains('snow')) return const Color(0xFFB0E0E6);
    } else if (hour >= 12 && hour < 17) {
      if (condition.contains('clear')) return const Color(0xFF4A90E2);
      if (condition.contains('cloud')) return const Color(0xFF708090);
      if (condition.contains('rain')) return const Color(0xFF4B5D6E);
      if (condition.contains('snow')) return const Color(0xFF87CEEB);
    } else if (hour >= 17 && hour < 21) {
      if (condition.contains('clear')) return const Color(0xFFFF6B6B);
      if (condition.contains('cloud')) return const Color(0xFF5F6F81);
      if (condition.contains('rain')) return const Color(0xFF2C3E50);
      if (condition.contains('snow')) return const Color(0xFF7B68EE);
    } else {
      if (condition.contains('clear')) return const Color(0xFF1e3c72);
      if (condition.contains('cloud')) return const Color(0xFF2C3E50);
      if (condition.contains('rain')) return const Color(0xFF34495E);
      if (condition.contains('snow')) return const Color(0xFF483D8B);
    }

    return const Color(0xFF4A90E2);
  }

  Color _getBackgroundGradientEnd() {
    if (_weatherData == null) return const Color(0xFF7B68EE);

    final condition = _weatherData!.mainCondition.toLowerCase();
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      if (condition.contains('clear')) return const Color(0xFFFFD93D);
      if (condition.contains('cloud')) return const Color(0xFFB0C4DE);
      if (condition.contains('rain')) return const Color(0xFF7C8FA1);
      if (condition.contains('snow')) return const Color(0xFFE0FFFF);
    } else if (hour >= 12 && hour < 17) {
      if (condition.contains('clear')) return const Color(0xFF7B68EE);
      if (condition.contains('cloud')) return const Color(0xFF95A5A6);
      if (condition.contains('rain')) return const Color(0xFF6B7D8F);
      if (condition.contains('snow')) return const Color(0xFFB0C4DE);
    } else if (hour >= 17 && hour < 21) {
      if (condition.contains('clear')) return const Color(0xFFFFA500);
      if (condition.contains('cloud')) return const Color(0xFF7C8FA1);
      if (condition.contains('rain')) return const Color(0xFF34495E);
      if (condition.contains('snow')) return const Color(0xFF9370DB);
    } else {
      if (condition.contains('clear')) return const Color(0xFF2a5298);
      if (condition.contains('cloud')) return const Color(0xFF34495E);
      if (condition.contains('rain')) return const Color(0xFF2C3E50);
      if (condition.contains('snow')) return const Color(0xFF6A5ACD);
    }

    return const Color(0xFF7B68EE);
  }

  IconData _getWeatherIcon() {
    if (_weatherData == null) return Icons.wb_sunny;

    final condition = _weatherData!.mainCondition.toLowerCase();

    if (condition.contains('clear')) return Icons.wb_sunny;
    if (condition.contains('cloud')) return Icons.cloud;
    if (condition.contains('rain') || condition.contains('drizzle'))
      return Icons.grain;
    if (condition.contains('snow')) return Icons.ac_unit;
    if (condition.contains('thunder')) return Icons.flash_on;
    if (condition.contains('mist') ||
        condition.contains('fog') ||
        condition.contains('haze')) {
      return Icons.blur_on;
    }

    return Icons.wb_cloudy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeInOut,
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
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
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
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: 0.1,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 2,
                  colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search any city worldwide...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 24,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                        : const Icon(
                          Icons.explore,
                          color: Colors.white,
                          size: 22,
                        ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: (value) => setState(() {}),
              onSubmitted: _fetchWeather,
              textInputAction: TextInputAction.search,
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
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            'Fetching weather data...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Getting latest information',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Oops!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = '';
                });
                _searchController.clear();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
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
              _buildSunriseSunsetCard(),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: Colors.white.withOpacity(0.9),
                size: 22,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${_weatherData!.cityName}, ${_weatherData!.country}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _weatherData!.getLocalDate(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white.withOpacity(0.9),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  _weatherData!.getLocalTime(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ScaleTransition(
            scale: _pulseAnimation,
            child: Icon(
              _getWeatherIcon(),
              size: 130,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black26, blurRadius: 20)],
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_weatherData!.temperature.round()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 90,
                  fontWeight: FontWeight.w200,
                  height: 1,
                ),
              ),
              const Text(
                '°C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              _weatherData!.description.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.thermostat,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Feels like ${_weatherData!.feelsLike.round()}°C',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMinMaxTemp(
                  'Min',
                  '${_weatherData!.tempMin.round()}°',
                  Icons.arrow_downward_rounded,
                  Colors.lightBlueAccent,
                ),
                Container(
                  height: 45,
                  width: 1.5,
                  color: Colors.white.withOpacity(0.4),
                ),
                _buildMinMaxTemp(
                  'Max',
                  '${_weatherData!.tempMax.round()}°',
                  Icons.arrow_upward_rounded,
                  Colors.orangeAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinMaxTemp(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
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
      childAspectRatio: 1.4,
      children: [
        _buildDetailCard(
          'Humidity',
          '${_weatherData!.humidity}%',
          Icons.water_drop_rounded,
          Colors.blueAccent,
        ),
        _buildDetailCard(
          'Wind Speed',
          '${_weatherData!.windSpeed.toStringAsFixed(1)} m/s',
          Icons.air_rounded,
          Colors.tealAccent,
        ),
        _buildDetailCard(
          'Pressure',
          '${_weatherData!.pressure} hPa',
          Icons.compress_rounded,
          Colors.purpleAccent,
        ),
        _buildDetailCard(
          'Cloudiness',
          '${_weatherData!.cloudiness}%',
          Icons.cloud_queue_rounded,
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSunriseSunsetCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSunTimeItem(
            'Sunrise',
            _weatherData!.getSunriseTime(),
            Icons.wb_sunny_rounded,
            Colors.orangeAccent,
          ),
          Container(
            height: 60,
            width: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.1),
                ],
              ),
            ),
          ),
          _buildSunTimeItem(
            'Sunset',
            _weatherData!.getSunsetTime(),
            Icons.nightlight_round,
            Colors.deepPurpleAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildSunTimeItem(
    String label,
    String time,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 15),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '5-Day Forecast',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children:
                dailyForecasts
                    .asMap()
                    .entries
                    .map((entry) => _buildForecastItem(entry.value, entry.key))
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastItem(ForecastData forecast, int index) {
    final day =
        forecast.dateTime.day == DateTime.now().day
            ? 'Today'
            : _getDayName(forecast.dateTime.weekday);

    final isLast = index == 4;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  day,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getWeatherIconForCondition(forecast.description),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${forecast.temperature.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${forecast.humidity}%',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.white.withOpacity(0.2),
            thickness: 1,
            height: 1,
          ),
      ],
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
    if (condition.contains('clear')) return Icons.wb_sunny_rounded;
    if (condition.contains('cloud')) return Icons.cloud_rounded;
    if (condition.contains('rain') || condition.contains('drizzle'))
      return Icons.grain;
    if (condition.contains('snow')) return Icons.ac_unit_rounded;
    if (condition.contains('thunder')) return Icons.flash_on_rounded;
    if (condition.contains('mist') || condition.contains('fog'))
      return Icons.blur_on;
    return Icons.wb_cloudy_rounded;
  }
}
