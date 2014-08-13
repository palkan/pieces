express = require('express');

app = express(); 

app.use(express.static(__dirname + '/public'));

var multipart = require('connect-multiparty');
var multipartMiddleware = multipart();

var bodyParser = require('body-parser');
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

exports.startServer = function(port, path, callback){ 
  app.get('/', function(req, res){ res.sendfile('./public/index.html') }); 
  
  app.post('/upload', multipartMiddleware, function(req, res) {
    data = {data: req.body, files: req.files}
    res.send(JSON.stringify(data));
  });

  app.post('/echo', multipartMiddleware, function(req, res) {
    data = {post: req.body};
    console.log(data);
    res.json({post: req.body});
  });

  app.patch('/echo', multipartMiddleware, function(req, res) {
    res.json({patch: req.body});
  });

  app.delete('/echo', multipartMiddleware, function(req, res) {
    res.json({'delete': req.body});
  });

  app.get('/echo', function(req, res) {
    res.json(req.query);
  });

  app.listen(port) 
  console.log('Listening on port: #{port}')
}