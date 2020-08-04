COMP6452-GroupProject

************************************************************************************************************************************

Environment for running API
- Require node.js, port 5000
- npm install --save express
- npm install morgan
- npm install body-parser
- npm start
   to run the server

************************************************************************************************************************************

API publish link (use Heroku cloud platform to publish the API into public network)
1) For review/comments/receipts :

   https://guarded-sands-73970.herokuapp.com/records 
   with normal get method to get all receipts detail

   https://guarded-sands-73970.herokuapp.com/records/#restaurantName/#receipt_num
   need to provide both restaurant name and its receipt num, receive the json object containing all information of that receipt

2) For store comments and reviews (post method only):

  Post review link:
  https://guarded-sands-73970.herokuapp.com/records/Review
  post review to ipfs need to provide :

  const review = {
            author : etherum address of author,
            restaurant : string of restaurant,
            content : string of content,
            credits : string of credits,
            receipt : string of receipt number
  }
  return message is the ipfs hash you can use this hash to check out the database detail is in below hash part

  Post comment link:
  https://guarded-sands-73970.herokuapp.com/records/Comment
  post comment to ipfs provide :

   const comment = { 
            review : id of review,
            author : address of author,
            positive : bool string of positive,
            comment : string of comment,
            restaurant : string of restaurant,
            receipt : string receipt number
   }
  return message is the ipfs hash you can use this hash to check out the database detail is in below hash part

  To access ipfs database:
  1. Go to the link that stores the ipfs hash : https://guarded-sands-73970.herokuapp.com/records/ipfs
  2. Use the hash from above access ipfs database :  https://ipfs.infura.io/ipfs/#hash from above address

3) For restaurant register, get coupon and use coupon :
   
  https://guarded-sands-73970.herokuapp.com/coupons
  with all coupons detail

  https://guarded-sands-73970.herokuapp.com/coupons/#senderAddress
  GET method to receive a $5 coupon from system return message is the coupon id

  https://guarded-sands-73970.herokuapp.com/coupons/used/#senderAddress
  GET method use to use a coupon by providing the sender add, if the current sender has unused coupon return message success otherwise return message current user do not have any coupon
 
  https://guarded-sands-73970.herokuapp.com/coupons/register
  POST method to register restaurant need to provide restaurant name and sender address. Each address can only register for 1 restaurant
  need to provide:

    const restaurant = {
        name: string of restaurant name,
        address: etherum address of sender(restaurant)
    }
  return message success if registeration is success else is because that address is already register

************************************************************************************************************************************

Reference Tutorials of API
  Build of REST API:
  https://www.youtube.com/playlist?list=PL55RiY5tL51q4D-B63KBnygU6opNPFk_q
  To publish API:
  https://dzone.com/articles/create-and-publish-your-rest-api-using-spring-boot

************************************************************************************************************************************

Ether and function use
  newComment/Review 0.02 ether/call
  uploadipfs(string option) 0.0008 ether/call
  *option can be either 'comment' or 'review'

************************************************************************************************************************************

How to run a local server (listener of smart contract)
  1. Setting up your environment and tools npm install -g truffle ethereumjs-testrpc
  2. Go to the 'oracle' directory in the project
  3. Install necessary things using the following instruction npm install truffle-contract web3 bluebird npm-fetch --save # Dependencies
  4. Install server provider Ganeche-cli using the following instruction npm install ganache-cli
  5. Use a terminal to run the server at local host with the following instruction ganache-cli
  6. Open Remix. Compile and deploy the contracts and then copy the contract address of Backent.sol.
  7. Open oracle.js in the 'oracle' directory. Replace the value of account and address at the top.
  8. Run node oracle.js in another terminal.

  Now you can check the output of the js terminal when you try the operations on Remix. Notice that you need to also replace the abi in the  oracle.js everytime you make some changes in the Backend.sol file. And always check if the monitoring account and address are the one  running on Remix.

  Reference from https://kndrck.co/posts/ethereum_oracles_a_simple_guide/