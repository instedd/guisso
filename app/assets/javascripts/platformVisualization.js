function PlatformVisualization(apps, cases, container) {

  EventDispatcher.call(this);
  InvalidateElement.call(this);

  var self = this;
  var MAX_STROKE_WIDTH = 10;
  var MIN_STROKE_WIDTH = 2;
  var MARGIN = 100;
  var _apps;
  var _cases;
  var _relations;
  var _extrema = {min:Number.MAX_VALUE, max:0};
  var _container;
  var _svg;
  var _caseId;
  var _width;
  var _height;
  var _radius;

  function init(apps, cases, container) {
    var size = MARGIN / 2;
   	var slice = Math.PI * 2 / apps.length;
   	_container = container;
    _width = _container.clientWidth;
    _height = _container.clientHeight;
    _radius = Math.max(0, (Math.min(_width, _height) - MARGIN * 2) / 2);
    _apps = createApps(apps, slice, size);
    _relations = createRelations(_apps, cases, _extrema);
    _cases = createCases(_apps, _relations, cases);
    _svg = createSVG();
    _container.appendChild(_svg);
    _svg.appendChild(drawCircle(_radius, {x:_width / 2, y:_height / 2}, "disabled", "fill:none;stroke-width:" + MAX_STROKE_WIDTH + ";"));
    _svg.appendChild(drawRelations(_relations, _extrema.min, _extrema.max));
		_apps.forEach(function (app) {
			_svg.appendChild(app.icon());
			_svg.appendChild(app.dot());
		});
		self.showCase();
  }

  self.showCase = function(id) {
  	resetStyles();
  	_caseId = id;
  	if(_caseId) {
	  	var relations = getCaseById(_caseId).relations();
	  	relations.forEach(function (relation) {
	  		enableRelation(relation, true);
	  		enableApp(relation.a(), true);
	  		enableApp(relation.b(), true);
	  	});
  	} else {
  		_apps.forEach(function (app) {
  			enableApp(app, true);
  		});
  	}
  }

  function createApps(data, slice, size) {
  	var apps = [];
    var index = 0;
    data.forEach(function (item) {
      var icon = document.createElementNS("http://www.w3.org/2000/svg","g");
      var x = Math.cos(slice * index) * (_radius + size) + _width / 2;
      var y = Math.sin(slice * index) * (_radius + size) + _width / 2 - size / 2 + 10;
      icon.setAttribute("transform", "translate(" + x +","+ y + ")");
      icon.setAttribute("style", "cursor:pointer");
      icon.setAttribute("data-x", x);
      icon.setAttribute("data-y", y);
      icon.setAttribute("data-id", item.id);
      icon.setAttribute("data-name", item.name);
      icon.setAttribute("data-index", index);
      icon.setAttribute("data-type", "app");
      var image = document.createElementNS("http://www.w3.org/2000/svg","image");
      image.setAttribute("x", -size / 2);
      image.setAttribute("y", -size / 2);
      image.setAttribute("width", size);
      image.setAttribute("height", size);
      image.setAttributeNS("http://www.w3.org/1999/xlink", "href", item.icon);
      icon.appendChild(image);
      var label = document.createElementNS("http://www.w3.org/2000/svg", "foreignObject");
      label.setAttribute("x", -size * 0.75);
      label.setAttribute("y", size / 2 - 5);
      label.setAttribute("width", size * 1.5);
      label.setAttribute("height", size);
      var p = document.createElement("p");
      p.setAttribute("xmlns", "http://www.w3.org/1999/xhtml");
      p.className = "label";
      p.textContent = item.name;
      label.appendChild(p);
      icon.appendChild(label);
      icon.addEventListener("mouseout", mouseHandler);
	    icon.addEventListener("mouseover", mouseHandler);
	    icon.addEventListener("click", mouseHandler);
      var app = new PlatformApp(item.id, item.name, icon);
      app.index(index);
      app.x(Math.cos(slice * index) * _radius + _width / 2);
      app.y(Math.sin(slice * index) * _radius + _height / 2);
	    app.dot(drawCircle((MIN_STROKE_WIDTH + MAX_STROKE_WIDTH) / 2, {x:app.x(), y:app.y()}, "disabled","fill:white;stroke-width:" + (MAX_STROKE_WIDTH / 2) + ";"));
      apps.push(app);
      index++;
    });
		return apps;
  }

  function createRelations(apps, data, extrema) {
  	var relations = [];
  	data.forEach(function (item) {
      item.relations.forEach(function(itemRelation) {
        var relation = relations[itemRelation.a + "-" + itemRelation.b] || relations[itemRelation.b + "-" + itemRelation.a];
        if(!relation) {
          relation = new PlatformRelation(getAppById(itemRelation.a), getAppById(itemRelation.b));
          var span = Math.abs(relation.a().index() - relation.b().index());
          relation.span(Math.min(span, apps.length - span));
          relations[itemRelation.a + "-" + itemRelation.b] = relation;
        }
        relation.increase();
        extrema.max = Math.max(extrema.max, relation.count());
     	 	extrema.min = Math.min(extrema.min, relation.count());
      });
    });
    extrema.min = extrema.min == extrema.max? 0 : extrema.min;
    return relations;
  }

  function createCases(apps, relations, data) {
  	var cases = [];
  	data.forEach(function (item) {
      var caseRelations = [];
      item.relations.forEach(function(itemRelation) {
        var relation = relations[itemRelation.a + "-" + itemRelation.b] || _relations[itemRelation.b + "-" + itemRelation.a];
        caseRelations.push(relation);
      });
      var platformCase = new PlatformCase(item.id, caseRelations);
      cases.push(platformCase);
    });
    return cases;
  }

  function createSVG() {
  	var svg = document.createElementNS("http://www.w3.org/2000/svg","svg");
    svg.setAttribute("xmlns", "http://www.w3.org/2000/svg");
    svg.setAttribute("xmlns:xlink", "http://www.w3.org/1999/xlink");
    var filter = document.createElementNS("http://www.w3.org/2000/svg","filter");
    filter.setAttribute("id", "greyscale");
    svg.appendChild(filter);
    var colorMatrix = document.createElementNS("http://www.w3.org/2000/svg","feColorMatrix");
    colorMatrix.setAttribute("type", "matrix");
    colorMatrix.setAttribute("values", "0.3333 0.3333 0.3333 0 0 0.3333 0.3333 0.3333 0 0 0.3333 0.3333 0.3333 0 0 0 0 0 1 0");
    filter.appendChild(colorMatrix);
    svg.setAttribute("width", _width);
    svg.setAttribute("height", _height);
    return svg;
  }

  function drawRelations(relations, min, max) {
    var group = document.createElementNS("http://www.w3.org/2000/svg","g");
    var all = relations == _relations;
    var apps = all? _apps : getAppList(relations);
    var key;
    for (key in relations) {
      var relation = relations[key];
      var context, ending;
      if(relation.a().index() < relation.b().index()) {
        context = {x:relation.a().x(), y:relation.a().y()};
        ending = {x:relation.b().x(), y:relation.b().y()};
      } else {
        context = {x:relation.b().x(), y:relation.b().y()};
        ending = {x:relation.a().x(), y:relation.a().y()};
      }
      var angle = relation.span() / _apps.length * Math.PI * 2;
      var radius = _radius * Math.tan(angle / 2);
      var length = Math.sin(angle / 2) * _radius;
      var sagitta = radius - Math.sqrt(Math.pow(radius, 2) - Math.pow(length, 2));
      var distance = Math.cos(angle / 2) * _radius - sagitta;
      var rotation = (Math.max(relation.a().index(), relation.b().index()) - relation.span() / (Math.abs(relation.a().index() - relation.b().index()) > _apps.length / 2? -2 : 2)) / _apps.length * Math.PI * 2;
      var control = {x:Math.cos(rotation) * distance + _width / 2, y:Math.sin(rotation) * distance + _height / 2};
      distance += radius;
      var center = {x:Math.cos(rotation) * distance + _width / 2, y:Math.sin(rotation) * distance + _height / 2};
      center = control
      var sweep = Math.abs(relation.a().index() - relation.b().index()) > _apps.length / 2;
      var strokeWidth = (MIN_STROKE_WIDTH + (MAX_STROKE_WIDTH - MIN_STROKE_WIDTH) * (relation.count() - min) / (max - min));
      var style = "fill:none;stroke-width:" + strokeWidth + ";";
      var arc = group.appendChild(document.createElementNS("http://www.w3.org/2000/svg","g"));
      arc.setAttribute("style", "cursor:pointer");
      arc.setAttribute("data-id-a", relation.a().id());
      arc.setAttribute("data-name-a", relation.a().name());
      arc.setAttribute("data-index-a", relation.a().index());
      arc.setAttribute("data-id-b", relation.b().id());
      arc.setAttribute("data-name-b", relation.b().name());
      arc.setAttribute("data-index-b", relation.b().index());
      arc.setAttribute("data-count", relation.count());
      arc.setAttribute("data-type", "relation");
      arc.addEventListener("mouseout", mouseHandler);
	    arc.addEventListener("mouseover", mouseHandler);
	    arc.addEventListener("click", mouseHandler);
      relation.arc(drawArc(context, radius, ending, sweep, "disabled", style));
      arc.appendChild(relation.arc());
      arc.appendChild(drawArc(context, radius, ending, sweep, "disabled", "fill:none;stroke-width:" + (MAX_STROKE_WIDTH * 2) + ";opacity:0"));
      relation.dot(drawCircle((MIN_STROKE_WIDTH + MAX_STROKE_WIDTH) / 2, control, "disabled","fill:white;stroke-width:" + (MAX_STROKE_WIDTH / 2) + ";"));
      relation.dot().setAttribute("visibility", "hidden");
      relation.dot().setAttribute("x", control.x);
      relation.dot().setAttribute("y", control.y);
      arc.appendChild(relation.dot());
    };
    _apps.forEach(function (app) {
      app.icon().setAttribute("data-disabled", "true");
    });
    return group;
  }

  function drawCircle(radius, center, className, style) {
    var circle = document.createElementNS("http://www.w3.org/2000/svg","circle");
    circle.setAttribute("r", radius);
    circle.setAttribute("cx", center.x);
    circle.setAttribute("cy", center.y);
    if(className) {
    	circle.setAttribute("class", className);
    }
    if(style) {
    	circle.setAttribute("style", style);
    }
    return circle;
  }

  function drawArc(context, radius, ending, sweep, className, style) {
    var arc = document.createElementNS("http://www.w3.org/2000/svg","path");
    var commands = "M" + context.x + " " + context.y;
    if(radius == Infinity) {
      commands += "L" + ending.x + " " + ending.y;
    } else {
      commands += "A" + radius + " " + radius + " 0 0 " + (sweep? 1 : 0) + " " + ending.x + " " + ending.y;
    }
    arc.setAttribute("d", commands);
    if(className) {
    	arc.setAttribute("class", className);
    }
    if(style) {
    	arc.setAttribute("style", style);
    }
    return arc;
  }

  function getAppList(relations) {
    var apps = [];
    for (key in relations) {
      var relation = relations[key];
      if(apps.indexOf(relation.a()) == -1) {
        apps.push(relation.a());
      }
      if(apps.indexOf(relation.b()) == -1) {
        apps.push(relation.b());
      }
    };
    return apps;
  }

  function getAppById(id) {
    var result;
    _apps.every(function (item) {
      if(item.id() == id) {
        result = item;
      }
      return result == undefined;
    });
    return result;
  }

  function getCaseById(id) {
    var result;
    _cases.every(function (item) {
      if(item.id() == id) {
        result = item;
      }
      return result == undefined;
    });
    return result;
  }

  function resetStyles() {
  	_apps.forEach(function(app) {
			enableApp(app, false);
  	});
  	for (var key in _relations) {
			enableRelation(_relations[key], false);
  	}
  }

  function enableApp(app, enabled) {
	  app.icon().setAttribute("opacity", enabled? 1 : 0.5);
	  if(enabled) {
	  	app.icon().removeAttribute("filter");
	  } else {
    	app.icon().setAttribute("filter", "url(#greyscale)");
	  }
  }

  function enableRelation(relation, enabled) {
		relation.dot().parentNode.parentNode.appendChild(relation.dot().parentNode);
  	relation.a().dot().setAttribute("class", enabled? "enabled" : "disabled");
  	relation.b().dot().setAttribute("class", enabled? "enabled" : "disabled");
  	relation.arc().setAttribute("class", enabled? "enabled" : "disabled");
		relation.dot().setAttribute("class", enabled? "enabled" : "disabled");
		relation.dot().setAttribute("visibility", enabled? "visible" : "hidden");
  }

  function mouseHandler(e) {
  	var target = e.currentTarget;
		var hover = e.type != "mouseout";
		if(hover) {
			resetStyles();
		}
  	switch(target.getAttribute("data-type")) {
  		case "app":
  			var info = {};
		    info.x = Number(target.getAttribute("data-x"));
		    info.y = Number(target.getAttribute("data-y"));
		    info.id = target.getAttribute("data-id");
		    info.name = target.getAttribute("data-name");
		    info.index = target.getAttribute("data-index");
		    info.type = target.getAttribute("data-type");
		    info.disabled = target.getAttribute("data-disabled") == "true";
		    if(hover) {
		    	enableApp(getAppById(info.id), true);
		    }
		    self.dispatchEvent(new Event(e.type, info));
		    break;
  		case "relation":
	  		var info = {};
		    info.idA = target.getAttribute("data-id-a");
		    info.nameA = target.getAttribute("data-name-a");
		    info.indexA = target.getAttribute("data-index-a");
		    info.idB = target.getAttribute("data-id-b");
		    info.nameB = target.getAttribute("data-name-b");
		    info.indexB = target.getAttribute("data-index-b");
		    info.count = target.getAttribute("data-count");
		    info.type = target.getAttribute("data-type");
			  var relation = _relations[info.idA + "-" + info.idB] || _relations[info.idB + "-" + info.idA];
		    info.x = Number(relation.dot().getAttribute("x"));
		    info.y = Number(relation.dot().getAttribute("y"));
		    if(hover) {
		    	enableRelation(relation, true);
		    	enableApp(relation.a(), true);
		    	enableApp(relation.b(), true);
		    }
		    self.dispatchEvent(new Event(e.type, info));
  			break;
  	}
  	if(!hover) {
  		self.showCase(_caseId);
  	}
  }

  init(apps, cases, container)
}
