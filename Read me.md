# AimTask

AimTask is a comprehensive task management app designed to help users manage their tasks and locations effectively. It integrates various technologies and frameworks to provide a seamless experience, including Firebase for authentication and data storage, MapKit for location-based features, and Mailjet for email services.

## Features

- **User Authentication**: Sign up, login, and manage users with Firebase Authentication.
- **Task Management**: Create, update, and delete tasks with Firebase Firestore Database.
- **Location Services**: Utilize CoreLocation and MapKit for geofencing, location tracking, and map-based task management.
- **Search Functionality**: Advanced search suggestions and location search using MapKit.
- **Local Notifications**: Receive notifications for task-related events and geofence entries/exits.
- **Email Notifications**: Send email alerts using Mailjet.

## Technologies Used

- **SwiftUI**: For building the user interface in a declarative way.
- **Combine Framework**: For handling asynchronous data streams and binding.
- **Firebase**: Core, Authentication, and Firestore Database for backend services.
- **MapKit**: For displaying maps, adding markers, and handling user location.
- **CoreLocation**: For geofencing and location tracking.
- **Mailjet**: Email serivce for sending email.
- **Network Framework**: To handle network connectivity and status.

## MVVM Design Pattern

The AimTask app follows the **Model-View-ViewModel (MVVM)** design pattern, which helps in separating the business logic from the user interface. Here’s a brief overview of how MVVM is implemented in this project:

- **Model**: Represents the data layer, including the data structures and the business logic. For example, `TaskModel` represents a task, and `AddTaskMapViewModel` manages data related to tasks and map functionalities.

- **View**: Represents the user interface, built using SwiftUI. The `AddTaskMapView` is a SwiftUI view that displays the UI and binds to the view model.

- **ViewModel**: Acts as a bridge between the Model and the View. It contains the logic to manage the state of the View and performs operations on the Model. For instance, `AddTaskMapViewModel` handles the data manipulation, including search operations and managing geofences.

## Continuous Integration/Continuous Deployment (CI/CD)

AimTask uses Xcode Cloud for its CI/CD pipeline, which is linked with GitHub. Any branch merge into the main branch will trigger the pipeline, automatically resolving dependencies, injecting API keys, and building the app. The pipeline can also deliver builds to specified destinations, such as internal testing groups.

-  Xcode Cloud manages the CI/CD process and handles code compilation, testing, and deployment.
-  API keys and sensitive information are injected during the pipeline build, ensuring they are not pushed to the repository.

## Getting Started

1. **Clone the Repository**:
```sh
https://github.com/vilayath01/AimTask.git
```

2. **Install Dependencies**:
Ensure you have Xcode installed and use Swift Package Manager or CocoaPods to install the necessary dependencies.

3. **Configure Firebase**:
Follow the Firebase setup guide to configure Firebase for your project. Update the `GoogleService-Info.plist` file in your Xcode project.

4. **Run the App**:
Open the project in Xcode and build the app for your desired simulator or device.
