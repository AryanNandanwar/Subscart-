import 'package:flutter/material.dart';
import 'screens/meal_plan_screen.dart';

void main(){
  runApp(MyApp());

} 
class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Plan',
      theme: ThemeData(primarySwatch: Colors.green),
      home: MealPlanScreen(),
    );
  }
}