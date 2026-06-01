const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const morganFormat = process.env.NODE_ENV === 'production' ? 'combined' : 'dev';
require('dotenv').config();

const healthRoutes = require('./routes/health');
const apiRoutes = require('./routes/api');

const app = express();

app.use(helmet());
app.use(cors());
app.use(morgan(morganFormat));
app.use(express.json());

app.use('/health', healthRoutes);
app.use('/api', apiRoutes);

module.exports = app;