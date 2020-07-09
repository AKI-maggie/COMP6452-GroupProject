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
https://guarded-sands-73970.herokuapp.com/records 
with normal get/post method </br>
https://guarded-sands-73970.herokuapp.com/records/#restaurantName/#receipt_num </br>
need to provide both restaurant name and its receipt num, receive the json object containing all information
</br>
post receipt number to the request body to change the status of receipt into used 

# Reference Tutorials 
Build of REST API: </br>
https://www.youtube.com/playlist?list=PL55RiY5tL51q4D-B63KBnygU6opNPFk_q </br>
To publish api: </br>
https://dzone.com/articles/create-and-publish-your-rest-api-using-spring-boot
