(function() {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.LSIImagePlugin = (function(_super) {
    __extends(LSIImagePlugin, _super);

    function LSIImagePlugin() {
      _ref = LSIImagePlugin.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    LSIImagePlugin.prototype.init = function() {
      var annotation, _i, _len, _ref1, _results;
      this.name = 'LSIImagePlugin';
      annotation = void 0;
      console.info("Initialize LSIImagePlugin");
      _ref1 = this.lime.annotations;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        annotation = _ref1[_i];
        if (annotation.resource.value.indexOf("geonames") < 0) {
          _results.push(this.handleAnnotation(annotation));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    LSIImagePlugin.prototype.handleAnnotation = function(annotation) {
      var _this = this;
      return annotation.entityPromise.done(function(entities) {
        var nonConcept, widget;
        nonConcept = annotation.getDescription();
        nonConcept = nonConcept.replace("No description found.", "");
        if (nonConcept.length >= 3) {
          widget = _this.lime.allocateWidgetSpace(_this, {
            thumbnail: "img/pic.png",
            title: "" + (annotation.getLabel()) + " Pics",
            type: "DbpediaInfoWidget",
            sortBy: function() {
              return 10000 * annotation.start + annotation.end;
            }
          });
          widget.annotation = annotation;
          jQuery(widget).bind('activate', function(e) {
            return _this.getModalContainer().html(_this.renderAnnotation(annotation));
          });
          annotation.widgets[_this.name] = widget;
          jQuery(annotation).bind("becomeActive", function(e) {
            return annotation.widgets[_this.name].setActive();
          });
          return jQuery(annotation).bind("becomeInactive", function(e) {
            return annotation.widgets[_this.name].setInactive();
          });
        }
      });
    };

    LSIImagePlugin.prototype.renderAnnotation = function(annotation) {
      var label, labelObj, result, returnResult,
        _this = this;
      returnResult = "";
      if (annotation) {
        labelObj = _(annotation.entity["rdfs:label"]).detect(function(labelObject) {
          return labelObject['@language'] === _this.lime.options.preferredLanguage;
        });
        label = labelObj['@value'];
        result = "<div class=\"LSIImageWidget\">\n <table style=\"margin:0 auto; width: 100%;\">\n   <tr>\n     <td>\n       <b class=\"utility-text\">" + (annotation.getLabel()) + " Pics </b>\n     </td>\n     <td>\n       <img class=\"utility-icon\" src=\"img/pic.png\" style=\"float: right; width: 25px; height: 25px; \" >\n    </td>\n   </tr>\n </table>\n</div>";
      }
      return result;
    };

    return LSIImagePlugin;

  })(window.LimePlugin);

}).call(this);
