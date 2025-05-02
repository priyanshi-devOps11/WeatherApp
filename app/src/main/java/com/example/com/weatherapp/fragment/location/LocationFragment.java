package com.example.weatherapp.fragment.location;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.fragment.app.Fragment;

import com.example.weatherapp.R;

public class LocationFragment extends Fragment {

    private EditText locationInput; // User input field for location
    private Button fetchLocationButton; // Button to fetch or update location
    private TextView locationTextView; // Display the selected location

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View rootView = inflater.inflate(R.layout.fragment_location, container, false);

        // Initialize views
        locationInput = rootView.findViewById(R.id.locationInput);
        fetchLocationButton = rootView.findViewById(R.id.fetchLocationButton);
        locationTextView = rootView.findViewById(R.id.locationTextView);

        // Set up button click listener to handle location input
        fetchLocationButton.setOnClickListener(v -> onFetchLocationClicked());

        return rootView;
    }

    // Handle the fetch location button click
    private void onFetchLocationClicked() {
        String location = locationInput.getText().toString().trim();

        if (location.isEmpty()) {
            // Show a toast message if no location is entered
            Toast.makeText(getContext(), "Please enter a location", Toast.LENGTH_SHORT).show();
        } else {
            // Update the TextView with the entered location
            locationTextView.setText("Selected Location: " + location);
        }
    }
}
