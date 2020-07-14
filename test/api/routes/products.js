const express = require('express');
const fs = require('fs');
const { route } = require('../../app')
const router = express.Router();

let rawdata = fs.readFileSync('./api/routes/examples.json');
const records = JSON.parse(rawdata);
//console.log(records.result[0].name);

router.get('/',(req, res, next) => {
    res.status(200).json(records);
});
/*
router.post('/',(req, res, next) => {
    if(req.body != null){
        const record = {
            name: req.body.name,
            receipt_num: req.body.receipt_num,
            order_num: req.body.order_num,
            time: req.body.time,
            status: "false"
        }
        res.status(201).json({
            message: 'Handling POST request to /products',
            createdRecord: record
        });
        records.result.push(record);
        fs.writeFileSync('./api/routes/examples.json', JSON.stringify(records));
    }
    else{
        res.status(500).json({
            message: 'body missing'
        });
    }
});
*/
router.get('/:restaurant/:receiptNum',(req, res, next) => {
    const name = req.params.restaurant;
    const receipt = req.params.receiptNum;
    const matches = [];
    for (var i = 0; i < records.result.length; i++){
        if (records.result[i].name === name && records.result[i].receipt_num === receipt){
            matches.push(records.result[i]);
        }
    }
    res.status(200).json({
        results: matches[0]
    });
});

router.post('/',(req, res, next) => {  
    if(req.body.receipt_num != null){
        for (var i = 0; i < records.result.length; i++){
            if (records.result[i].receipt_num === req.body.receipt_num){
                records.result[i].status = "true";
            }
        }
        res.status(200).json({
            message : "success"
        });
        fs.writeFileSync('./api/routes/examples.json', JSON.stringify(records));
    }
});


module.exports = router;