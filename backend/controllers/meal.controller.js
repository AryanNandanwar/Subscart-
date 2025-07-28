import { asyncHandler } from '../utils/asyncHandler.js';
import { Meal } from '../models/meal.models.js'; 
import { ApiError } from '../utils/ApiError.js';  
import { ApiResponse } from '../utils/ApiResponse.js';  
import { Delivery } from '../models/delivery.models.js';

const createMeal = asyncHandler(async (req, res) => {
    const {
        title,
        protein,
        fat,
        carbohydrates,
        calories,
        duration
    } = req.body;

    // Check for missing fields
    if (!title || !protein || !fat || !carbohydrates || !calories || !duration) {
        throw new ApiError(400, "All fields are required");
    }

    // Check for existing meal
    const existingMeal = await Meal.findOne({ title });
    if (existingMeal) {
        throw new ApiError(409, "Meal with this title already exists");
    }

    const newMeal = await Meal.create({
        title,
        protein,
        fat,
        carbohydrates,
        calories,
        duration
    });

    return res.status(201).json(
        new ApiResponse(201, newMeal, "Meal created successfully")
    );
});

const addMealToDelivery = asyncHandler(async (req, res) => {
    const { deliveryId, mealId } = req.body;

    if (!deliveryId || !mealId) {
        throw new ApiError(400, "Both deliveryId and mealId are required");
    }

    const delivery = await Delivery.findById(deliveryId);
    if (!delivery) {
        throw new ApiError(404, "Delivery not found");
    }

    const meal = await Meal.findById(mealId);
    if (!meal) {
        throw new ApiError(404, "Meal not found");
    }

    // Avoid duplicate entries
    if (!delivery.meals.includes(mealId)) {
        delivery.meals.push(mealId);
        await delivery.save();
    }

    return res.status(200).json(
        new ApiResponse(200, delivery, "Meal added to delivery successfully")
    );
});




export {
    createMeal, 
    addMealToDelivery,
}
