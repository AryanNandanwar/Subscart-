import { asyncHandler } from '../utils/asyncHandler.js';
import { Delivery } from '../models/delivery.models.js'; 
import { ApiError } from '../utils/ApiError.js';
import { ApiResponse }from '../utils/ApiResponse.js';


const createDelivery = asyncHandler(async (req, res) => {
    const { time, address, delivery_type, meals, day } = req.body;

    // Validate required fields
    if (!time || !address || !day) {
        throw new ApiError(400, "Time and at least one address are required.");
    }

    const newDelivery = await Delivery.create({
        time,
        address,
        day,
        delivery_type: delivery_type || 'Delivery',
        meals: meals || []  // Optional list of Meal ObjectIds
    });

    return res.status(201).json(
        new ApiResponse(201, newDelivery, "Delivery created successfully")
    );
});

const getDeliveriesByDay = asyncHandler(async (req, res) => {
    const { day } = req.body; // Example: "2025-07-25"

    if (!day) {
        throw new ApiError(400, "Day is required");
    }

    const deliveries = await Delivery.find({ day }).populate('meals');

    if (!deliveries || deliveries.length === 0) {
        throw new ApiError(404, "No deliveries found for the specified day");
    }

    return res.status(200).json(
        new ApiResponse(200, deliveries, "Deliveries fetched successfully")
    );
});

const updateDeliveryDayAndTime = asyncHandler(async (req, res) => {
  const { deliveryId } = req.params;
  const { day, time } = req.body;

  if (!day || !time) {
    throw new ApiError(400, "Both day and time are required");
  }

  const delivery = await Delivery.findById(deliveryId);
  if (!delivery) {
    throw new ApiError(404, "Delivery not found");
  }

  delivery.day = day;
  delivery.time = time;
  await delivery.save();

  return res.status(200).json(
    new ApiResponse(200, delivery, "Delivery day and time updated successfully")
  );
});

const getMealsByDelivery = asyncHandler(async (req, res) => {
    const { deliveryId } = req.params;

    if (!deliveryId) {
        throw new ApiError(400, "Delivery ID is required");
    }

    // Find delivery and populate meals
    const delivery = await Delivery.findById(deliveryId).populate('meals');

    if (!delivery) {
        throw new ApiError(404, "Delivery not found");
    }

    return res.status(200).json(
        new ApiResponse(200, delivery.meals, "Meals fetched successfully for this delivery")
    );
});



export {
    createDelivery,
    getDeliveriesByDay,
    updateDeliveryDayAndTime,
    getMealsByDelivery
} 
