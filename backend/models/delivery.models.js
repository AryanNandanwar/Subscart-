import mongoose, {Schema} from "mongoose";

const deliverySchema = new Schema(
    {
        time: {
            type: String,
            required: true,
            trim: true,
        },
        address:{
            type: String,
            required: true,
            trim: true,   
        },
        delivery_type: {
            type: String,
            enum: ['Delivery', 'Pickup'],
            default: 'Delivery',   
        },
        day: {
            type: String,
            required: true,
            trim: true,
        },
        meals: [{
            type: Schema.Types.ObjectId,
            ref: 'Meal',
        }],
        
    },
    {
        timestamps: true
    }
)



export const Delivery = mongoose.model("Delivery", deliverySchema)