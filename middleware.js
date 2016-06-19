var bodyParser = require('body-parser');
var url = require('url');

// create application/json parser
var jsonParser = bodyParser.json()

// create application/x-www-form-urlencoded parser
var urlencodedParser = bodyParser.urlencoded({ extended: true })

module.exports = function (config) {
  return function(req, res, next){
    if(/test\//.test(req.url)){
      var url_parts = url.parse(req.url, true);
      req.query = url_parts.query;
      return jsonParser(req, res,
        function(err){
          if(err) return next(err);
          urlencodedParser(req, res, function(err){
            if(err) return next(err);
            APP.handle_request(req, res);
          });
        });
    }

    next();
  }
};

var APP = {
  handle_request: function(req, res) {
    if(/echo/.test(req.url)){
      return this["handle_echo_" + req.method.toLowerCase()](req, res);
    }
    res.writeHead(404);
    res.end('Not found');
  },

  handle_echo_get: function(req, res) {
    this.responseJson(res, req.query);
  },

  handle_echo_post: function(req, res) {
    data = { post: req.body };
    this.responseJson(res, { post: req.body });
  },

  handle_echo_patch: function(req, res) {
    data = { patch: req.body };
    this.responseJson(res, { patch: req.body });
  },

  handle_echo_put: function(req, res) {
    data = { put: req.body };
    this.responseJson(res, { put: req.body });
  },

  handle_echo_delete: function(req, res) {
    data = { delete: req.body };
    this.responseJson(res, { delete: req.body });
  },

  responseJson: function(res, data) {
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify(data));
  }
}
