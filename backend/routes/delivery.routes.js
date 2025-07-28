import { Router } from "express";
import { createDelivery,  getDeliveriesByDay, updateDeliveryDayAndTime, getMealsByDelivery } from "../controllers/delivery.controller.js";

const router = Router()

router.route('/create-delivery').post(createDelivery)
router.route('/get-deliveries').post(getDeliveriesByDay)
router.route('/reschedule-delivery/:deliveryId').put(updateDeliveryDayAndTime)
router.route('/get-meals/:deliveryId').get(getMealsByDelivery)



export default router