var mongoose = require('mongoose');  
var UserSchema = new mongoose.Schema({  
  name: String,
  email: String,
  password: String,
  address: String,
  privillageLevel: String,
  location: String,
  companyName: String,
  phoneNumber: String
});
mongoose.model('User', UserSchema);

module.exports = mongoose.model('User');