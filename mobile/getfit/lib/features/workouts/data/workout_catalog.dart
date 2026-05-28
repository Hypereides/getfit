class WorkoutCatalog {
  static const List<String> categories = [
    'Strength',
    'Cardio',
  ];

  static const List<String> strengthExercises = [
    'Bench Press',
    'Squat',
    'Deadlift',
    'Shoulder Press',
    'Bicep Curl',
    'Lat Pulldown',
  ];

  static const List<String> cardioExercises = [
    'Running',
    'Cycling',
    'Jump Rope',
    'Rowing',
    'Elliptical',
    'Stair Climber',
  ];

  static List<String> byCategory(String category) {
    switch (category) {
      case 'Strength':
        return strengthExercises;
      case 'Cardio':
        return cardioExercises;
      default:
        return [];
    }
  }
}