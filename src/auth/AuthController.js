var express = require('express');
var router = express.Router();
var bodyParser = require('body-parser');
router.use(bodyParser.urlencoded({ extended: false }));
router.use(bodyParser.json());
var User = require('../user/User');

var jwt = require('jsonwebtoken');
var bcrypt = require('bcryptjs');
var config = require('../config');

const VerifyToken = require('./VerifyToken');

router.post('/register', function(req, res) {

    User.findOne({ email: req.body.email }, function (err, user) {
        if (err) return res.status(500).send('Error on the server.');
        if (user) return res.status(403).send('User already exist.'); 

        var hashedPassword = bcrypt.hashSync(req.body.password, 8);
        User.create({
        name : req.body.name,
        email : req.body.email,
        password : hashedPassword,
        address: req.body.address,
        privillageLevel: req.body.privillageLevel 
        },
        function (err, user) {
        if (err) return res.status(500).send("There was a problem registering the user.")
        // create a token
        var token = jwt.sign({ id: user._id }, config.secret, {
            expiresIn: 3600 // expires in 1 hour
        });
        res.status(200).send({ auth: true, token: token });
        }); 

    });
  
  });

  router.get('/me', VerifyToken,  function(req, res) {
    User.findById(req.userId, 
        {password: 0},
        function (err, user) {
        if (err) return res.status(500).send("There was a problem finding the user.");
        if (!user) return res.status(404).send("No user found.");
        
        res.status(200).send(user);
    });
  });
  
  router.post('/login', function(req, res) {

    User.findOne({ email: req.body.email }, function (err, user) {
      if (err) return res.status(500).send('Error on the server.');
      if (!user) return res.status(404).send('No user found.');
      
      var passwordIsValid = bcrypt.compareSync(req.body.password, user.password);
      if (!passwordIsValid) return res.status(401).send({ auth: false, token: null });
      
      var token = jwt.sign({ id: user._id }, config.secret, {
        expiresIn: 3600 // expires in 1 hour
      });
      
      res.status(200).send({ auth: true, token: token });
    });
    
  });

  // UPDATES A SINGLE USER IN THE DATABASE
router.post('/update', VerifyToken, function (req, res) {
    User.findByIdAndUpdate(req.userId, 
        {
            location: req.body.location,
            companyName: req.body.companyName,
            phoneNumber: req.body.phoneNumber
        },
        {new: true}, function (err, user) {
        if (err) return res.status(500).send("There was a problem updating the user.");
        res.status(200).send("User details updated successfully.");
    });
});

  router.get('/logout', function(req, res) {
    res.status(200).send({ auth: false, token: null });
  });
  

  module.exports = router;