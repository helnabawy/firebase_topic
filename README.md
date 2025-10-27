# Firebase Notifications Flutter App

A Flutter application that integrates with Firebase Cloud Messaging (FCM) to receive push notifications on Android.

Test Multi Project in same Account Handling same Topic in **Option 3** _without unsubscribe from any topic_



## Features

- Firebase Core integration
- Firebase Cloud Messaging (FCM) setup
- Local notifications display
- FCM token generation and display
- Foreground and background message handling
- Message click handling
- **Topic Subscriptions**: Subscribe and unsubscribe from topics
- **Quick Topic Management**: Predefined topics (news, sports, weather, tech, general)
- **Custom Topic Support**: Add any custom topic name



## Issue Reproduce

1. Run the app using the first project `android/app/google-services-first.json`
2. Subscribe to topic on Home Screen for example `news`
3. When Sending Notification from Firebase Console Messages the notification received successfully
4. Without unsubscribing from topics Change the google.services.json file with the second project file `android/app/google-services.json`
5. Run the project with the second project firebase file
6. Subscribe to the same topic name in the app
7. Send the notification from the second project the notification will be received successfully
8. Change the google.service.json to the first project
9. Run the app
10. Send the Notification from second Project Firebase console
11. The Users who run the app using first project google.service.json receive all notification from Project 2 broadcast topic

> the two apps runs in the same bundle id


## Setup Instructions

### 1. Firebase Project Setup

There are two `google-service.json` files to two projects in Firebase


**First Project** 

android/app/google-services-first.json

**Second Project**

android/app/google-services.json

### 2. Add google-services.json

1. Copy the downloaded `google-services.json` file
2. Place it in the `android/app/` directory of your Flutter project

### 3. Install Dependencies

Run the following command to install all dependencies:

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

## How to Test Notifications

### Option 1: Using Firebase Console

1. Go to Firebase Console > Cloud Messaging
2. Click "Send your first message"
3. Enter a notification title and text
4. Select your app
5. Send the notification

### Option 2: Using FCM Token (Programmatically)

1. Copy the FCM token displayed in the app
2. Use a tool like Postman to send a POST 

### Option 3: Using Topic Messaging

1. Subscribe to a topic in the app (e.g., "news", "sports")
2. Send to topic using Firebase Console or API

## App Features

- **FCM Token Display**: Shows the current device's FCM token
- **Message Counter**: Tracks how many notifications have been received
- **Last Message**: Displays the most recent notification received
- **Refresh Token**: Button to refresh the FCM token
- **Background Handling**: Processes notifications even when app is closed
- **Tap Handling**: Responds when notifications are tapped
- **Topic Subscriptions**: 
  - Subscribe to predefined topics (news, sports, weather, tech, general)
  - Subscribe to custom topics by entering topic name
  - Visual indication of subscribed topics
  - Easy unsubscribe functionality
- **Topic Management**: Visual chips showing subscription status
