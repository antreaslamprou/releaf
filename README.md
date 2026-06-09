# ReLeaf

A gamified social media mobile application, that provides daily tasks to complete for a more sutainable environment.

**Author:** Antreas Lamprou  
**Contact:** alamprou1@uclan.ac.uk - antreaslamprou12@gmail.com  
**Repository:** https://github.com/antreaslamprou/releaf  

---

## Table of Contents
<details>
  <summary><strong>Expand</strong></summary>

- [About the Project](#about-the-project)
  - [Key Features](#key-features)
  - [Technology Stack](#technology-stack)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Configuration](#configuration)
- [Usage](#usage)
- [Development](#development)
  - [Running Tests](#running-tests)
  - [Project Structure](#project-structure)
- [Roadmap](#roadmap)
  - [Planned Features](#planned-features)
  - [Known Limitations](#known-limitations)
  - [Future Improvements](#future-improvements)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)
- [Acknowledgments](#acknowledgments)

</details>

---

## About the Project

The project is a gamified social media mobile application, that provides each user the same daily task, and each user must complete the task to keep their hotstreak up and earn points. The aim of this project is to provide users with enviromental responisbility and provide users with a way to help with the 17 UN SDGs. It is for mostly young adults who are already using social media and might want to help the enviroment seamlessly.

### Key Features

- Daily enviromental task
- Points system
- Leaderboard
- Avatar and app customization
- Social media aspect
- Friendships functionality
- User authentication

### Technology Stack

- Dart
- Flutter
- Firebase

---

## Getting Started

To install and run the project locally make sure you have flutter and the repository installed.

### Prerequisites

Make sure you have flutter installed by running version command and also run doctor to make sure you have all prerequisites set up correctly.

```sh
flutter --version
flutter doctor
```

### Installation

```sh
git clone https://github.com/antreaslamprou/releaf.git
cd releaf
flutter pub get
```

### Configuration

No need to add any configuration files.

---

## Usage

To run the project enter the run command. You can run the project on release mode aswell. 

```sh
flutter run
flutter run --release
```

---

## Development

### Running Tests

```sh
test-command
```

### Project Structure

```text
releaf
│
├── assets/               # Static files
│     └── images/         # Application images
│
├── lib/                  # Main application source code
│     ├── components/     # Reusable UI components
│     ├── controllers/    # Tracking controllers
│     ├── extensions/     # Conversion extensions
│     ├── pages/          # Application pages/routes
│     ├── providers/      # Local data providers
│     ├── services/       # Services with database functionality
│     ├── utils/          # Helper functions
│     ├── app.dart        # Main application class
│     └── main.dart       # Main class
│
├── android-release/      # Android APK
├── web-release/          # Web hosted files
│
├── android/              # Android platform-specific files
├── ios/                  # iOS platform-specific files
├── linux/                # Linux platform files
├── macos/                # macOS platform files
├── web/                  # Web platform configuration
├── windows/              # Windows desktop platform files
│
├── test/                 # Component automatic tests
│
├── package.json          # Project dependencies and configuration
├── LICENCE               # Project licence
└── README.md             # Project documentation
```

---

## Roadmap

### Planned Features
- Multi-platform support
- Filtering intergration for posts
- Firebase web functions integration

### Known Limitations
- Limited storage
- Limited testing coverage

### Future Improvements
- Improve code quality and maintain clean architecture
- Increase automated testing
- Continue using open-source or free resources where possible

---

## Contributing

Contributions, issues, and feature requests are welcome. Feel free to open an issue or submit a pull request if you would like to improve the project.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contact

Antreas Lamprou  
alamprou1@uclan.ac.uk - antreaslamprou12@gmail.com  
https://github.com/antreaslamprou

---

## Acknowledgments

I want to thank my professors for helping me with this project, and my girlfriend for helping me find this project idea.
