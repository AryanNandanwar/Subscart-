
import express from 'express';
import cors from 'cors';
import cookieParser from 'cookie-parser';

const app = express();

app.use(cors({
    origin: process.env.CORS_ORIGIN,
    credentials: true
}))

app.options('*', cors());

// body parsing, static, cookies
app.use(express.json({ limit: '16kb' }))
app.use(express.urlencoded({ extended: true, limit: '16kb' }))
app.use(express.static('public'))
app.use(cookieParser())


import mealRouter from './routes/meal.routes.js'
import deliveryRouter from './routes/delivery.routes.js'


app.use('/api/meal', mealRouter)
app.use('/api/delivery', deliveryRouter)

export { app }