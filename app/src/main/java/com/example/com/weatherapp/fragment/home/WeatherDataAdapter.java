package com.example.weatherapp.fragment.home;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;


import com.example.com.weatherapp.data.WeatherData;
import com.example.weatherapp.R;

import java.util.List;

public class WeatherDataAdapter extends RecyclerView.Adapter<WeatherDataAdapter.WeatherViewHolder> {

    private List<WeatherData> weatherDataList;
    private final OnLocationClickListener onLocationClickListener;

    public WeatherDataAdapter(List<WeatherData> weatherDataList, OnLocationClickListener onLocationClickListener) {
        this.weatherDataList = weatherDataList;
        this.onLocationClickListener = onLocationClickListener;
    }

    @Override
    public WeatherViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_weather, parent, false);
        return new WeatherViewHolder(view);
    }

    @Override
    public void onBindViewHolder(WeatherViewHolder holder, int position) {
        WeatherData weatherData = weatherDataList.get(position);
        holder.locationTextView.setText(weatherData.getLocation());
        holder.dateTextView.setText(weatherData.getDate());

        holder.locationTextView.setOnClickListener(v -> {
            if (onLocationClickListener != null) {
                onLocationClickListener.onLocationClick(weatherData.getLocation());
            }
        });
    }

    @Override
    public int getItemCount() {
        return weatherDataList.size();
    }

    public static class WeatherViewHolder extends RecyclerView.ViewHolder {
        TextView locationTextView;
        TextView dateTextView;

        public WeatherViewHolder(View itemView) {
            super(itemView);
            locationTextView = itemView.findViewById(R.id.locationTextView);
            dateTextView = itemView.findViewById(R.id.dateTextView);
        }
    }

    public interface OnLocationClickListener {
        void onLocationClick(String location);
    }
}

