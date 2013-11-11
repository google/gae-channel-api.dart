channels = {};

goog = {
  'appengine': {
    'Channel': function(token) {
      this.token = token;
      this.opened = false;
      this.socket = null;
      
      channels[token] = this;
      
      this.open = function(config) {
        this.opened = true;
        this.socket = new goog.appengine.Socket(config); 
        return this.socket;
      }
    },
    'Socket': function(config) {
      console.log("new Socket");
      this.config = config;
    }
  }
};
