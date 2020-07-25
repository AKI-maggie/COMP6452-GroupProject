# COMP6452-GroupProject
This repo contains related files to run the group project of COMP6452 20T2

# Environment for running api
Require node.js, port 5050</br>
npm install --save express </br>
npm install morgan </br>
npm install body-parser </br>
npm start </br>
to run the server

# API publish link
For review/comments/receipts : </br>
https://guarded-sands-73970.herokuapp.com/records 
with normal get method to get all receipts detail</br>
https://guarded-sands-73970.herokuapp.com/records/#restaurantName/#receipt_num </br>
need to provide both restaurant name and its receipt num, receive the json object containing all information of that receipt
</br>
For store comments and reviews (post method only): </br>
https://guarded-sands-73970.herokuapp.com/records/Review </br>
post review to ipfs provide : </br>
```js
  const review = {
            author : req.body.author,
            restaurant : req.body.restaurant,
            content : req.body.content,
            credits : req.body.credits,
            receipt : req.body.receipt
  }
 ```
</br>
</br>
hash file link : https://guarded-sands-73970.herokuapp.com/records/ipfs  </br>
when you want to access the ipfs database link is : https://ipfs.infura.io/ipfs/ + {hash from above address}
</br>

# Reference Tutorials 
Build of REST API: </br>
https://www.youtube.com/playlist?list=PL55RiY5tL51q4D-B63KBnygU6opNPFk_q </br>
To publish api: </br>
https://dzone.com/articles/create-and-publish-your-rest-api-using-spring-boot

# Ether and function use
newComment/Review 0.02 ether/call </br>
uploadipfs(string option) 0.0008 ether/call </br>
*option can be either 'comment' or 'review'
