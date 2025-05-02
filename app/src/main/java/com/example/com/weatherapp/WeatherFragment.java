package com.example.weatherapp;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.fragment.app.Fragment;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

public class WeatherFragment extends Fragment {

    private EditText cityInput;
    private Button getWeatherBtn;
    private TextView resultText;

    private final String API_KEY = "0b8cb3ca16665a68aa5c4c4a7d0f8daa";

    public WeatherFragment() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_weather, container, false);

        cityInput = view.findViewById(R.id.cityInput);
        getWeatherBtn = view.findViewById(R.id.getWeatherBtn);
        resultText = view.findViewById(R.id.resultText);

        getWeatherBtn.setOnClickListener(v -> fetchWeather());

        return view;
    }

    private void fetchWeather() {
        String city = cityInput.getText().toString().trim();
        if (city.isEmpty()) {
            Toast.makeText(getContext(), "Please enter a city name", Toast.LENGTH_SHORT).show();
            return;
        }

        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl("https://api.openweathermap.org/data/2.5/")
                .addConverterFactory(GsonConverterFactory.create())
                .build();

        WeatherApiService apiService = retrofit.create(WeatherApiService.class);

        Call<WeatherResponse> call = apiService.getWeatherData(city, API_KEY, "metric");

        call.enqueue(new Callback<WeatherResponse>() {
            @Override
            public void onResponse(Call<WeatherResponse> call, Response<WeatherResponse> response) {
                if (response.isSuccessful()) {
                    WeatherResponse weather = response.body();
                    String info = "Temp: " + weather.getMain().getTemp() + "°C\n"
                            + "Humidity: " + weather.getMain().getHumidity() + "%\n"
                            + "Condition: " + weather.getWeather().get(0).getDescription();
                    resultText.setText(info);
                } else {
                    resultText.setText("City not found or error occurred");
                }
            }

            @Override
            public void onFailure(Call<WeatherResponse> call, Throwable t) {
                resultText.setText("Error: " + t.getMessage());
            }
        });
    }
}
