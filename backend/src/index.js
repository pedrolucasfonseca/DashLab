const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const healthRoutes = require('./routes/health');
const apiRoutes = require('./routes/api');

const app = express();
const PORT =  process.env.PORT || 3001;

app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

app.use('/health', healthRoutes);
app.use('/api', apiRoutes);

app.listen(PORT, () => {console.log(`DashLab (BackEnd) rodando na porta ${PORT}`)});

module.exports = app;