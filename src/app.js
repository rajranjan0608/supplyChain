var express = require('express');
var app = express();

//login API
var db = require('./db');

const MainContract = require('../build/contracts/MainContract.json');

app.use(express.static("public"));

app.get('/', (req,res) => {
    res.send('index.html');
});

app.get('/MainContract', (req,res) => {
    res.send(MainContract);
});

//login API--------------

var AuthController = require('./auth/AuthController');
app.use('/api/auth', AuthController);

//-----------------------

app.listen(3000, () => {
    console.log('Server started at 3000');
})