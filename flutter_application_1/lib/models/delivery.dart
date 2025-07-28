import 'meal.dart';

class Delivery {
  final String id, time, address, deliveryType;
  final String day;
  List<Meal> meals;
  Delivery({required this.id, required this.day, required this.meals, required this.time, required this.address, required this.deliveryType});

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['_id'] as String?           ?? '', 
      time: json['time'] as String?        ?? '',
      address: json['address'] as String?  ?? '',
      deliveryType: json['delivery_type'] as String? ?? '',
      day: json['day'] as String?          ?? '',
      meals: (json['meals'] as List)
          .map((mealJson) => Meal.fromJson(mealJson))
          .toList(),
    );
  }
}