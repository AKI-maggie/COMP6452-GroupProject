const express = require('express');
const app = express();
const morgan = require('morgan'); // from error handler
const bodyParser = require('body-parser');

const productRoutes = require('./api/routes/products');
//const orderRoutes = require('./api/routes/orders');

app.use(morgan('dev'));
app.use(bodyParser.urlencoded({extended: false}));
app.use(bodyParser.json());
/*
app.use((req,res,next) => {
    res.header("Access-Control-Allow-Origin","*");
    res.header(
        "Access-Control-Headers",
        "Origin,X-Requested-With, Content-Type,Accept,Authorization"
    );
    if(req.method === 'OPTIONS'){
        res.header('Access-Control-Allow-Methods','PUT,POST,PATH,DELETE,GET');
        return res.status(200).json({});
    }
});
*/
app.use('/records',productRoutes);
//app.use('/orders',orderRoutes);

app.use((req,res,next) => {
    const error = new Error('Not found');
    error.status = 404;
    next(error);
});

app.use((error,req,res,next) => {
    res.status(error.status || 500);
    res.json({
        error:{
            message: error.message
        }
    });
});

module.exports = app;