**Flutter Image Search App**
A single-page image search app built with Flutter.
Type a query, see results below, and keep scrolling for more.

**Features**

Search bar at the top

Results grid below

Debounced typing (reduces API calls)

Infinite scroll / pagination

Uses the Pexels API (can be swapped out)

**Getting Started**
Requirements:

Flutter

A Pexels API key: https://www.pexels.com/api/

**Clone & Install**
git clone https://github.com/Collin-ross/flutter_image_search_app.git
cd flutter_image_search_app
flutter pub get

**Configure Environment**
Create a file named .env in the project root:

PEXELS_API_KEY=YOUR_REAL_KEY_HERE


In pubspec.yaml, make sure .env is listed as an asset (and that uses-material-design appears only once):

flutter:
  uses-material-design: true
  assets:
    - .env



**Run**
Web (Chrome recommended):
flutter run -d chrome
(MacOS):
flutter run -d macos

