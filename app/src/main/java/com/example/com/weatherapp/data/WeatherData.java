package com.example.com.weatherapp.data;

public class WeatherData {
    private String date;
    private String location;

    // Constructor
    public WeatherData(String date, String location) {
        this.date = date;
        this.location = location != null ? location : "Choose Your Location";
    }

    // Getters and setters
    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    // toString() method
    @Override
    public String toString() {
        return "WeatherData{" +
                "date='" + date + '\'' +
                ", location='" + location + '\'' +
                '}';
    }
}
