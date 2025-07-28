import { Router } from "express";
import { createMeal, addMealToDelivery } from "../controllers/meal.controller.js";

const router = Router()

router.route('/create-meal').post(createMeal)
router.route('/add-meal').post(addMealToDelivery)


export default router