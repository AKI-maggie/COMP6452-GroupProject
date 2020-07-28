/*
File of base route https://guarded-sands-73970.herokuapp.com/coupons/
Includes restaurant register, get coupon. All though get/post method of REST API
**/
const express = require('express');
const fs = require('fs');
const { route } = require('../../app');
const { finished } = require('stream');
const router = express.Router();
let rawdata = fs.readFileSync('./api/routes/coupons.json');
const records = JSON.parse(rawdata);
let data = fs.readFileSync('./api/routes/restaurants.json');
const restaurants = JSON.parse(data);

function check(address){
    for(var i = 0; i < restaurants.result.length; i ++){
        if (restaurants.result[i].address === address){
            return false;
        }
    }
    return true;
}

router.get('/',(req, res, next) => {
    res.status(200).json(records);
});


router.get('/restaurant',(req, res, next) => {
    res.status(200).json(restaurants);
});

router.get('/:add',(req, res, next) => {
    const record = {
        belongTo: req.params.add ,
        coupon_id: records.result.length,
        value: 5,
    }
    res.status(201).json({
        message: record.coupon_id
    });
    records.result.push(record);
    fs.writeFileSync('./api/routes/coupons.json', JSON.stringify(records));
    
});

router.get('/used/:add',(req, res, next) => {
    const after = [];
  //  const id = req.params.id;
    const add = req.params.add;
    var flag = false;
    for(var i = 0; i < records.result.length; i ++){
        if (records.result[i].belongTo === add){
            flag = true;
        }
        else{
            after.push(records.result[i]);
        }
    }
    if (flag){
        records.result = after;
        fs.writeFileSync('./api/routes/coupons.json', JSON.stringify(records));
        res.status(201).json({
            message: "Success"
        });
    }
    else{
        res.status(500).json({
            message: "Current user do not have any coupon"
        });
    }

});

router.post('/register',(req, res, next) => {
    
    const restaurant = {
        id : restaurants.result.length,
        name: req.body.name,
        address: req.body.add
    }
    if(check(restaurant.address)){
        restaurants.result.push(restaurant);
        fs.writeFileSync('./api/routes/restaurants.json', JSON.stringify(restaurants));
        res.status(201).json({
            message: "Success"
        });
    }
    else{
        res.status(500).json({
            message: "Already register"
        }); 
    }
});


module.exports = router;