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
 return message is the ipfs hash you can use this hash to check out the database detail is in below hash part
</br>
https://guarded-sands-73970.herokuapp.com/records/Comment
post comment to ipfs provide :</br>
```js
 const comment = { 
            review : req.body.review,
            author : req.body.author,
            positive : req.body.positive,
            comment : req.body.comment,
            restaurant : req.body.restaurant,
            receipt : req.body.receipt
        }
```
return message is the ipfs hash you can use this hash to check out the database detail is in below hash part
</br>
To access ipfs database: </br>
Hash file link : https://guarded-sands-73970.herokuapp.com/records/ipfs  </br>
when you want to access the ipfs database link is : https://ipfs.infura.io/ipfs/ + {hash from above address}
</br>
</br>
For restaurant register, get coupon and use coupon : </br>
https://guarded-sands-73970.herokuapp.com/coupons </br>
with all coupons detail </br>
https://guarded-sands-73970.herokuapp.com/coupons/#senderAddress </br>
GET method to receive a $5 coupon from system return message is the coupon id </br>
https://guarded-sands-73970.herokuapp.com/coupons/used/#senderAddress </br>
GET method to used a coupon by providing the sender add, if the current sender has unused coupon return message success otherwise return message current user do not have any coupon </br>
https://guarded-sands-73970.herokuapp.com/coupons/register </br>
POST method to register restaurant need to provide restaurant name and sender address. Each address can only register for 1 restaurant: </br>
```js  
    const restaurant = {
        name: req.body.name,
        address: req.body.add
    }
```
return message success if registeration is success else is because that address is already register </br>

# Reference Tutorials
Build of REST API: </br>
https://www.youtube.com/playlist?list=PL55RiY5tL51q4D-B63KBnygU6opNPFk_q </br>
To publish api: </br>
https://dzone.com/articles/create-and-publish-your-rest-api-using-spring-boot

# Ether and function use
newComment/Review 0.02 ether/call </br>
uploadipfs(string option) 0.0008 ether/call </br>
*option can be either 'comment' or 'review'

# How to run the contracts under a local server environment
1. Setting up your environment and tools
`npm install -g truffle ethereumjs-testrpc`
2. Go to the 'oracle' directory in the project
3. Install necessary things using the following instruction
`npm install truffle-contract web3 bluebird npm-fetch --save  # Dependencies`
4. Install server provider Ganeche-cli using the following instruction
`npm install ganache-cli`
5. Use a terminal to run the server at local host with the following instruction
`ganache-cli`
6. Open Remix. Compile and deploy all the contracts with the order of StringTools.sol, Backend.sol, UserITF.sol. And then copy the contract address of `Backend.sol`.
7. Open `oracle.js` in the 'oracle' directory. Replace the value of `account` and `address` at the top with the account who deployed the contract and the address of deployed Backend.sol.
8. Run `node oracle.js` in another terminal.
9. Carry out contract interactions on the Remix interface.

Now you can check the output of the js terminal when you try the operations on Remix. **Notice** that you need to also replace the abi in the `oracle.js` everytime you make some changes in the `Backend.sol` file. And **always** check if the monitoring account and address are the one running on Remix.

Reference from https://kndrck.co/posts/ethereum_oracles_a_simple_guide/
