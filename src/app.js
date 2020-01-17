var express = require('express');
var app = express();

const MainContract = require('../build/contracts/MainContract.json');

app.use(express.static("public"));

app.get('/', (req,res) => {
    res.send('index.html');
});

app.get('/MainContract', (req,res) => {
    res.send(MainContract);
});

app.listen(3000, () => {
    console.log('Server started at 3000');
})