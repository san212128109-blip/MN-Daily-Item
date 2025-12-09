require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const session = require('express-session');
const MongoStore = require('connect-mongo');
const path = require('path');
const bodyParser = require('body-parser');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const productRoutes = require('./routes/products');
const cartRoutes = require('./routes/cart');
const adminRoutes = require('./routes/admin'); // <-- added

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

// serve uploaded images
app.use('/uploads', express.static(path.join(__dirname, 'public','uploads')));

mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(()=> console.log('MongoDB connected'))
  .catch(err => console.error('MongoDB err', err));

app.use(session({
  secret: process.env.SESSION_SECRET || 'secret',
  resave: false,
  saveUninitialized: false,
  store: MongoStore.create({ mongoUrl: process.env.MONGO_URI }),
  cookie: { maxAge: 1000 * 60 * 60 * 24 } // 1 day
}));

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/admin', adminRoutes); // <-- added

// Serve frontend pages
app.get('/', (req,res)=> res.sendFile(path.join(__dirname,'public','index.html')));
app.get('/product.html', (req,res)=> res.sendFile(path.join(__dirname,'public','product.html')));
app.get('/cart.html', (req,res)=> res.sendFile(path.join(__dirname,'public','cart.html')));
app.get('/auth.html', (req,res)=> res.sendFile(path.join(__dirname,'public','auth.html')));
app.get('/admin.html', (req,res)=> res.sendFile(path.join(__dirname,'public','admin.html')));
app.get('/admin-login.html', (req,res)=> res.sendFile(path.join(__dirname,'public','admin-login.html')));

app.listen(PORT, ()=> console.log(`MN Daily Items running on http://localhost:${PORT}`));
