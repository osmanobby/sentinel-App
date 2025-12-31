# Parental Control App Blueprint

## Overview

This document outlines the architecture and features of the Parental Control App, a Flutter application designed to help parents monitor and manage their children's device usage.

## Style and Design

*   **Modern & Bold UI:** The app features a premium user interface inspired by modern design trends, including the "Bold Definition" principles. It uses vibrant gradients, expressive typography, and interactive elements with soft shadows to create a sense of depth and a high-quality user experience.
*   **Glassmorphism:** The UI incorporates glassmorphism, a design trend that uses a frosted-glass effect. Key UI elements, like cards and panels, are semi-transparent with a background blur, creating a multi-layered, modern aesthetic.
*   **Material Design 3:** The app is built on the latest Material Design 3 guidelines, ensuring a consistent and accessible experience.
*   **Theming:**
    *   **Light/Dark Mode:** The app supports both light and dark themes, with a theme toggle available to the user.
    *   **Custom Fonts:** The `google_fonts` package is used for custom, expressive typography.
    *   **Noise Texture:** A subtle noise texture is applied to backgrounds to provide a premium, tactile feel.

## Features

### Authentication & User Management

*   **Firebase Authentication:** Handles user registration and login.
*   **User Roles:** Users can sign up as a 'parent' or a 'child'. This is stored in Firestore.
*   **Account Linking:** Parents can link to their child's account using a unique, one-time code generated on the child's device.
*   **User Service:** A `UserService` manages all user-related data in Firestore.
*   **Auth Wrapper:** The `AuthWrapper` directs users to the appropriate screen (login or dashboard) based on their authentication state.

### Screen Time & App Usage Tracking

*   **Parent-side Dashboard (`ScreenTimeScreen`):** A visually rich dashboard for parents to monitor their child's screen time. It features an interactive pie chart with a "lifted" effect on touch and a glassmorphic list of app usage.
*   **Child-side Simulation (`AppUsageTrackerService`):** To simulate real-world functionality, an `AppUsageTrackerService` runs on the child's dashboard. This service periodically generates random app usage data and updates Firestore.
*   **Real-time Updates:** The parent's dashboard listens to a live stream of data from Firestore, so the screen time information updates in real-time as the child's device reports usage.
*   **Daily Limits:** Parents can set and adjust daily screen time limits from their dashboard. The limit controls are designed as interactive "hero" elements.
*   **Screen Time Service:** The `ScreenTimeService` centralizes all Firestore operations related to screen time data.

### App Blocking

*   **Parental Control:** Parents can view a list of their child's apps and choose to block or unblock them.
*   **Child's Dashboard:** The child's dashboard displays a list of currently blocked apps.
*   **App Blocking Service:** The `AppBlockingService` handles the logic for managing app-blocking rules in Firestore.

### Web Filtering

*   **Web Filter Service:** Manages web filtering settings, including blocking adult content, social media, and custom lists of allowed/blocked websites.
*   **Parental Configuration:** Parents can configure these web filter settings from their dashboard.

## Project Structure

The project is organized by feature, promoting scalability and maintainability.

```
lib/
├── auth/ (Authentication screens and services)
├── child/ (Child-specific dashboard and services)
├── models/ (Data models for User, ScreenTime, etc.)
├── parent/ (Parent-specific screens: Dashboard, ScreenTime, etc.)
├── services/ (Core services like Firebase, User, ScreenTime)
├── shared/ (Shared widgets and utilities)
├── main.dart
└── firebase_options.dart
```
