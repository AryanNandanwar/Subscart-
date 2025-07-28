import mongoose, {Schema} from "mongoose";

const mealSchema = new Schema(
    {
        title: {
            type: String,
            required: true,
            unique: true,
            trim: true,
        },
        protein: {
            type: String,
            required: true,
            trim: true, 
            
        },
        fat: {
            type: String,
            required: true,
            trim: true, 
            
        },
        carbohydrates: {
            type: String,
            required: true,
            trim: true, 
            
        },
        calories: {
            type: String,
            required: true,
            trim: true, 
            
        },
        duration: {
            type: String,
            required: true,
            trim: true, 
            
        }
    },
    {
        timestamps: true
    }
)



export const Meal = mongoose.model("Meal", mealSchema)