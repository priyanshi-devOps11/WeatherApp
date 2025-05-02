package com.example.weatherapp;

import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Query;

// Interface for Retrofit to get weather data
public interface WeatherApiService {

    // Define a GET request to fetch weather data
    @GET("weather")  // OpenWeatherMap endpoint
    Call<WeatherResponse> getWeatherData(
            @Query("q") String cityName,        // City name parameter
            @Query("appid") String apiKey,      // API key for authentication
            @Query("units") String units       // Units for the temperature (metric, imperial, etc.)
    );
}
