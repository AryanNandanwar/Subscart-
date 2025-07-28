class Meal {
  final String title;
  final String protein, fat, carbs, calories;
  final String deliveryType;
  final String timeEstimate;
  Meal({
    required this.title, required this.protein, required this.fat, 
    required this.carbs, required this.calories,
    required this.deliveryType, required this.timeEstimate
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      title:           json['title'] as String?            ?? '',
      protein:        json['protein'] as String?         ?? '0',
      fat:            json['fat'] as String?             ?? '0',
      carbs:          json['carbs'] as String?           ?? '0',
      calories:       json['calories'] as String?        ?? '0',
      deliveryType:   json['deliveryType'] as String?    ?? '',
      timeEstimate:   json['timeEstimate'] as String?    ?? '',
    );
  }
}