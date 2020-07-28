/*
File of base route https://guarded-sands-73970.herokuapp.com/records/
Includes reciept authorification, review/comment upload, review credit update and ipfs database file upload
authorification through rest api request
review/comment upload, review credit update through api to upload into ipfs system
**/

const IPFS = require('ipfs-api');
const ipfs = IPFS({host: 'ipfs.infura.io', port: 5001, protocol: 'https'});
const express = require('express');
const fs = require('fs');
const { route } = require('../../app')
const router = express.Router();
let rawdata = fs.readFileSync('./api/routes/examples.json');
const records = JSON.parse(rawdata);

//console.log(records.result[0].name);
function sendIPFS(buffer){
    ipfs.files.add(buffer, function (err, hash) {
        if (err) {
          console.log(err);
        }
        console.log(hash);
     //   console.log('https://ipfs.infura.io/ipfs/'+hash);
        const link = 'https://ipfs.infura.io/ipfs/'+hash.hash;
        return link;
      })
}
router.get('/',(req, res, next) => {
    res.status(200).json(records);
});



router.get('/:restaurant/:receiptNum',(req, res, next) => {
    const name = req.params.restaurant;
    const receipt = req.params.receiptNum;
    const matches = [];
    const data = []

    for (var i = 0; i < records.result.length; i++){
        if (records.result[i].name === name && records.result[i].receipt_num === receipt){
            matches.push(records.result[i]);
        }
        else{
           data.push(records.result[i]);
        }
    }
    if (matches.length > 0){
        res.status(200).json({
            result: matches[0].receipt_num
        });
      //  records.result = data;
      //  fs.writeFileSync('./api/routes/examples.json', JSON.stringify(data));
    }
    else{
        res.status(201).json({
            result: "false"
        });
    }
});
router.get('/ipfs',(req, res, next) => {
    let ipfsH = fs.readFileSync('./api/routes/ipfsHash.json');
    const obj = JSON.parse(ipfsH);
    res.status(200).json(obj);
});

router.get('/credit/:receipt/:rest/:credit',(req, res, next) => {
    const receipt = req.params.receipt;
    const restN = req.params.rest;
    const currCredit = req.params.credit;
    let data = fs.readFileSync('./api/routes/Reviews.json');
    const reviews = JSON.parse(data);
    var flag = false;
    for(var i = 0; i < reviews.result.length; i ++){
        if (reviews.result[i].restaurant === restN && reviews.result[i].receipt === receipt){
            reviews.result[i].credits = currCredit;
            flag = true;
        }
    }
    if(flag){
        fs.writeFileSync('./api/routes/Reviews.json', JSON.stringify(reviews));
        const file = Buffer.from(JSON.stringify(reviews));
        ipfs.files.add(file, function (err, hash) {
            if (err) {
            console.log(err);
            }
            console.log(hash);
         //   console.log(hash[0].hash);
        //   console.log('https://ipfs.infura.io/ipfs/'+hash);
         //   const link = 'https://ipfs.infura.io/ipfs/'+hash.hash;
            res.status(200).json({
                message : hash[0].hash
            });
            let ipfsH = fs.readFileSync('./api/routes/ipfsHash.json');
            const obj = JSON.parse(ipfsH);
            obj.Reviews = hash[0].hash;
            fs.writeFileSync('./api/routes/ipfsHash.json', JSON.stringify(obj));
        })
    }
    else{
        res.status(500).json({
            message: 'Could not find the review'
        });
    }
     
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

router.post('/Review',(req, res, next) => {  
    let data = fs.readFileSync('./api/routes/Reviews.json');
    const reviews = JSON.parse(data);
    if(req.body.author != null && req.body.restaurant != null && req.body.content != null && req.body.credits != null && req.body.receipt != null){
        const review = {
            author : req.body.author,
            restaurant : req.body.restaurant,
            content : req.body.content,
            credits : req.body.credits,
            receipt : req.body.receipt
        }
       
        reviews.result.push(review);
        fs.writeFileSync('./api/routes/Reviews.json', JSON.stringify(reviews));
        const file = Buffer.from(JSON.stringify(reviews));
        ipfs.files.add(file, function (err, hash) {
            if (err) {
            console.log(err);
            }
            console.log(hash);
         //   console.log(hash[0].hash);
        //   console.log('https://ipfs.infura.io/ipfs/'+hash);
         //   const link = 'https://ipfs.infura.io/ipfs/'+hash.hash;
            res.status(200).json({
                message : hash[0].hash
            });
            let ipfsH = fs.readFileSync('./api/routes/ipfsHash.json');
            const obj = JSON.parse(ipfsH);
            obj.Reviews = hash[0].hash;
            fs.writeFileSync('./api/routes/ipfsHash.json', JSON.stringify(obj));
        })
    }
    else{
        res.status(500).json({
            message: 'body missing'
        });
    }
});

/**
 *     struct Comment {
        bytes32 review;
        address author;
        bool positive;
        string comment;
        string restaurant;
        string receipt;
    }
 */
router.post('/Comment',(req, res, next) => {  
    let data = fs.readFileSync('./api/routes/Comment.json');
    const comments = JSON.parse(data);
    if(req.body.review != null && req.body.author != null && req.body.positive != null && req.body.comment != null  && req.body.restaurant != null && req.body.receipt != null){
        const comment = { 
            review : req.body.review,
            author : req.body.author,
            positive : req.body.positive,
            comment : req.body.comment,
            restaurant : req.body.restaurant,
            receipt : req.body.receipt
        }

        comments.result.push(comment);
        fs.writeFileSync('./api/routes/Comment.json', JSON.stringify(comments));

        const file = Buffer.from(JSON.stringify(comments));
        ipfs.files.add(file, function (err, hash) {
            if (err) {
            console.log(err);
            }
            console.log(hash);
         //   console.log(hash[0].hash);
        //   console.log('https://ipfs.infura.io/ipfs/'+hash);
         //   const link = 'https://ipfs.infura.io/ipfs/'+hash.hash;
            res.status(200).json({
                message : hash[0].hash
            });
            let ipfsH = fs.readFileSync('./api/routes/ipfsHash.json');
            const obj = JSON.parse(ipfsH);
            obj.Comments = hash[0].hash;
            fs.writeFileSync('./api/routes/ipfsHash.json', JSON.stringify(obj));
        })
    }
    else{
        res.status(500).json({
            message: 'body missing'
        });
    }
});

module.exports = router;